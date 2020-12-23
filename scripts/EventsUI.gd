extends CanvasLayer

signal close
signal accepted(event)
signal refused(event)
signal onHold(event)

export var currentEventID = 0

var previousEventID
var currentEvent
onready var events


func _ready():
	previousEventID = -1
	var global = get_tree().get_current_scene().get_node("GlobalObject")
	events = global.events
	
func _process(_delta):
	currentEvent = getEvent(events, currentEventID)
	# Refresh only if there is a new event to print
	if (currentEventID != previousEventID):
		printEventData()
	
	previousEventID = currentEventID 
	
func getEvent(allEvents, eventID):
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
	emit_signal("accepted", currentEvent)
	emit_signal("close")

func _on_RefuseButton_pressed():
	print("You refused the event : ", currentEvent["title"])
	emit_signal("refused", currentEvent)
	emit_signal("close")

func _on_HoldButton_pressed():
	print("You put on hold the event : ", currentEvent["title"])
	emit_signal("onHold", currentEvent)
	emit_signal("close")

func _on_CloseButton_pressed():
	print("You closed the event : ", currentEvent["title"])
	emit_signal("close")
	
func _on_eventChanged(eventID):
	currentEventID = eventID

