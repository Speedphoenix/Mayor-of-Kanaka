#Dependable event
#Sitizen Unsatisfaction of city hall's activity/actions
extends DecisionSimple

func _init():
	#on accept
	#Mayor will do a public speach
	accept_effects = {
		"on_gauges": {
			"BUDGET": rng.randi_range(-300, -100),
			"SATISFACTION": rng.randi_range(10, 15),
			"STRESS": rng.randi_range(10, 15),
			},
	}
	
	#on decline
	#City hall does not react, satisfaction goes down, stress increrase
	refuse_or_expire_effects = {
		"on_gauges": {
		"SATISFACTION": rng.randi_range(-10, -5),
		"STRESS": rng.randi_range(-10, -5),
		},
	}
