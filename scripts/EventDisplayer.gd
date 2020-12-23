extends Control

signal eventChanged(eventID)

var devmode
var events

onready var global = get_tree().get_current_scene().get_node("GlobalObject")
onready var turnController = global.get_node("TurnController")

func _ready():
	devmode = global.devmode
	events = global.events
	
	turnController.connect("miniturn_changed", self, "_on_miniturn_changed")
	turnController.connect("turn_changed", self, "_on_turn_changed")
	
	$EventsUIController/EventsUI.get_child(0).hide()
	initSelector()
	if(devmode == true):
		$CreateEventButton.show()
		$EventIDSelector.show()

func _process(_delta):
	pass

func getRandomEvent(allEvents):
	randomize()
	var eventsIDlist = []
	for eventKey in allEvents:
		if(allEvents[eventKey]["id"] != 0):
			eventsIDlist.append(allEvents[eventKey]["id"])
		
	eventsIDlist.shuffle()
	var randomID = eventsIDlist[0]
	
	for eventKey in allEvents:
		if (allEvents[eventKey]["id"] == randomID):
			var event = allEvents[eventKey]
			return event

func addRandomEvent():
	var eventsList = global.eventsList
	var randomEvent = getRandomEvent(events)
	eventsList.append(randomEvent)

func initSelector():
	$EventIDSelector.add_item("Earthquake", 1)
	$EventIDSelector.add_item("School", 2)
	$EventIDSelector.add_item("Chaos", 3)

func _on_CreateEventButton_pressed():
	var eventID = $EventIDSelector.get_item_id($EventIDSelector.selected)
	#print("eventID to be printed :", eventID)
	emit_signal("eventChanged", eventID)
	$EventsUIController/EventsUI.get_child(0).show()

func _on_nextTurn():
	pass
#	var eventsList = global.eventsList
#
#	var randomEvent = getRandomEvent(events)
#	eventsList.append(randomEvent)

func _on_miniturn_changed(turn_number, miniturn_number):
	if miniturn_number == 10 || miniturn_number == 20:
		addRandomEvent()

func _on_turn_changed(turn_number, miniturn_number):
	addRandomEvent()
	addRandomEvent()
	

func _on_eventToDisplay(eventID):
	#print("Need to display event ID: ", eventID)
	emit_signal("eventChanged", eventID)
	turnController.pause_turns()
	$EventsUIController/EventsUI.get_child(0).show()
	
func _on_EventsUI_close():
	$EventsUIController/EventsUI.get_child(0).hide()
	turnController.resume_turns()
