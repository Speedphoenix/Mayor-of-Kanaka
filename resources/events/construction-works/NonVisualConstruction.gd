# Some construction works not illustrated on the main city map:
# Basically we are paying a reasonable amount of money per month and get some bonuses for it
# Ex: upgrading the electricity network 
extends DecisionSimple

#will generate a random number 
var rng = RandomNumberGenerator.new()

var event_title_description = [['Water supply system'], ['Water filtering system'],
	['Electricity delivery system'], ['Electricity consumption policies']]

func _init():
	#on accept
	#city spends money for some preventive measures in order to soften crisis consequences
	accept_effects = {
		"on_gauges": {
			#BUDGET is added in on_triggered
			"SATISFACTION": rng.randi_range(5,15),
		},
	}
	
	#on decline
	#no preventive measures taken, crisis strikes at it's full strength
	refuse_or_expire_effects = {
		"on_gauges": {
			"SATISFACTION": rng.randi_range(-15,-10),
		},
	}
	
func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	#ex: Hurricane Incomming !!!
	title = trouble_name[rng.randi_range(0,trouble_name.size()-1)] + ' Incomming!!!'
	#Amount of money to spent if we want to softeh crisis concsequences
	var work_cost = rng.randi_range(-100,-20)
	
	description = ('Mayor, a troubble has occured on ' 
		+ street_name[rng.randi_range(0,street_name.size()-1)] + ' Street.'
		+ 'The necessary intervention will cost' + str(work_cost * -1) + ' $')
	accept_effects['on_gauges']['BUDGET'] = work_cost
