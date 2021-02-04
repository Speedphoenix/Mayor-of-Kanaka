extends EventNonInteractive

var vandal_action = ['turned over hundreds of trash cans all over the city',
	"left graffiti on the windows of many city shops. All saying: 'deceitful eco-friendly'"]
var trigger_effects

func _init():
	#due to the vandalism actions the satisfaction goes up
	trigger_effects = {
		"on_gauges": {
			"SATISFACTION": -4,
		},
	}

func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	#yield(turn_controller, "turn_changed")
	description = ("Mayor, this night some people have "
	+ WeightChoice.choose_random_from_array(vandal_action) + ".")
	gauge_controller.apply_to_gauges(trigger_effects.on_gauges)
