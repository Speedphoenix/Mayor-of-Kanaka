extends EventNonInteractive

var trigger_effects

func _init():
	#due to the vandalism actions the satisfaction goes up
	trigger_effects = {
		"on_gauges": {
			"NATURE": -10,
		},
	}

func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	#TODO
	#gauge_controller.get_gauge_controller(scene_tree).apply_to_gauges(trigger_effects.on_gauges)
