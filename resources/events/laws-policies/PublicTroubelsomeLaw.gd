#This event generates an unpopular public law preserving nature/ecology
extends DecisionSimple

#will generate a random number to chose event's title/description from an array
var rng = RandomNumberGenerator.new()


export(Array,Array,String) var possible_title_and_description := [['Curfew', 'Citizens mobility is limited between 8PM and 6AM' ],
	['Limitating CO2 Emissions', 'Only vehicles having \'pair\' numbers are allowed to move in the city (concerns only civil private transport)']]

func _init():
	#Budget< (city s spending some money on the laws) 
	#Stress> (people r ucomfortable) 
	#Nature> (laws preserving nature/ecology) 
	#Satisfaction< (people unsatisfied with governments policies)
	accept_effects = {
		"on_gauges": {
			"BUDGET": rng.randi_range(-60, -25),
			"STRESS": rng.randi_range(5, 20),
			"NATURE": rng.randi_range(10, 20),
			"SATISFACTION": rng.randi_range(-10, -5),
		},
	}
	
	#on decline
	# Nature< (no preserving laws in action)
	refuse_or_expire_effects = {
		"on_gauges": {
			"NATURE": rng.randi_range(-20, -10),
		},
	}
func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	
	rng.randomize()
	var name_desc_chooser = rng.randi_range(0, possible_title_and_description.size() - 1)
	title = possible_title_and_description[name_desc_chooser][0]
	description = possible_title_and_description[name_desc_chooser][1]
