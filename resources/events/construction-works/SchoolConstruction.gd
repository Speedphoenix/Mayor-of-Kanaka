extends ConstructionEvent

# The name of the gauge that will be incremented when a building is erected
const gauge_counter_name = "SCHOOL"

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


func on_accepted(scene_tree: SceneTree) -> void:
	.on_accepted(scene_tree)
	if can_build_it:
		# The school building will be constructed!
		if !gauge_controller.gauge_exists(gauge_counter_name):
			gauge_controller.create_gauge(gauge_counter_name, 0, { "LOWER": 0 })
		gauge_controller.apply_to_gauge(gauge_counter_name, 1)
