#Some regular small troubles like car accident, pipe broken etc...
extends DecisionSimple

var trouble_name := ['A pipe has been severed', 'A power outage has occurred', 'There has been a car accident']
export (Array, String) var street_name := [
	'Bukovski', 'Dupont', 'Smith', 'Bugaga', 'Sezam', 
	'Meisters', 'Wagner', 'Nihon', 'Chingpo',
]

func _init():
	#on accept
	#in case of city halls intervention we will spend money and raise citizens satisfction
	accept_effects = {
		"on_gauges": {
			#BUDGET is added in on_triggered
			"SATISFACTION": WeightChoice.randi_range(5, 15),
		},
	}
	#on decline
	#in case of refusing, satisfaction will go down
	refuse_or_expire_effects = {
		"on_gauges": {
			"SATISFACTION": WeightChoice.randi_range(-10, -7),
		},
	}

func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	#ex: Pipe broken
	title = WeightChoice.choose_random_from_array(trouble_name)
	#Amount of money to spent r repairs
	var work_cost = WeightChoice.randi_range(-60, -10)
	description = ('Mayor, trouble has occurred on '
		+ WeightChoice.choose_random_from_array(street_name) 
		+ ' Street.'
		+ ' The necessary intervention will cost ' + str(work_cost * -1) + 'K $')
	accept_effects['on_gauges']['BUDGET'] = work_cost
