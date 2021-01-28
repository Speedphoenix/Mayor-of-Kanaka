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

# The random seed to use for this game
# (does not apply to random number generators used internally by the events)
export(int) var random_seed := 0

export(Array, Resource) var initial_possible_events = []

# Decides how many houses shall be present at the start of the game
# WARNING: using large values for this will make the game load noticeably slower
# Avoid putting values higher than 100 for games that will be first launched by the player
export(int) var initial_city_size := 1

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
	"HEALTH": PERCENT,
	"SATISFACTION": PERCENT,
	"NATURE": PERCENT,
	"STRESS": PERCENT,
}


func apply(scene_tree: SceneTree) -> void:
	var rnd_seed = random_seed if random_seed != 0 else randi()
	seed(rnd_seed)
	print("Using random seed ", rnd_seed)
	
	var event_controller := EventController.get_instance(scene_tree)
	var gauge_controller := GaugeController.get_instance(scene_tree)
	var population_controller := PopulationController.get_instance(scene_tree)
	
	# Applying intial possible events
	for event in initial_possible_events:
		event_controller.add_possible_event(event)
	
	# Applying initial gauges limits and values
	gauge_controller.set_gauges_limits(gauge_limits)
	gauge_controller.set_gauges(initial_gauges)
	
	# Instructions after this line rely on every node having had their _ready() called
	yield(scene_tree, "idle_frame")
	
	population_controller.add_random_houses(initial_city_size)

