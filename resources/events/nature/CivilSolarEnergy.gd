#Will suggest to finance civil solar panel installation in the city
extends DecisionSimple

func _init():
	#on accept
	accept_effects = {
		"on_gauges": {
			#"BUDGET": added later in code
			"SATISFACTION": WeightChoice.randi_range(7, 12) # may increase or not
		},
	}
	#on decline
	#no visible effects
	refuse_or_expire_effects = {
		"on_gauges": {
		},
	}

func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	var total_cost := WeightChoice.randi_range(-30, -20)
	description += str(total_cost * -1) + 'K $.'
	accept_effects['on_gauges']['BUDGET'] = total_cost

func on_accepted(_scene_tree: SceneTree) -> void:
	.on_accepted(_scene_tree)
	var monthly_effect = {
		"on_gauges": {
			'NATURE': WeightChoice.randi_range(1, 3)
		},
	}
	for _month in range(1, 12):
		yield(turn_controller, "turn_changed")
		gauge_controller.announce_gauges_diff(monthly_effect.on_gauges)
		gauge_controller.apply_to_gauges(monthly_effect.on_gauges)
