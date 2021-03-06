#Natural Catastrophies
extends DecisionSimple

var catastrophy_title := [
	'A hurricane has been sighted',
	'A tsunami is incoming',
	'An earthquake will hit the city',
	'A flood is expected soon',
]

func _init():
	#on accept
	#city spends money for some preventive measures in order to soften crisis consequences
	accept_effects = {
		"on_gauges": {
			#BUDGET is added in on_triggered
			"STRESS": WeightChoice.randi_range(-5, 0),
			"SATISFACTION": WeightChoice.randi_range(5, 15),
		},
	}
	#on decline
	#no preventive measures taken, crisis strikes at it's full strength
	refuse_or_expire_effects = {
		"on_gauges": {
			"STRESS": WeightChoice.randi_range(2, 5),
			"SATISFACTION": WeightChoice.randi_range(-10, -5),
			"BUDGET": WeightChoice.randi_range(-1000, -100),
		},
	}

func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	#ex: Hurricane Incomming !!!
	title = WeightChoice.choose_random_from_array(catastrophy_title)
	#Amount of money to spent if we want to softeh crisis concsequences
	var preventive_measures_cost = WeightChoice.randi_range(-400, -100)
	description = ('Nature is rebelling, Mayor. We must act immediately, or face unpleasant consequences.\n'
		+ 'It would cost ' + str(preventive_measures_cost * -1) + 'K $ on the city budget.' 
		+ ' The economic damage is yet unknown.')
	accept_effects['on_gauges']['BUDGET'] = preventive_measures_cost
