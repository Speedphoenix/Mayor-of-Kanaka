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
# The parameter is an array of BaseEvent resources
signal events_arrived(events)
# Will expire next turn/miniturn
signal events_will_expire(events)
signal events_expired(events)


# An array of TriggerableEvents
var triggerable_events: Array
# An array of TriggeredEvents
var active_events: Array
# An array of TriggeredEvents
# It contains every event that has been triggered so far, even those in active_events
var triggered_events: Array

# When a new turn/month starts, how many events can be triggered at once
export(bool) var max_events_per_turn_start = 1
export(bool) var max_events_per_miniturn = 1

# Need a better name for this
# Whether the game should aim to fulfill a certain amount of events per turn
# (count potentially result in machine gun events near the end of the turn)
# TODO:
# export(bool) var should_fix_event_count_per_turn = true

export(int) var events_per_turn = 3

onready var global = get_tree().get_current_scene().get_node("GlobalObject")
onready var turnController = global.get_node("TurnController")


# An event that can be triggered.
# The event resource will be duplicated when the event is created
class TriggerableEvent:
	var event_resource: BaseEvent
	
	# The turn number of the last time this event was triggered
	var last_trigger_turn := -1
	var last_trigger_miniturn := -1
	
	# The number of times this event has left to be triggered.
	# Use -1 for an even that does not have a trigger limit
	var remaing_triggers := -1
	var past_triggers_count := 0
	
	# How likely it should be to be triggered
	# WARNING: at the moment large weights might slow down the game
	var weight: int = 1
	# Whether this should be triggered as soon as possible (rather than on a weight basis)
	# 0 means false, positive numbers indicate how many times it should be triggered as sooon as possible
	var trigger_immediately := 0
	
	# TODO: initialize the other vars
	func _init(from: BaseEvent):
		event_resource = from

# An event that has been instantiated and triggered.
# It might be active or closed
class TriggeredEvent:
	var event_resource: BaseEvent
	var remaining_turns: int
	
	func _init(from: TriggerableEvent):
		event_resource = from.event_resource.duplicate()
		remaining_turns = event_resource.active_duration


func _ready():
	turnController.connect("miniturn_changed", self, "_on_miniturn_changed")
	turnController.connect("turn_changed", self, "_on_turn_changed")
	turnController.connect("turn_ended", self, "_on_turn_ended")

# returns an array of valid usable TriggerableEvents
# Note that multiple events could have the same reference
func getAvailableEvent(max_count: int = 1) -> Array:
	var possible_events := []
	var trigger_now := []
	for event in triggerable_events:
		if event.trigger_immediately != 0:
			trigger_now.append(event)
		elif event.remaing_triggers > 0 && event.weight > 0:
			for i in range(event.weight):
				possible_events.append(event)

	var rep := []
	var needmore := max_count
	trigger_now.shuffle()
	for event in trigger_now:
		if event.trigger_immediately >= needmore:
			for i in range(needmore):
				rep.append(event)
			needmore = 0
		else:
			for i in range(event.trigger_immediately):
				rep.append(event)
			needmore -= event.trigger_immediately
		if needmore == 0:
			break
	if needmore > 0:
		possible_events.shuffle()
		for event in possible_events:
			rep.append(event)
			needmore -= 1
			if needmore == 0:
				break
	return rep


func trigger_events(curr_turn_number: int, curr_miniturn_number: int, max_count: int = 1):
	var available_events = getAvailableEvent(max_count)
	if available_events.size() != 0:
		var to_send = []
		for event in available_events:
			var triggered = TriggeredEvent.new(event)
			to_send.append(triggered.event_resource)
			active_events.append(triggered)
			triggered_events.append(triggered)
			if event.trigger_immediately > 0:
				event.trigger_immediately -= 1
			# not using != -1 here because if we force trigger an event that is at 0,
			# It will end up at -1
			if event.remaing_triggers > 0:
				event.remaing_triggers -= 1
			event.past_triggers_count += 1
			event.last_trigger_turn = curr_turn_number
			event.last_trigger_miniturn = curr_miniturn_number
			triggered.event_resource.on_triggered(get_tree())
		emit_signal("events_arrived", to_send)

func expire_events(to_expire: Array):
	var expired_resources := []
	for event in to_expire:
		active_events.remove(active_events.find(event))
		expired_resources.append(event.event_resource)
		event.event_resource.on_expired(get_tree())
	emit_signal("events_expired", expired_resources)

func _on_miniturn_changed(turn_number, miniturn_number):
	# TODO: actually decide randomly, with checks or probabilities depending on
	# remaining turns and events to trigger
	if miniturn_number == 10 || miniturn_number == 20:
		trigger_events(turn_number, miniturn_number, max_events_per_miniturn)

func _on_turn_changed(turn_number: int, miniturn_number: int):
	var to_expire = []
	for event in active_events:
		event.remaining_turns -= 1
		if event.remaining_turns < 0:
			to_expire.append(event)
	if to_expire.size() != 0:
		expire_events(to_expire)
	trigger_events(turn_number, miniturn_number, max_events_per_turn_start)
	
func _on_turn_ended(turn_number: int, miniturn_number: int):
	var imminent = []
	for event in active_events:
		if event.remaining_turns == 0:
			imminent.append(event)
	if imminent.size() != 0:
		emit_signal("events_will_expire", imminent)

# returns the index of to_find in tab
func _find_by_event_resource(tab: Array, to_find: BaseEvent) -> int:
	for i in range(tab.size()):
		if tab[i].event_resource == to_find:
			return i
	return -1

# TODO:
# will (forcefully) generate an event next miniturn	(or as soon as possible)
func trigger_immediate_event():
	pass

# TODO:
func add_possible_event(base_event: BaseEvent) -> void:
	var new_event := TriggerableEvent.new(base_event)
	triggerable_events.append(new_event)

# TODO:
# remove from the bag of available potential events
func remove_possible_event():
	pass


func accept_event(base_event: BaseEvent):
	var index := _find_by_event_resource(active_events, base_event)
	active_events.remove(index)
	base_event.on_accepted(get_tree())

func refuse_event(base_event: BaseEvent):
	var index := _find_by_event_resource(active_events, base_event)
	active_events.remove(index)
	base_event.on_refused(get_tree())
