#Natural Catastrophies
extends DecisionSimple

#will generate a random number 
var rng = RandomNumberGenerator.new()

var catastrophy_name := ['Hurricane', 'Tsunami', 'Earthquake', 'Flood']

func _init():
	#on accept
	#city spends money for some preventive measures in order to soften crisis consequences
	accept_effects = {
		"on_gauges": {
			#BUDGET is added in on_triggered
			"STRESS": rng.randi_range(-5,0),
			"SATISFACTION": rng.randi_range(5,15),
		},
	}
	
	#on decline
	#no preventive measures taken, crisis strikes at it's full strength
	refuse_or_expire_effects = {
		"on_gauges": {
			"STRESS": rng.randi_range(-15,-10),
			"SATISFACTION": rng.randi_range(-15,-10),
			"BUDGET": rng.randi_range(-1000,-100),
		},
	}
	
func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	#ex: Hurricane Incomming !!!
	title = catastrophy_name[rng.randi_range(0,catastrophy_name.size()-1)] + ' Incomming!!!'
	#Amount of money to spent if we want to softeh crisis concsequences
	var preventive_measures_cost = rng.randi_range(-1000,-100)
	
	description = ('Nature is rebelling, Mayor. We must act immiditealy, or face unpleasant consequences.'
		+ 'It will cost ' + str(preventive_measures_cost * -1) + '$ for the city budget.' 
		+ ' Economic damage yet is unknown.')
		
	accept_effects['on_gauges']['BUDGET'] = preventive_measures_cost
