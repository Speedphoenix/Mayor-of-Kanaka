extends EventNonInteractive

var trigger_effects

var stress_diff := 10

func _init():
	trigger_effects = {
		"on_gauges": {
			"SATISFACTION": WeightChoice.randi_range(-5, 5),
		},
	}

func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	if trigger_effects['on_gauges']['SATISFACTION'] > 0:
		description += "satisfied."
		stress_diff *= -1
	elif trigger_effects['on_gauges']['SATISFACTION'] < 0:
		description += "unsatisfied."
	else:
		description += "uninterested"
		stress_diff = 0
	gauge_controller.apply_to_gauges(trigger_effects.on_gauges)

func on_accepted(scene_tree: SceneTree) -> void:
	.on_accepted(scene_tree)
	gauge_controller.apply_to_gauge("STRESS", stress_diff)
