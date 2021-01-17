class_name CityMap
extends Node2D

# TODO:
# keep the city's dimensions in memory somewhere?
# add a add-road-here function (done)
#	will add road n° 1
#	check roads around it, update their tile and itself
# when doing previews don't change the background tile until it's set in stone

enum SurroundMode {
	NO_SURROUND,
	FRONT_ONLY,
	FULL_SURROUND,
}

const BFS_SEARCH := 0
const TAXI_CAB_SEARCH := 1

const BLOCK_OVERLAP_NONE := 0
const BLOCK_OVERLAP_WEAK := 1
const BLOCK_OVERLAP_STRONG := 2

export(Vector2) var initial_townhall_position = Vector2(11, 7)
# Could be added to the game params
export(SurroundMode) var initial_townhall_surrounding_roads := SurroundMode.FRONT_ONLY

export(float, 0, 1) var new_house_probability = 0.5
export(int) var max_city_length := 20000000
export(int) var new_house_choises_max_count := 100

export(String) var tilename_background_empty_tile = "grass"
export(String) var tilename_background_filled_tile = "concrete"
export(String) var tilename_townhall = "townhall"

export(Array, Dictionary) var houses := [
	{
		"tilename": "house",
		"dimensions": Vector2(1, 1),
		"weight": 8,
	},
	{
		"tilename": "house_long_horizontal",
		"dimensions": Vector2(2, 1),
		"weight": 1,
	},
	{
		"tilename": "house_long_vertical",
		"dimensions": Vector2(1, 2),
		"weight": 1,
	},
]

var path_tiles: PathTilesManager

var townhall_dims: Vector2


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
	path_tiles = PathTilesManager.new(tile_set)
	turn_controller.connect("miniturn_changed", self, "_on_anyturn_changed")
	turn_controller.connect("turn_changed", self, "_on_anyturn_changed")
	townhall_dims = _get_tile_size(tilename_townhall)
	reset_map()
	for i in range(30):
		WeightChoice.choose_dict_by_weight(houses)

func reset_map() -> void:
	background_city.clear()
	foreground_city.clear()
	var townhall_dims = _get_tile_size(tilename_townhall)
	_add_tile_at(tilename_townhall, initial_townhall_position, townhall_dims)
	match initial_townhall_surrounding_roads:
		SurroundMode.NO_SURROUND:
			pass
		SurroundMode.FRONT_ONLY:
			for i in range(initial_townhall_position.x, initial_townhall_position.x + townhall_dims.x):
				add_road(i, initial_townhall_position.y + townhall_dims.y)
		SurroundMode.FULL_SURROUND:
			for pos in TaxiCabIterator.get_adjacent_coords(initial_townhall_position, townhall_dims, true):
				add_road(pos.x, pos.y)

# TODO:
# - A more random choice (make it randomer)
# - Take only spots that are contiguous to the rest of the city?
# - Allow for different sizes of houses
# - Make the steps above generic and usable for other buildings
func add_random_house() -> bool:
	assert(!houses.empty())
	var chosen_house: Dictionary = WeightChoice.choose_dict_by_weight(houses)
	assert(chosen_house.has("dimensions"))
	var house_dims: Vector2 = chosen_house.dimensions
	var spots := _get_available_spots(house_dims, initial_townhall_position,
			new_house_choises_max_count, max_city_length)
	if spots.size() > 0:
		var chosen_spot = WeightChoice.choose_random_from_array(spots)
		_add_tile_at(chosen_house.tilename, chosen_spot, house_dims)
		construct_road_to(chosen_spot, house_dims)
		return true
	return false

# This will add roads leading to where, but not inside it
# If there is already a road touching it, will return immediately
# If there is no free space for roads, will return immediately
func construct_road_to(where: Vector2, dims: Vector2) -> void:
	var found_road := false
	var found_building := false
	var closest_building: Vector2
	var closest_road: Vector2
	
	# This is to be used as a queue, where the oldest and next in line is the front
	var next_cells := []
	# The keys to this are Vector2s that indicate cells that have already been checked or added
	# The values are Vector2s indicating where the path is coming from
	# Or itself if it's the start of the search or invalid
	var passed_already := {}
	
	# Add initial cells
	for coord in TaxiCabIterator.get_adjacent_coords(where, dims):
		if _cell_is_road(coord.x, coord.y):
			return
		if _cell_connects_to_city(coord.x, coord.y):
			continue
		next_cells.push_back(coord)
		passed_already[coord] = coord
	# Can't build roads anyway
	if next_cells.empty():
		return
	# Add cells that should be ignored
	for i in range(where.x, where.x + dims.x):
		for j in range(where.y, where.y + dims.y):
			passed_already[Vector2(i, j)] = Vector2(i, j)

	while !found_road && !next_cells.empty():
		var current_cell: Vector2 = next_cells.pop_front()
		# Look at directly adjacent cells
		for diff in TaxiCabIterator.new(1, 1):
			var to_add_cell: Vector2 = current_cell + diff
			if passed_already.has(to_add_cell):
				continue
			passed_already[to_add_cell] = current_cell
			if _cell_is_connectable_road(to_add_cell.x, to_add_cell.y):
				found_road = true
				closest_road = to_add_cell
				break
			elif _cell_connects_to_city(to_add_cell.x, to_add_cell.y):
				# Only set that as the found building if the track passes through available space first
				if !found_building && !_cell_connects_to_city(current_cell.x, current_cell.y):
					found_building = true
					closest_building = to_add_cell
			else:
				# Need to check that we don't stray away from the city
				for neighbour in TaxiCabIterator.get_adjacent_coords(to_add_cell, Vector2(1, 1), true):
					if _cell_connects_to_city(neighbour.x, neighbour.y):
						next_cells.push_back(to_add_cell)
						break
	if found_road || found_building:
		var last_empty: Vector2 = passed_already[closest_road if found_road else closest_building]
		_trace_back_road_bfs(last_empty, passed_already)
	else: # Somehow this building is alone, still gotta add one road if possible
		for coord in TaxiCabIterator.get_adjacent_coords(where, dims):
			if _can_build_on_cell(coord.x, coord.y):
				add_road(coord.x, coord.y)
				break

func _get_neighbor_connectivity(x: int, y: int, xdiff: int, ydiff: int) -> int:
	var target_id = foreground_city.get_cell(x + xdiff, y + ydiff)
	return int(path_tiles.cell_can_connect_to(PathTilesManager.PathType.ROAD,
			target_id, Vector2(x, y), Vector2(x + xdiff, y + ydiff)))

# Will add a single road tile and connect it around
# TODO: make it connect to nearby roads
func add_road(x: int, y: int, neighbours_too := true) -> void:
	background_city.set_cell(x, y, tileid_background_filled)
	var neighbours = [0, 0, 0, 0]
	
	neighbours[PathTilesManager.Direction.UP] = _get_neighbor_connectivity(x, y, 0, -1)
	neighbours[PathTilesManager.Direction.LEFT] = _get_neighbor_connectivity(x, y, -1, 0)
	neighbours[PathTilesManager.Direction.RIGHT] = _get_neighbor_connectivity(x, y, 1, 0)
	neighbours[PathTilesManager.Direction.DOWN] = _get_neighbor_connectivity(x, y, 0, 1)
	foreground_city.set_cell(x, y, path_tiles.get_tileid_from_neighbours(neighbours))
	
	if neighbours_too:
		for dir in PathTilesManager.Direction:
			if neighbours[PathTilesManager.Direction[dir]] == 1:
				var diff := PathTilesManager.get_diff_from_dir(PathTilesManager.Direction[dir])
				# make sure the neighbours connect themselves
				add_road(x + diff.x, y + diff.y, false)

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
	for i in range(dims.x):
		for j in range(dims.y):
			background_city.set_cellv(where + Vector2(i, j), tileid_background_filled)
	foreground_city.set_cellv(where, tile_id)

# Returns whether a cell is part of the city or empty
func _cell_connects_to_city(x: int, y: int) -> bool:
	return background_city.get_cell(x, y) != TileMap.INVALID_CELL

# Returns whether a building or road can be created here
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

func _get_available_spots_manhattan(
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
func _get_available_spots_bfs(
	dims: Vector2,
	around_where: Vector2,
	count: int = 1,
	search_limit: int = 5,
	starting_dims := Vector2(1, 1),
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
		if _cell_connects_to_city(current_cell.x, current_cell.y):
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
func _get_available_spots(
	dims: Vector2,
	around_where: Vector2,
	count: int = 1,
	search_limit: int = 5,
	method: int = BFS_SEARCH
) -> Array:
	match method:
		TAXI_CAB_SEARCH:
			return _get_available_spots_manhattan(dims, around_where, count, search_limit)
		_, BFS_SEARCH:
			return _get_available_spots_bfs(dims, around_where, count, search_limit, townhall_dims)

# TODO: add randomness (don't always add a house, add a random number...)
func _on_anyturn_changed(turn_number, miniturn_number):
	if randf() <= new_house_probability:
		add_random_house()

# Returns whether the cell contains a bit of road
# TODO: rather if the cell is one of the possible road tiles
func _cell_is_road(x: int, y: int) -> bool:
	return path_tiles.tile_is_path(foreground_city.get_cell(x, y))

# Returns whether the cell contains a bit of road that can be connected to more road
# For example a bus stop might return false
# TODO: use can_connect_to
func _cell_is_connectable_road(x: int, y: int) -> bool:
	return _cell_is_road(x, y)

# TODO: add the possibility to do this over time with yields n' stuff
func _trace_back_road_bfs(start: Vector2, passed_already: Dictionary):
	var current := start
	if _can_build_on_cell(current.x, current.y):
		add_road(current.x, current.y)
	while current != passed_already[current]:
		current = passed_already[current]
		if _can_build_on_cell(current.x, current.y):
			add_road(current.x, current.y)