extends ConstructionEvent

# The name of the gauge that will be incremented when a building is erected
const gauge_counter_name = "HOSPITAL"

func _init():
	#on accept
	#increase overall HEALTH level
	accept_effects = {
		"on_gauges": {
			#"BUDGET": added later in code
			"HEALTH": 20,
		},
	}
	#on decline
	#City hall does not react, satisfaction goes down
	refuse_or_expire_effects = {
		"on_gauges": {
			"SATISFACTION": -40,
		},
	}

func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	var cunstruction_cost := WeightChoice.randi_range(-1200, -800)
	description += str(cunstruction_cost * -1) + ' $.'
	accept_effects['on_gauges']['BUDGET'] = cunstruction_cost

func on_accepted(scene_tree: SceneTree) -> void:
	.on_accepted(scene_tree)
	if can_build_it:
		# The school building will be constructed!
		if !gauge_controller.gauge_exists(gauge_counter_name):
			gauge_controller.create_gauge(gauge_counter_name, 0, { "LOWER": 0 })
		gauge_controller.apply_to_gauge(gauge_counter_name, 1)
