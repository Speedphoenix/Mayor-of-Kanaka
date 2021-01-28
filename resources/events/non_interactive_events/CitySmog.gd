extends EventNonInteractive

var trigger_effects

func _init():
	#to the smog over the city NATURE goes down
	#this is a monthly effect
	trigger_effects = {
		"on_gauges": {
			"NATURE": -3,
		},
	}

func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	for _month in range(1, 12):
		yield(turn_controller, "turn_changed")
		gauge_controller.apply_to_gauges(trigger_effects.on_gauges)
