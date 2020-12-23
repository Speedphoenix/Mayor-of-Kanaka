extends Node

# TODO: This whole script. right now it's mostly signatures, sometimes incomplete

# remember:
# if the number of miniturns left isn't enough, ignore the probabilities
#	rather make variable probas depending on that

# TODO: make a robust next-event chooser:
#	So that we don't get them too many times in a row
#		Careful about ending up at the last turns of a game with many of the same!
#	So that new available ones are adde for infinite games

signal events_arrived
# Will expire next turn/miniturn
signal events_will_expire
signal events_expired

export(bool) var can_trigger_multiple_at_once = true


# the elements of these arrays should indicate stuff like
# their weight in terms of probability
# if it can trigger multiplel times, it should indicate stuff like
# - how recent the last one was
# - how many can be/have been triggered
# - whether it should be triggered as soon as possible or not
var active_events: Array

var triggerable_events: Array

func _ready():
	pass

# will (forcefully) generate an event next miniturn	(or as soon as possible)
func trigger_event():
	pass

func add_possible_event():
	pass

# remove from the bag of available potential events
func remove_possible_event():
	pass

# may remove these two, and replace with just resolve event
func accept_event():
	pass
func refuse_event():
	pass
