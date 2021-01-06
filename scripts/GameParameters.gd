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

func apply(scene_tree: SceneTree) -> void:
	var global_object = scene_tree.get_current_scene().get_node("GlobalObject")
	var event_controller = global_object.get_node("EventController")
	for event in initial_possible_events:
		event_controller.add_possible_event(event)
