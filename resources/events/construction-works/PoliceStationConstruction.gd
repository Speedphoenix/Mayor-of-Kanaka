extends ConstructionEvent

# The name of the gauge that will be incremented when a building is erected
const gauge_counter_name = "POLICE_STATION"

func _init():
	#on accept
	# Satisfaction goes up, stress down
	accept_effects = {
		"on_gauges": {
			#"BUDGET":added later
			"SATISFACTION": WeightChoice.randi_range(10, 20),
			"STRESS": WeightChoice.randi_range(-5, -3)
		},
	}
	#on decline
	#Satisfaction goes down, stress goes up
	refuse_or_expire_effects = {
		"on_gauges": {
			"SATISFACTION": WeightChoice.randi_range(-8, -3),
			"STRESS": WeightChoice.randi_range(3, 5)
		},
	}

func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	var cunstruction_cost := WeightChoice.randi_range(-550, -300)
	description += str(cunstruction_cost * -1) + 'K $.'
	accept_effects['on_gauges']['BUDGET'] = cunstruction_cost

func on_accepted(scene_tree: SceneTree) -> void:
	.on_accepted(scene_tree)
	if can_build_it:
		# The school building will be constructed!
		if !gauge_controller.gauge_exists(gauge_counter_name):
			gauge_controller.create_gauge(gauge_counter_name, 0, { "LOWER": 0 })
		gauge_controller.apply_to_gauge(gauge_counter_name, 1)
