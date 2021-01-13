extends DecisionSimple

#will generate a random number to chose event's title/description from an array
var rng = RandomNumberGenerator.new()

var trouble_name := ['Pipe broken', 'Electricity cut', 'Car accident']
export (Array, String) var street_name := ['Bukovski', 'Dupont', 'Smith', 'Bugaga', 'Sezam', 
'Meisters', 'Wagner', 'Nihon', 'Chingpo']

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
