class_name EventController
extends Node


# TODO: This whole script. right now it's mostly signatures, sometimes incomplete

# remember:
# if the number of miniturns left isn't enough, machine gun the events?
#	rather make variable probas depending on that

# TODO: make a robust next-event chooser:
#	So that we don't get them too many times in a row
#		Careful about ending up at the last turns of a game with many of the same!
#	So that new available ones are adde for infinite games

# Events to pop up on the screen right now
signal events_arrived
# Will expire next turn/miniturn
signal events_will_expire
signal events_expired


export(bool) var can_trigger_multiple_at_once = true
# Need abetter name for this
# Whether the game should aim to fulfill a certain amount of events per turn
# (count potentially result in machine gun events near the end of the turn)
export(bool) var should_fix_event_count_per_turn = true

var active_events: Array

var triggerable_events: Array

onready var global = get_tree().get_current_scene().get_node("GlobalObject")
onready var turnController = global.get_node("TurnController")


# An event that can be triggered.
# The event resource will be duplicated when the event is created
class ReadyEvent:
	var event_resource: BaseEvent
	
	# The turn number of the last time this event was triggered
	var last_trigger_turn := -1
	var last_trigger_miniturn := -1
	
	# The number of times this event has left to be triggered.
	# Use -1 for an even that does not have a trigger limit
	var remaing_triggers := -1
	var past_triggers_count := 0
	
	# How likely it should be to be triggered
	var weight := 1
	# Whether this should be triggered as soon as possible (rather than on a weight basis)
	var trigger_immediately := false
	
	# TODO: initialize the other vars
	func _init(from: BaseEvent):
		event_resource = from

# An event that has been instantiated and triggered.
# It might be active or closed
class OpenEvent:
	var event_resource: BaseEvent
	var remaining_turns: int
	
	func _init(from: ReadyEvent):
		event_resource = from.event_resource.duplicate()
		remaining_turns = event_resource.active_duration


func _ready():
	turnController.connect("miniturn_changed", self, "_on_miniturn_changed")
	turnController.connect("turn_changed", self, "_on_turn_changed")

func _on_miniturn_changed(turn_number, miniturn_number):
	pass

func _on_turn_changed(turn_number, miniturn_number):
	pass

# will (forcefully) generate an event next miniturn	(or as soon as possible)
func trigger_event():
	pass

func add_possible_event() -> ReadyEvent:
	return null

# remove from the bag of available potential events
func remove_possible_event():
	pass

# may remove these two, and replace with just resolve event
func accept_event():
	pass
func refuse_event():
	pass
