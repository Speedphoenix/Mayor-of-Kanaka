class_name CityMap
extends Node2D

const BFS_SEARCH := 0
const TAXI_CAB_SEARCH := 1

const BLOCK_OVERLAP_NONE := 0
const BLOCK_OVERLAP_WEAK := 1
const BLOCK_OVERLAP_STRONG := 2

export(Vector2) var initial_townhall_position = Vector2(11, 7)

export(String) var tilename_background_empty_tile = "grass"
export(String) var tilename_background_filled_tile = "concrete"
export(String) var tilename_townhall = "townhall"
export(String) var tilename_house = "house"

# These will in time be changed for autotiles
export(String) var tilename_road_vertical = "road_vertical"
export(String) var tilename_road_horizontal = "road_horizontal"
export(String) var tilename_crossroad = "crossroad"

# This is a static background, could be a tilemap or an image.
# It will not move and will likely not ever be used
onready var background: Node2D = $Background

onready var full_city: Node2D = $FullCity
onready var background_city: TileMap = $FullCity/BackgroundCity
onready var foreground_city: TileMap = $FullCity/ForegroundCity

onready var tile_set: TileSet = background_city.tile_set

onready var cell_size: Vector2 = background_city.cell_size

onready var turn_controller := TurnController.get_turn_controller(get_tree())

onready var tileid_background_filled := tile_set.find_tile_by_name(tilename_background_filled_tile)

# An iterator to go through each cell in order of manhattan distance

func _ready():
	assert(tile_set == foreground_city.tile_set && tile_set == background_city.tile_set)
	turn_controller.connect("miniturn_changed", self, "_on_miniturn_changed")
	reset_map()

# TODO:
# - A more random choice (make it randomer)
# - Take only spots that are contiguous to the rest of the city?
# - Allow for different sizes of houses
# - Take roads into account
# - Make the steps above generic and usable for other buildings
func add_random_house() -> bool:
	var house_dims := Vector2(1, 1)
	var spots := _get_available_spot(house_dims, initial_townhall_position, 7)
	if spots.size() > 0:
		spots.shuffle()
		_add_tile_at(tilename_house, spots[0], house_dims)
		return true
	return false

func reset_map() -> void:
	background_city.clear()
	foreground_city.clear()
	_add_tile_at(tilename_townhall, initial_townhall_position, _get_tile_size(tilename_townhall))

# Preferably do not use this, but rather receive the information from other sources...
func _get_tile_size(tile_name: String) -> Vector2:
	var tile_id = tile_set.find_tile_by_name(tile_name)
	var pixel_up_to := tile_set.tile_get_region(tile_id).size
	var x := int(pixel_up_to.x / cell_size.x)
	var y := int(pixel_up_to.y / cell_size.y)
	if int(pixel_up_to.x) % int(cell_size.x) != 0:
		x += 1
	if int(pixel_up_to.y) % int(cell_size.y) != 0:
		y += 1
	return Vector2(x, y)

func _add_tile_at(tile_name: String, where: Vector2, dims: Vector2):
	var tile_id = tile_set.find_tile_by_name(tile_name)
	var filled_id = tile_set.find_tile_by_name(tilename_background_filled_tile)
	for i in range(dims.x):
		for j in range(dims.y):
			background_city.set_cellv(where + Vector2(i, j), filled_id)
	foreground_city.set_cellv(where, tile_id)

# Returns whether a cell is part of the city or empty
func _cell_can_connect(x: int, y: int) -> bool:
	return background_city.get_cell(x, y) != TileMap.INVALID_CELL

# Returns whether a building can be created here
# TODO: make this able to build on roads if that's not blocking a building
func _can_build_on_cell(x: int, y: int) -> bool:
	return background_city.get_cell(x, y) == TileMap.INVALID_CELL

# TODO: make this take into account roads and the like
# (give roads a different background than buildings for this?)
func _spot_is_available(pos: Vector2, dims: Vector2) -> bool:
	for i in range(dims.x):
		for j in range(dims.y):
			if !_can_build_on_cell(pos.x + i, pos.y + j):
				return false
	return true

# Will return an array of available spots (Vector2) that include included_cell
# TODO: find a better name for this func
# TODO: optimize this with spot_is_available to not iterate n^2 times too many
# TODO: get the first element to be the most centered around included_cell?
func _find_available_spots(included_cell: Vector2, dims: Vector2) -> Array:
	var rep := []
	for i in range(included_cell.x - (dims.x - 1), included_cell.x + dims.x):
		for j in range(included_cell.y - (dims.y - 1), included_cell.y + dims.y):
			if _spot_is_available(Vector2(i, j), dims):
				rep.append(Vector2(i, j))
	return rep

func _get_available_spot_manhattan(
	dims: Vector2,
	around_where: Vector2,
	count: int = 1,
	search_limit: int = 5
) -> Array:
	var rep := []
	for diff in TaxiCabIterator.new(search_limit):
		var curr_cell: Vector2 = around_where + diff
		var spot_origin: Vector2
		# Please tell me if you have a prettier way of doing this
		if diff.x >= 0 && diff.y >= 0:
			spot_origin = curr_cell
			if _spot_is_available(spot_origin, dims):
				rep.append(spot_origin)
			if rep.size() >= count:
				break
		if diff.x >= 0 && diff.y <= 0:
			spot_origin = Vector2(curr_cell.x, curr_cell.y - (dims.y - 1))
			if _spot_is_available(spot_origin, dims):
				rep.append(spot_origin)
			if rep.size() >= count:
				break
		if diff.x <= 0 && diff.y <= 0:
			spot_origin = Vector2(curr_cell.x - (dims.x - 1), curr_cell.y - (dims.y - 1))
			if _spot_is_available(spot_origin, dims):
				rep.append(spot_origin)
			if rep.size() >= count:
				break
		if diff.x <= 0 && diff.y >= 0:
			spot_origin = Vector2(curr_cell.x - (dims.x - 1), curr_cell.y)
			if _spot_is_available(spot_origin, dims):
				rep.append(spot_origin)
			if rep.size() >= count:
				break
	return rep

# around_where must be a full cell,
# else the returned array will only contain spots icluding with that cell
# TODO: implement a ignore_overlapping parameter
func _get_available_spot_bfs(
	dims: Vector2,
	around_where: Vector2,
	count: int = 1,
	search_limit: int = 5,
	overlapping_ignore_level: int = BLOCK_OVERLAP_NONE
) -> Array:
	# This is to be used as a queue, where the oldest and next in line is the front
	var next_cells := []
	# The keys to this are Vector2s that indicate cells that have already been checked or added
	var checked_already := {}
	
	# Cells that are already in rep or that should not added to it
	# eg. overlapping with some of those in rep
	var ignore_rep := {}
	# Array of Vector2s indicating empty cells.
	# Elements of this array are also keys to checked_already
	var rep := []

	next_cells.push_back(around_where)
	checked_already[around_where] = true
	
	while rep.size() < count && !next_cells.empty():
		var current_cell: Vector2 = next_cells.pop_front()
		# check if the distance has gotten too big
		var cell_diff: Vector2 = (current_cell - around_where).abs()
		if cell_diff.x + cell_diff.y > search_limit:
			break
		if _can_build_on_cell(current_cell.x, current_cell.y):
			var available: Array = _find_available_spots(current_cell, dims)
			var to_add := []
			var skipped := false
			for el in available:
				if !ignore_rep.has(el):
					to_add.append(el)
				elif overlapping_ignore_level == BLOCK_OVERLAP_STRONG:
					skipped = true
					break
			if !skipped: # if we block overlaps
				for el in available:
					ignore_rep[el] = true
			if overlapping_ignore_level == BLOCK_OVERLAP_NONE: # may replace with a match in time
				for el in to_add:
					rep.append(el)
					if rep.size() > count:
						break
			elif !to_add.empty(): # BLOCK_OVERLAP_WEAK or STRONG
				rep.append(to_add[0])
		if _cell_can_connect(current_cell.x, current_cell.y):
			# Look at directly adjacent cells
			for diff in TaxiCabIterator.new(1, 1):
				var to_add_cell: Vector2 = current_cell + diff
				if !checked_already.has(to_add_cell):
					checked_already[to_add_cell] = true
					next_cells.push_back(to_add_cell)
	return rep

# Returns an array of Vector2 that indicate possible positions
#
# Note that it may return an array smaller than count
# The returned array has the closest cell at the front
# Remember to shuffle the array before using it
# search_limit is inclusive and decides how far to look in terms of Manhattan distance
func _get_available_spot(
	dims: Vector2,
	around_where: Vector2,
	count: int = 1,
	search_limit: int = 5,
	method: int = BFS_SEARCH
) -> Array:
	match method:
		TAXI_CAB_SEARCH:
			return _get_available_spot_manhattan(dims, around_where, count, search_limit)
		_, BFS_SEARCH:
			return _get_available_spot_bfs(dims, around_where, count, search_limit)

# TODO: add randomness (don't always add a house, add a random number...)
func _on_miniturn_changed(turn_number, miniturn_number):
	if randi() % 2:
		add_random_house()
