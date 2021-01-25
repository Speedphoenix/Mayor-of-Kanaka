#Some regular small troubles like car accident, pipe broken etc...
extends DecisionSimple

var trouble_name := ['A pipe has been severed', 'A power outage has occurred', 'There has been a car accident']
export (Array, String) var street_name := ['Bukovski', 'Dupont', 'Smith', 'Bugaga', 'Sezam', 
'Meisters', 'Wagner', 'Nihon', 'Chingpo']

func _init():
	#on accept
	#in case of city halls intervention we will spend money and raise citizens satisfction
	accept_effects = {
		"on_gauges": {
			#BUDGET is added in on_triggered
			"SATISFACTION": rng.randi_range(5, 15),
		},
	}
	
	#on decline
	#in case of refusing, satisfaction will go down
	refuse_or_expire_effects = {
		"on_gauges": {
			"SATISFACTION": rng.randi_range(-15, -10),
		},
	}
	
func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	
	#ex: Pipe broken
	title = trouble_name[rng.randi_range(0, trouble_name.size() - 1)]
	#Amount of money to spent r repairs
	var work_cost = rng.randi_range(-100, -20)
	
	description = ('Mayor, a trouble has occurred on '
		+ street_name[rng.randi_range(0,street_name.size() - 1)] + ' Street.'
		+ ' The necessary intervention will cost ' + str(work_cost * -1) + 'K $')
	accept_effects['on_gauges']['BUDGET'] = work_cost
