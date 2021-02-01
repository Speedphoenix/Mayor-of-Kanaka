class_name ConstructionEffect
extends BaseEffect


# Used when the city does not provide space to construct the building
export(Vector2) var tile_dimensions: Vector2
export(String) var tile_name
export(int, 1, 2e9) var possibility_count := 1

# If true will use CityMap.BLOCK_OVERLAP_WEAK, else will use CityMap.BLOCK_OVERLAP_STRONG
export(bool) var possibilities_can_touch = true

var can_build_it = true
var city_map: CityMap
var possible_positions: Array
var usable_positions: Array
var chosen_pos_index: int = 0

# Called when the event is created, before the player has interracted with it
func on_triggered(scene_tree: SceneTree, _event: BaseEvent) -> void:
	.on_triggered(scene_tree, _event)
	city_map = CityMap.get_instance(scene_tree)
	var overlap_level: int = CityMap.BLOCK_OVERLAP_WEAK if possibilities_can_touch else CityMap.BLOCK_OVERLAP_STRONG
	possible_positions = city_map.get_available_spots(tile_dimensions,
			city_map.get_town_hall_position(), possibility_count, overlap_level)
	usable_positions = possible_positions.duplicate()
	usable_positions.shuffle()
	if usable_positions.empty():
		can_build_it = false
	else:
		can_build_it = true
		for pos in usable_positions:
			city_map.add_construction_work(pos, tile_dimensions)


func on_resolved(_scene_tree: SceneTree, resolve_type: int) -> void:
	if !can_build_it:
		return
	if not (resolve_type in which_resolves):
		_remove_construction_works()
	else:
		# Removes all except the one at chosen_pos_index
		_remove_construction_works(chosen_pos_index)

func apply_effect(_scene_tree: SceneTree, resolve_type: int, _current_delay: int) -> void:
	.apply_effect(_scene_tree, resolve_type, _current_delay)
	if !can_build_it:
		return
	if resolve_type in which_resolves:
		city_map.remove_building(usable_positions[chosen_pos_index], tile_dimensions)
		city_map.add_building(tile_name, usable_positions[chosen_pos_index], tile_dimensions)
		can_build_it = false

# Returns false if this should not be accepted
func blocks_accept(_scene_tree: SceneTree) -> bool:
	return can_build_it

func _remove_construction_works(to_ignore := -1):
	for i in range(usable_positions.size()):
		if i != to_ignore:
			city_map.remove_building(usable_positions[i], tile_dimensions)
