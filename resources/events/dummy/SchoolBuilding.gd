extends DecisionSimple
# This has the basic functionality of an event, and is customizable
# should have an effect on the various gauges

func _init():
	accept_effects = {
		"on_gauges": {
			"BUDGET": -10,
			"SATISFACTION": 20,
		},
	}
	refuse_or_expire_effects = {
		"on_gauges": {
			"SATISFACTION": -10,
			"HEALTH": -5,
		},
	}
