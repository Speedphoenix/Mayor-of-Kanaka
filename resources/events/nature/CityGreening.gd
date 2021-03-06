#Long-term City greening, will increase HEALTH and NATURE gauges
extends DecisionSimple

var greening_duration : int

func _init():
	#on accept
	#every month city will spend some money to improve HEALTN & NATURE + SATISFACTION
	accept_effects = {
		"on_gauges": {
			#"BUDGET": added later in code
			"NATURE": WeightChoice.randi_range(1, 3),
			"HEALTH": WeightChoice.randi_range(1, 3),
			"SATISFACTION": WeightChoice.randi_range(0, 1) # may increase or not
			
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
	var monthly_cost = WeightChoice.randi_range(-15, -5)
	#Supposing it's a long term decision, the effects will take place for 12 to 36 months
	greening_duration = WeightChoice.randi_range(12, 36)
	description = ('Mayor, we suggest to launch a global city greening project in order to' 
		+ ' reduce cancer risks and improve the overall ecological situation.\n'
		+ 'This project will cost us ' + str(monthly_cost * -1) + 'K $ per month.\n'
		+ 'It is estimated to last ' + str(greening_duration) + ' months.')
	accept_effects['on_gauges']['BUDGET'] = monthly_cost

func on_accepted(_scene_tree: SceneTree) -> void:
	for _month in range(1, greening_duration):
		yield(turn_controller, "turn_changed")
		gauge_controller.announce_gauges_diff(accept_effects.on_gauges)
		gauge_controller.apply_to_gauges(accept_effects.on_gauges)
