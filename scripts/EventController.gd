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

# Emitted when a possible triggerable event is added
# This DOES NOT mean any event was triggered
# This is triggered even if the new triggerable event has a weight of 0
signal new_triggerable_event_added(new_triggerable)

# TODO: rename to "on turn start" and "on miniturn"
# When a new turn/month starts, how many events can be triggered at once
export(int) var events_per_turn_start := 1
export(int) var max_events_per_miniturn := 1

# Put a value greater than 30 to wait until the second month
# Use -1 to disable, and randomly have events at any time
var day_of_first_event := 10

# note that manually triggering events with trigger_events() may bring triggered events over the limit
var max_events_per_turn := 6
var target_events_per_turn := 3
var min_events_per_turn := 2

# If this is set to true, events will only be triggered on days 10 and 20
export(bool) var use_dumb_event_generation := false

var current_turn_event_count: int = 0

# An array of TriggerableEvents
var triggerable_events: Array
# An array of TriggeredEvents
var active_events: Array
# An array of TriggeredEvents
# It contains every event that has been triggered so far, even those in active_events
var triggered_events: Array

onready var turn_controller: TurnController = TurnController.get_instance(get_tree())


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

static func get_instance(scene_tree: SceneTree) -> EventController:
	# Not using GlobalObject.get_instance because cyclic reference
	return scene_tree.get_current_scene().get_node("GlobalObject/EventController") as EventController

func _ready():
	assert(max_events_per_turn >= target_events_per_turn)
	assert(target_events_per_turn >= min_events_per_turn)
	assert(events_per_turn_start <= max_events_per_turn)
	current_turn_event_count = 0
	turn_controller.connect("miniturn_changed", self, "_on_miniturn_changed")
	turn_controller.connect("turn_changed", self, "_on_turn_changed")
	turn_controller.connect("turn_ended", self, "_on_turn_ended")

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
	emit_signal("new_triggerable_event_added", new_event)

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

# Will randomly trigger events
func trigger_events(max_count: int = 1) -> void:
	var available_events: Array = _get_available_events(max_count)
	var curr_turn_number: int = turn_controller.current_turn_no
	var curr_miniturn_number: int = turn_controller.current_miniturn_no
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
		current_turn_event_count += to_send.size()
		emit_signal("events_arrived", to_send)
		emit_signal("active_events_changed", active_events.duplicate())


func _pending_immediate_event_count() -> int:
	var rep := 0
	for event in triggerable_events:
		if event.trigger_immediately != 0:
			rep += 1
	return rep

# returns an array of valid usable TriggerableEvents
# Note that multiple events could have the same reference
func _get_available_events(max_count: int = 1) -> Array:
	var possible_events := []
	var trigger_now := []
	for event in triggerable_events:
		if event.trigger_immediately != 0:
			trigger_now.append(event)
		elif event.remaing_triggers == -1 || event.remaing_triggers > 0:
			possible_events.append(event)

	var rep := []
	var needmore := max_count
	trigger_now.shuffle()
	for event in trigger_now:
		if event.trigger_immediately >= needmore:
			for _i in range(needmore):
				rep.append(event)
			needmore = 0
		else:
			for _i in range(event.trigger_immediately):
				rep.append(event)
			needmore -= event.trigger_immediately
		if needmore == 0:
			break
	if needmore > 0 && !possible_events.empty():
		var possible_weights := WeightChoice.get_weights_from_dicts(possible_events)
		var chosen_possibles := WeightChoice.choose_by_weight(possible_weights, needmore)
		for chosen_index in chosen_possibles:
			rep.append(possible_events[chosen_index])
	return rep

func _expire_events(to_expire: Array):
	var expired_resources := []
	for event in to_expire:
		active_events.remove(active_events.find(event))
		expired_resources.append(event.event_resource)
		event.event_resource.on_expired(get_tree())
	emit_signal("events_expired", expired_resources)
	emit_signal("active_events_changed", active_events.duplicate())

func _should_trigger_miniturn_event(turn_number, miniturn_number: int) -> int:
	if use_dumb_event_generation && miniturn_number in [10, 20]:
		return 1
	var days_in_a_month := turn_controller.days_in_a_month
	var day_count = turn_number * days_in_a_month + miniturn_number
	if day_of_first_event != -1 && day_count <= day_of_first_event:
		if day_count < day_of_first_event:
			return 0
		if day_count == day_of_first_event:
			return 1
	if miniturn_number <= 1:
		return 0
	var pending_immediate: int = _pending_immediate_event_count()
	var max_remaining_events: int = max_events_per_turn - current_turn_event_count
	if pending_immediate > 0:
		return int(clamp(pending_immediate, 0, max_events_per_miniturn))
	if max_remaining_events <= 0:
		return 0
	
	# + 1 because miniturn number counts from 1 to 30, not 0 to 29
	var remaining_days: int = days_in_a_month - miniturn_number + 1
	var avg_event_at_once: float = float(target_events_per_turn - events_per_turn_start) / (float(max_events_per_miniturn + 1) / 2)
	var target_proba: float = avg_event_at_once / days_in_a_month
	
	if remaining_days * max_events_per_miniturn <= min_events_per_turn - current_turn_event_count:
		return max_events_per_miniturn
	
	if randf() <= target_proba:
		var count_ceiling = max_events_per_miniturn if max_events_per_miniturn < max_remaining_events else max_remaining_events
		return WeightChoice.randi_range(1, count_ceiling)
	return 0

func _on_miniturn_changed(turn_number: int, miniturn_number: int):
	var new_event_count = _should_trigger_miniturn_event(turn_number, miniturn_number)
	if new_event_count > 0:
		trigger_events(new_event_count)

func _on_turn_changed(_turn_number: int, _miniturn_number: int):
	current_turn_event_count = 0
	var to_expire := []
	for event in active_events:
		event.remaining_turns -= 1
		if event.remaining_turns < 0:
			to_expire.append(event)
	if to_expire.size() != 0:
		_expire_events(to_expire)
	trigger_events(events_per_turn_start)
	
func _on_turn_ended(_turn_number: int, _miniturn_number: int):
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

