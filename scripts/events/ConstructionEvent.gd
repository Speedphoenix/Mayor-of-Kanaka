class_name ConstructionEvent
extends DecisionSimple

# Used when the city does not provide space to construct the building
export(String, MULTILINE) var no_space_description: String
export(Vector2) var tile_dimensions: Vector2
export(String) var tile_name
export(int, 1, 2e9) var possibility_count := 1

# If true will use CityMap.BLOCK_OVERLAP_WEAK, else will use CityMap.BLOCK_OVERLAP_STRONG
export(bool) var possibilities_can_touch = true

var can_build_it := true

var city_map: CityMap
var possible_positions: Array
	
func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	city_map = CityMap.get_instance(scene_tree)
	var overlap_level: int = CityMap.BLOCK_OVERLAP_WEAK if possibilities_can_touch else CityMap.BLOCK_OVERLAP_STRONG
	possible_positions = city_map.get_available_spots(tile_dimensions,
			city_map.get_town_hall_center_position(), possibility_count, overlap_level)
	possible_positions.shuffle()
	if possible_positions.empty():
		can_build_it = false
		description = no_space_description
	else:
		can_build_it = true
		for pos in possible_positions:
			city_map.add_construction_work(pos, tile_dimensions)

func on_accepted(scene_tree: SceneTree) -> void:
	.on_accepted(scene_tree)
	if !possible_positions.empty():
		_remove_construction_works(true)
		yield(turn_controller, "turn_changed")
		city_map.remove_building(possible_positions[0], tile_dimensions)
		city_map.add_building(tile_name, possible_positions[0], tile_dimensions)

func _remove_construction_works(ignore_first := false):
	var start: int = 1 if ignore_first else 0
	for i in range(start, possible_positions.size()):
		city_map.remove_building(possible_positions[i], tile_dimensions)

func on_refused(scene_tree: SceneTree) -> void:
	.on_refused(scene_tree)
	_remove_construction_works()

func on_expired(scene_tree: SceneTree) -> void:
	.on_expired(scene_tree)
	_remove_construction_works()
