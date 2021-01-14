class_name GameParameters
extends Resource
# A resource to contain all parameters defining a game 
#
# This should contain elements that are specific to the current game
# For example:
# - The initial possible events
# - The initial size of the city
# - The difficulty level, if it applies
# - The initial state of the gauges

export(Array, Resource) var initial_possible_events = []

export(Dictionary) var initial_gauges := {
	"HEALTH": 50,
	"SATISFACTION": 50,
	"NATURE": 50,
	"STRESS": 50,
	"BUDGET": 100,
}

const PERCENT := {
	"LOWER": 0,
	"UPPER": 100,
}
export(Dictionary) var gauge_limits: Dictionary = {
	"BUDGET": {
		"LOWER": 0,
	},
	"HEALTH": PERCENT,
	"SATISFACTION": PERCENT,
	"NATURE": PERCENT,
	"STRESS": PERCENT,
}


func apply(scene_tree: SceneTree) -> void:
	var event_controller := EventController.get_event_controller(scene_tree)
	var gauge_controller := GaugeController.get_gauge_controller(scene_tree)
	
	# Applying intial possible events
	for event in initial_possible_events:
		event_controller.add_possible_event(event)
	
	# Applying initial gauges limits and values
	gauge_controller.set_gauges_limits(gauge_limits)
	gauge_controller.set_gauges(initial_gauges)
