extends EventNonInteractive

var trigger_effects

func _init():
	trigger_effects = {
		"on_gauges": {
			"NATURE": WeightChoice.randi_range(-8, -4),
			"HEALTH": WeightChoice.randi_range(-6, -2),
		},
	}

func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	#yield(turn_controller, "turn_changed")
	gauge_controller.apply_to_gauges(trigger_effects.on_gauges)
