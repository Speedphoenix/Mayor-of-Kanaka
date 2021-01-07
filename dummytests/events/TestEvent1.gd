extends DecisionSimple
# This has the basic functionality of an event, and is customizable
# should have an effect on the various gauges 

func _init():
	print("I am test event 1")
	accept_effects = {
		"on_gauges": {
			"BUDGET": -15,
			"SATISFACTION": 10,
		},
	}
	refuse_or_expire_effects = {
		"on_gauges": {
			"SATISFACTION": -10,
			"HEALTH": -20,
		},
	}
