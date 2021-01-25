#Will suggest to finance civil solar panel installation in the city
extends DecisionSimple

func _init():
	#on accept
	accept_effects = {
		"on_gauges": {
			#"BUDGET": added later in code
			"NATURE": rng.randi_range(1, 2),
			"SATISFACTION": rng.randi_range(1, 2) # may increase or not
		},
	}
	#on decline
	#no visible effects
	refuse_or_expire_effects = {
		"on_gauges": {
		},
	}
