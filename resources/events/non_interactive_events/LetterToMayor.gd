extends EventNonInteractive

var trigger_effects

func _init():
	trigger_effects = {
		"on_gauges": {
			"SATISFACTION": WeightChoice.randi_range(-5, 5),
		},
	}

func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	if(trigger_effects['on_gauges']['SATISFACTION']>=0):
		description += "satisfied."
	else:
		description += "unsatisfied."
	gauge_controller.apply_to_gauges(trigger_effects.on_gauges)
