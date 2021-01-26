extends EventNonInteractive

var manif_reasons := ['Energy consumption', 'Ecological situation']
var square_names := ['Bariko', 'Zuula', 'General', 'Zaebumba']
var trigger_effects 

func _init():
	#due to the manifestation the stress goes up
	trigger_effects = {
		"on_gauges": {
			"STRESS": 5,
		},
	}

func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	
	description = ("Mayor, people are manifestating on "
	+ WeightChoice.choose_random_from_array(square_names) + " square"
	+ ". The reason is Kanaka's " + WeightChoice.choose_random_from_array(manif_reasons) + '.')
	#gauge_controller.get_gauge_controller(scene_tree).apply_to_gauges(trigger_effects.on_gauges)
	
