extends DecisionSimple
# This has the basic functionality of an event, and is customizable
# should have an effect on the various gauges

func _init():
	accept_effects = [
		{
			"on_bar" : "BUDGET",
			"value": -15,
		},
		{
			"on_bar" : "SATISFACTION",
			"value": 10,
		},
	]
	refuse_or_expire_effects = [
		{
			"on_bar" : "SATISFACTION",
			"value": -10,
		},
		{
			"on_bar" : "HEALTH",
			"value": -20,
		},
	]
