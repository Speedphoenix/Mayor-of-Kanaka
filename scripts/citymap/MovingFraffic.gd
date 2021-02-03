extends Node2D

# This should be the same as PathTilesManager
enum Direction { UP = 0, LEFT = 1, DOWN = 2, RIGHT = 3}

export(Vector2) var offset_to_road_center := Vector2(9, 9)
# Pixels per second
export(float) var speed := 82.0

export(int, 1, 1000) var keep_straight_weight := 24
export(int, 1, 1000) var turn_weight := 6
export(int, 1, 1000) var u_turn_weight := 1

var advance_in_cell: float
var current_direction: int = Direction.UP
var cell_size: Vector2
var cell_position: Vector2

onready var city_map := CityMap.get_instance(get_tree())

func _ready():
	# Else we should probably adapt this script
	assert(city_map.cell_size.x == city_map.cell_size.y)
	cell_size = city_map.cell_size

func _process(delta: float):
	_auto_advance(delta)

# Position must be in cells (not pixels)
func initialize(where: Vector2, direction := -1) -> void:
	assert(city_map.cell_is_road(int(where.x), int(where.y)))
	cell_position = where
	if direction != -1:
		current_direction = direction
	else:
		var neighbours: Array = city_map.get_road_neighbours(where.x, where.y)
		var choice: Array = WeightChoice.choose_by_weight(neighbours)
		if choice.size() != 0:
			var chosen_dir: int = choice[0]
			current_direction = chosen_dir
	advance_in_cell = cell_size.x / 2
	
	_use_pos()

func _get_along_direction(dir: int, dist: float) -> Vector2:
	match dir:
		Direction.RIGHT:
			return Vector2(dist, 0)
		Direction.LEFT:
			return Vector2(-1 * dist, 0)
		Direction.DOWN:
			return Vector2(0, dist)
		Direction.UP, _:
			return Vector2(0, -1 * dist)

func _get_from_direction(dir: int, what: Vector2) -> float:
	match dir:
		Direction.RIGHT:
			return what.x
		Direction.LEFT:
			return -1 * what.x
		Direction.DOWN:
			return what.y
		Direction.UP, _:
			return -1 * what.y

func _auto_advance(delta: float):
	var old_pos := advance_in_cell
	var new_pos := advance_in_cell + delta * speed
	var cell_length := int(cell_size.x)
	var turned := false
	
	# If we just passed the halfwaypoint
	if old_pos < float(cell_length) / 2 && new_pos > float(cell_length) / 2:
		# Find which ways we can go
		var neighbours: Array = city_map.get_road_neighbours(cell_position.x, cell_position.y)
		for i in range(neighbours.size()):
			if i == current_direction:
				neighbours[i] *= keep_straight_weight
			elif i % 2 != current_direction % 2:
				neighbours[i] *= turn_weight
			else:
				neighbours[i] *= u_turn_weight
		var choice: Array = WeightChoice.choose_by_weight(neighbours)
		if choice.size() != 0:
			var chosen_dir: int = choice[0]
			if chosen_dir != current_direction:
				turned = true
				advance_in_cell = float(cell_length) / 2
				current_direction = chosen_dir
	if !turned:
		if new_pos > cell_length:
			cell_position += _get_along_direction(current_direction, 1)
			advance_in_cell = int(new_pos) % cell_length
		else:
			advance_in_cell = new_pos
	_use_pos()

func _use_pos():
	var position_in_cell: Vector2
	match current_direction:
		Direction.RIGHT:
			position_in_cell = Vector2(advance_in_cell, cell_size.y / 2 + offset_to_road_center.y)
			$Sprite.rotation_degrees = -90
		Direction.LEFT:
			position_in_cell = Vector2(cell_size.x - advance_in_cell, cell_size.y / 2 - offset_to_road_center.y)
			$Sprite.rotation_degrees = 90
		Direction.DOWN:
			position_in_cell = Vector2(cell_size.x / 2 - offset_to_road_center.x, advance_in_cell)
			$Sprite.rotation_degrees = 0
		Direction.UP, _:
			position_in_cell = Vector2(cell_size.x / 2 + offset_to_road_center.x, cell_size.y - advance_in_cell)
			$Sprite.rotation_degrees = 180
	self.position = (cell_position * cell_size) + position_in_cell
	
	
	
