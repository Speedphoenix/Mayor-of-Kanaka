class_name PathTilesManager
extends Reference

# Note on the tile names:
# for one connection, the name indicates where it is connected
# for corners, the directions indicate which sides are connected
# for triple, the direction indicates the middle connection (NOT the empty side)

# TODO: randomly use alt tiles

enum Direction { UP = 0, LEFT = 1, RIGHT = 2, DOWN = 3}
enum PathType { ANYPATH, ROAD, WATERWAY }

# I know this should be done in better fashions
# This is essentially autotiles done manually
# because I couldn't figure how to make autotiles work properly
var tiles := [
	{
		"tilename": "road_no_connection",
		"neighbours_array": [0, 0, 0, 0],
	},
	{
		"tilename": "road_vertical",
		"neighbours_array": [1, 0, 0, 1],
	},
	{
		"tilename": "road_horizontal",
		"neighbours_array": [0, 1, 1, 0],
	},
	{
		"tilename": "crossroad",
		"neighbours_array": [1, 1, 1, 1],
	},
	{
		"tilename": "road_one_connection_up",
		"neighbours_array": [1, 0, 0, 0],
	},
	{
		"tilename": "road_one_connection_right",
		"neighbours_array": [0, 0, 1, 0],
	},
	{
		"tilename": "road_one_connection_left",
		"neighbours_array": [0, 1, 0, 0],
	},
	{
		"tilename": "road_one_connection_down",
		"neighbours_array": [0, 0, 0, 1],
	},
	{
		"tilename": "road_corner_right_up",
		"neighbours_array": [1, 0, 1, 0],
	},
	{
		"tilename": "road_corner_up_left",
		"neighbours_array": [1, 1, 0, 0],
	},
	{
		"tilename": "road_corner_left_down",
		"neighbours_array": [0, 1, 0, 1],
	},
	{
		"tilename": "road_corner_down_right",
		"neighbours_array": [0, 0, 1, 1],
	},
	{
		"tilename": "road_triple_up",
		"neighbours_array": [1, 1, 1, 0],
	},
	{
		"tilename": "road_triple_down",
		"neighbours_array": [0, 1, 1, 1],
	},
	{
		"tilename": "road_triple_left",
		"neighbours_array": [1, 1, 0, 1],
	},
	{
		"tilename": "road_triple_right",
		"neighbours_array": [1, 0, 1, 1],
	},
]

# other alternative tiles
var alt_tiles := [
	{
		# pedestrian crossing
		"tilename": "road_vertical_crossing",
		"neighbours_array": [1, 0, 0, 1],
		"can_replace_default": true,
	},
	{
		# pedestrian crossing
		"tilename": "road_horizontal_crossing",
		"neighbours_array": [0, 1, 1, 0],
		"can_replace_default": true,
	},
	{
		"tilename": "bus_stop_horizontal",
		"neighbours_array": [0, 1, 1, 0],
		"can_replace_default": false,
	},
	{
		"tilename": "bus_stop_vertical",
		"neighbours_array": [1, 0, 0, 1],
		"can_replace_default": false,
	},
]

var road_tiles_list := []

static func get_diff_from_dir(direction: int) -> Vector2:
	match direction:
		Direction.UP:
			return Vector2(0, -1)
		Direction.LEFT:
			return Vector2(-1, 0)
		Direction.RIGHT:
			return Vector2(1, 0)
		Direction.DOWN:
			return Vector2(0, 1)
	return Vector2(0, 0)

func _init(tile_set: TileSet):
	for el in tiles:
		el.tileid = tile_set.find_tile_by_name(el.tilename)
		road_tiles_list.append(el.tileid)
	for el in alt_tiles:
		el.tileid = tile_set.find_tile_by_name(el.tilename)
		if el.can_replace_default:
			road_tiles_list.append(el.tileid)

func get_tileid_from_neighbours(neighbours: Array, alt_probability := 0.0) -> int:
	var found := TileMap.INVALID_CELL
	var alts := []
	for el in tiles:
		if el.neighbours_array == neighbours:
			found = el.tileid
	for el in alt_tiles:
		if el.can_replace_default && el.neighbours_array == neighbours:
			alts.append(el.tileid)
	if alts.empty():
		return found
	elif found == TileMap.INVALID_CELL || randf() < alt_probability:
		return WeightChoice.choose_random_from_array(alts)
	return found

# TODO: take direction into account for stuff like bus stops that can't be changed
# (you can only connect to a bus stop road tile if you're ahead or behind it)
# TODO: specialize depending on current tile (road vs water etc)
func cell_can_connect_to(current_tile: int, target_tileid: int, current_pos: Vector2, tarteg_pos: Vector2) -> bool:
	return (current_tile == PathType.ROAD || current_tile == PathType.ANYPATH) && target_tileid in road_tiles_list
	
func tile_is_path(tileid: int, path_type := PathType.ANYPATH) -> bool:
	for el in tiles:
		if el.tileid == tileid:
			return true
	# TODO: specialize this?
	for el in alt_tiles:
		if el.tileid == tileid && el.can_replace_default:
			return true
	return false
	
	
