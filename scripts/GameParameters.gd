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

# note that manually triggering events with trigger_events()
# may bring the triggered event count over the limit
export(int) var max_events_per_turn := 6
export(int) var target_events_per_turn := 3
export(int) var min_events_per_turn := 2

# Put a value greater than 30 to wait until the second month
# Use -1 to disable, and randomly have events at any time
export(int) var day_of_first_event := 10

# The random seed to use for this game
# (does not apply to random number generators used internally by the events)
export(int) var random_seed := 0

export(bool) var game_can_end := true

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
export(Dictionary) var new_turn_diffs := {
	"BUDGET": 50,
}


func apply(scene_tree: SceneTree) -> void:
	var rnd_seed = random_seed if random_seed != 0 else randi()
	seed(rnd_seed)
	print("Using random seed ", rnd_seed)
	
	var event_controller := EventController.get_instance(scene_tree)
	var gauge_controller := GaugeController.get_instance(scene_tree)
	var population_controller := PopulationController.get_instance(scene_tree)
	var game_state_controller := GameStateController.get_instance(scene_tree)
	
	event_controller.target_events_per_turn = self.target_events_per_turn
	event_controller.max_events_per_turn = self.max_events_per_turn
	event_controller.min_events_per_turn = self.min_events_per_turn
	event_controller.day_of_first_event = self.day_of_first_event
	
	# Applying intial possible events
	for event in initial_possible_events:
		event_controller.add_possible_event(event)
	
	# Applying initial gauges limits and values
	gauge_controller.set_gauges_limits(gauge_limits)
	gauge_controller.set_gauges(initial_gauges, true)
	
	game_state_controller.game_can_end = self.game_can_end
	game_state_controller.new_turn_diffs = self.new_turn_diffs
	
	# Instructions after this line rely on every node having had their _ready() called
	yield(scene_tree, "idle_frame")
	
	population_controller.add_random_houses(initial_city_size)

