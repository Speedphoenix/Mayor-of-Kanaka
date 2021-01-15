class_name EventController
extends Node
# Controls the flow of event throughout a single game

# TODO: make a robust next-event chooser:
#	So that we don't get them too many miniturns in a row
#	So we don't get the same event many times in a row
#		Careful about ending up at the last turns of a game with many of the same!
# if the number of miniturns left isn't enough, machine gun the events?
#	or rather make variable probas depending on that

# Events to pop up on the screen right now
# The parameter is an array of BaseEvent resources
signal events_arrived(events)
# Will expire next turn/miniturn
signal events_will_expire(events)
signal events_expired(events)

# Emmitted anytime the list of currently active events changes
# This passes an array of TriggeredEvent (not BaseEvent)
signal active_events_changed(new_active_events)

# An array of TriggerableEvents
var triggerable_events: Array
# An array of TriggeredEvents
var active_events: Array
# An array of TriggeredEvents
# It contains every event that has been triggered so far, even those in active_events
var triggered_events: Array

# When a new turn/month starts, how many events can be triggered at once
export(int) var max_events_per_turn_start := 1
export(int) var max_events_per_miniturn := 1

# Need a better name for this
# Whether the game should aim to fulfill a certain amount of events per turn
# (count potentially result in machine gun events near the end of the turn)
# TODO:
# export(bool) var should_fix_event_count_per_turn = true

# maybe min & max events per turn?
export(int) var events_per_turn := 3

onready var turn_controller: TurnController = get_node("../TurnController")


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
	func _init(from: BaseEvent, use_weight := -1):
		event_resource = from
		if use_weight != -1:
			weight = use_weight
		else:
			weight = from.weight
		remaing_triggers = from.trigger_count

# An event that has been instantiated and triggered.
# It might be active or closed
class TriggeredEvent:
	var event_resource: BaseEvent
	var triggerable: TriggerableEvent
	var remaining_turns: int
	
	func _init(from: TriggerableEvent):
		event_resource = from.event_resource.duplicate()
		remaining_turns = event_resource.active_duration
		triggerable = from

static func get_event_controller(scene_tree: SceneTree) -> EventController:
	# Not using GlobalObject.get_global_object because cyclic reference
	return scene_tree.get_current_scene().get_node("GlobalObject/EventController") as EventController

func _ready():
	turn_controller.connect("miniturn_changed", self, "_on_miniturn_changed")
	turn_controller.connect("turn_changed", self, "_on_turn_changed")
	turn_controller.connect("turn_ended", self, "_on_turn_ended")

# returns an array of valid usable TriggerableEvents
# Note that multiple events could have the same reference
func _get_available_events(max_count: int = 1) -> Array:
	var possible_events := []
	var trigger_now := []
	for event in triggerable_events:
		if event.trigger_immediately != 0:
			trigger_now.append(event)
		elif (event.remaing_triggers == -1 || event.remaing_triggers > 0) && event.weight > 0:
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


func trigger_events(curr_turn_number: int, curr_miniturn_number: int, max_count: int = 1) -> void:
	var available_events = _get_available_events(max_count)
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
		emit_signal("active_events_changed", active_events.duplicate())


func _expire_events(to_expire: Array):
	var expired_resources := []
	for event in to_expire:
		active_events.remove(active_events.find(event))
		expired_resources.append(event.event_resource)
		event.event_resource.on_expired(get_tree())
	emit_signal("events_expired", expired_resources)
	emit_signal("active_events_changed", active_events.duplicate())

func _on_miniturn_changed(turn_number, miniturn_number):
	# TODO: actually decide randomly, with checks or probabilities depending on
	# remaining turns and events to trigger
	if miniturn_number == 10 || miniturn_number == 20:
		trigger_events(turn_number, miniturn_number, max_events_per_miniturn)

func _on_turn_changed(turn_number: int, miniturn_number: int):
	var to_expire := []
	for event in active_events:
		event.remaining_turns -= 1
		if event.remaining_turns < 0:
			to_expire.append(event)
	if to_expire.size() != 0:
		_expire_events(to_expire)
	trigger_events(turn_number, miniturn_number, max_events_per_turn_start)
	
func _on_turn_ended(turn_number: int, miniturn_number: int):
	var imminent := []
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


func get_triggerable_event(base_event: BaseEvent) -> TriggerableEvent:
	var index := _find_by_event_resource(triggerable_events, base_event)
	if index == -1:
		var index_triggered = _find_by_event_resource(triggered_events, base_event)
		if index_triggered == -1:
			return null
		else:
			return triggered_events[index_triggered].triggerable
	else:
		return triggerable_events[index]

# will trigger this event next miniturn (or as soon as possible)
#
# Note that if this will reset the trigger_immediately counter
func trigger_immediate_event(base_event: BaseEvent, trigger_count := 1) -> void:
	var triggerable := get_triggerable_event(base_event)
	if triggerable != null:
		triggerable.trigger_immediately = trigger_count

# Omit the weight argument or pass -1 to use the Event's default
func add_possible_event(base_event: BaseEvent, weight := -1) -> void:
	var new_event := TriggerableEvent.new(base_event, weight)
	triggerable_events.append(new_event)

func enable_or_add_possible_event(base_event: BaseEvent, weight := 1) -> void:
	var triggerable := get_triggerable_event(base_event)
	if triggerable == null:
		add_possible_event(base_event, weight)
	else:
		triggerable.weight = weight

# Will set the event's probability weight to zero
#
# An event without a positive weight value will not be used 
func disable_possible_event(base_event: BaseEvent) -> void:
	var triggerable := get_triggerable_event(base_event)
	if triggerable != null:
		triggerable.weight = 0

func accept_event(base_event: BaseEvent) -> void:
	var index := _find_by_event_resource(active_events, base_event)
	if index != -1:
		active_events.remove(index)
	base_event.on_accepted(get_tree())
	emit_signal("active_events_changed", active_events.duplicate())

func refuse_event(base_event: BaseEvent) -> void:
	var index := _find_by_event_resource(active_events, base_event)
	if index != -1:
		active_events.remove(index)
	base_event.on_refused(get_tree())
	emit_signal("active_events_changed", active_events.duplicate())
