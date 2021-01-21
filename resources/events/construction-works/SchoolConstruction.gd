extends DecisionSimple

export(String, MULTILINE) var no_space_description: String
export(Vector2) var school_dims := Vector2(3, 2)
export(String) var school_tile_name := "school"

var city_map: CityMap
var have_space := true
var chosen_position: Vector2

func _init():
	#on accept
	#Mayor will do a public speach
	accept_effects = {
		"on_gauges": {
			"BUDGET": -200,
			"SATISFACTION": 40,
		},
	}
	#on decline
	#City hall does not react, satisfaction goes down, stress increrase
	refuse_or_expire_effects = {
		"on_gauges": {
			"SATISFACTION": -50,
		},
	}
	
func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	city_map = CityMap.get_city_map(scene_tree)
	var possible_positions: Array = city_map.get_available_spots(school_dims, city_map.get_town_hall_center_position())
	if possible_positions.empty():
		have_space = false
		description = no_space_description
	else:
		have_space = true
		chosen_position = possible_positions[0]
		city_map.add_building(school_tile_name, chosen_position, school_dims)

func on_accepted(scene_tree: SceneTree) -> void:
	.on_accepted(scene_tree)

func on_refused(scene_tree: SceneTree) -> void:
	.on_refused(scene_tree)

func on_expired(scene_tree: SceneTree) -> void:
	.on_expired(scene_tree)
