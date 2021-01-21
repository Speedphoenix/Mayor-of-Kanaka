#Long-term City greening, will increase HEALTH and NATURE gauges
extends DecisionSimple

var greening_duration : int

func _init():
	#on accept
	#every month city will spend some money to improve HEALTN & NATURE + SATISFACTION
	accept_effects = {
		"on_gauges": {
			#"BUDGET": added later in code
			"NATURE": rng.randi_range(1, 3),
			"HEALTH": rng.randi_range(1, 3),
			"SATISFACTION": rng.randi_range(0, 1) # may increase or not
			
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
	var monthly_cost = rng.randi_range(-15, -5)
	#Supposing it's a long term decision, the effects will take place for 12 to 36 months
	greening_duration = rng.randi_range(12, 36)
	description = ('Mayor, we suggest to launch a global city greening project in order to' 
		+ ' reduce cancer risk and imrpove overall the ecological situation.\n'
		+ 'This project will cost us ' + str(monthly_cost * -1)+ 'K $ per month.\n'
		+ 'The duration is estimated to ' + str(greening_duration) + ' month.')
	accept_effects['on_gauges']['BUDGET'] = monthly_cost

func on_accepted(scene_tree: SceneTree) -> void:
	for month in range(1, greening_duration):
		yield(turn_controller, "turn_changed")
		gauge_controller.apply_to_gauges(accept_effects.on_gauges)
