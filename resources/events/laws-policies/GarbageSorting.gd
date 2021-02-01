extends DecisionSimple

var monthyl_effects
var effect_duration: int

func _init():
	#on accept
	accept_effects = {
		"on_gauges": {
			#"NATURE":will be changed everry turn
			"SATISFACTION": WeightChoice.randi_range(4,10)
			
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
	#6 - 12 months
	effect_duration = WeightChoice.randi_range(6, 12)
	var cost = WeightChoice.randi_range(150, 400)
	#will be payed once
	accept_effects['on_gauges']["BUDGET"] = cost
	description = (
		"Mayor, we suggest to conduct the city garbage sorting project."
		+ " Our initial investment will be "
		+ str(cost) + "K $."
		+ "This will certainly help us with garbage recycling."
		)
	monthyl_effects = {
		"on_gauges": {
			"NATURE": 1
		}
	}

func on_accepted(_scene_tree: SceneTree) -> void:
	.on_accepted(_scene_tree)
	for _month in range(1, effect_duration):
		yield(turn_controller, "turn_changed")
		gauge_controller.announce_gauges_diff(monthyl_effects.on_gauges)
		gauge_controller.apply_to_gauges(monthyl_effects.on_gauges)
