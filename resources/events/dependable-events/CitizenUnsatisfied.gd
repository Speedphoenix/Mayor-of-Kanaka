#Dependable event
#Sitizen Unsatisfaction of city hall's activity/actions
extends DecisionSimple

func _init():
	#on accept
	#Mayor will do a public speach
	accept_effects = {
		"on_gauges": {
			"BUDGET": WeightChoice.randi_range(-30, -10),
			"SATISFACTION": WeightChoice.randi_range(7, 12),
			"STRESS": WeightChoice.randi_range(-10, -5),
			},
	}
	#on decline
	#City hall does not react, satisfaction goes down, stress increrase
	refuse_or_expire_effects = {
		"on_gauges": {
		"SATISFACTION": WeightChoice.randi_range(-10, -5),
		"STRESS": WeightChoice.randi_range(5, 7),
		},
	}
