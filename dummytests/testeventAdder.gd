extends Node

export(Array, Resource) var events

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	print("oyy")
#	for event in events:
#		$"../GlobalObject/EventController".add_possible_event(event)
#	print($"../GlobalObject/EventController".triggerable_events.size())


func _on_EventController_events_arrived(_events: Array):
	pass
#	print("received an event!")
#	print(events[0].title)
