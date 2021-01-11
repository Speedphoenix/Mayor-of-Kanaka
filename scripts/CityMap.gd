class_name CityMap
extends Node2D

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

onready var global = get_tree().get_current_scene().get_node("GlobalObject")
onready var turn_controller = global.get_node("TurnController")

onready var tileid_background_filled := tile_set.find_tile_by_name(tilename_background_filled_tile)


# An iterator to go through each cell in order of manhattan distance
class TaxiCabRange:
	var curr_distance: int
	var max_distance: int
	var start_distance: int
	var stage: int
	var x: int
	var y: int
	
	enum Stages {RIGHT_TO_TOP = 0, TOP_TO_LEFT = 1, LEFT_TO_BOTTOM = 2, BOTTOM_TO_RIGHT = 3}
	
	# Use -1 to not set any maximum distance
	# max_distance is included in the iteration
	func _init(max_distance := -1, start_distance := 0):
		self.max_distance = max_distance
		self.start_distance = start_distance

	func should_continue() -> bool:
		return max_distance == -1 || curr_distance <= max_distance

	func _distance_init(dist: int):
		curr_distance = dist
		if dist == 0:
			x = 0
			y = 0
			# The last stage, so the next iteration will increase distance
			stage = Stages.BOTTOM_TO_RIGHT
		else:
			x = dist
			y = 0
			# The first stage
			stage = Stages.RIGHT_TO_TOP

	func _iter_init(_arg) -> bool:
		_distance_init(start_distance)
		return should_continue()

	func _iter_next(_arg) -> bool:
		# Can only happen on first iteration if start_distance = 0
		if (x == 0 && y == 0):
			_distance_init(curr_distance + 1)
			return should_continue()
		match stage:
			Stages.RIGHT_TO_TOP:
				x -= 1
				y += 1
			Stages.TOP_TO_LEFT:
				x -= 1
				y -= 1
			Stages.LEFT_TO_BOTTOM:
				x += 1
				y -= 1
			Stages.BOTTOM_TO_RIGHT:
				x += 1
				y += 1
		if (x == 0 && (stage % 2 == 0)) || (y == 0 && (stage % 2 == 1)):
			stage += 1
		if stage >= 4:
			_distance_init(curr_distance + 1)
		return should_continue()

	func _iter_get(_arg) -> Vector2:
		return Vector2(x, y)

func _ready():
	assert(tile_set == foreground_city.tile_set && tile_set == background_city.tile_set)
	turn_controller.connect("miniturn_changed", self, "_on_miniturn_changed")
	reset_map()

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

# TODO: make this take into account roads and the like
# (give roads a different background than buildings for this?)
func _spot_is_available(pos: Vector2, dims: Vector2) -> bool:
	for i in range(dims.x):
		for j in range(dims.y):
			if background_city.get_cell(pos.x + i, pos.y + j) != TileMap.INVALID_CELL:
				return false
	return true

# Returns an array of Vector2 that indicate possible positions
#
# Note that it may return an array smaller than count
# Remember to shuffle the array before using it
# search_limit is inclusive and decides how far to look in terms of Manhattan distance
func _get_available_spot(dims: Vector2, around_where: Vector2, count: int = 1, search_limit: int = 5) -> Array:
	var rep := []
	for diff in TaxiCabRange.new(search_limit):
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

# TODO: add randomness (don't always add a house, add a random number...)
func _on_miniturn_changed(turn_number, miniturn_number):
	if randi() % 2:
		add_random_house()
	
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
