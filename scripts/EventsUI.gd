extends CanvasLayer

signal close

export var currentEventID = 0

var previousEventID
var currentEvent
var events

func _ready():
	previousEventID = -1
	var Global = get_node("/root/Global")
	events = Global.events
	
func _process(_delta):
	currentEvent = getCurrentEvent(events, currentEventID)
	# Refresh only if there is a new event to print
	if (currentEventID != previousEventID):
		printEventData()
	
	previousEventID = currentEventID 
	
func getCurrentEvent(allEvents, eventID):
	for eventKey in allEvents:
		if (allEvents[eventKey]["id"] == eventID):
			var event = allEvents[eventKey]
			return event
	
	# if we did not find the event, return the default event
	var defaultEvent = events["0"]
	return defaultEvent
	
func printEventData():
	$SingleEventController/TitleController/Title.text = currentEvent["title"]
	$SingleEventController/DescriptionController/Description.text = currentEvent["description"]

func _on_AcceptButton_pressed():
	print("You accepted the event : ", currentEvent["title"])

func _on_RefuseButton_pressed():
	print("You refused the event : ", currentEvent["title"])

func _on_HoldButton_pressed():
	print("You put on hold the event : ", currentEvent["title"])

func _on_CloseButton_pressed():
	print("You closed the event : ", currentEvent["title"])
	emit_signal("close")
	
func _on_eventChanged(eventID):
	currentEventID = eventID
