extends CanvasLayer

export var eventID = 0

var previousEventID
var currentEvent
var events

func _ready():
	randomize()
	previousEventID = -1
	events = getEventsData()
	
func _process(delta):
	currentEvent = getCurrentEvent(events, eventID)
	var currentEventID = currentEvent["id"]
	# Refresh only if there is a new event to print
	if (currentEventID != previousEventID):
		printEventData()
	
	# Once the processing for an event is done, the previous event is now equal
	# the current one
	previousEventID = currentEventID 

func getEventsData():
	var data_file = File.new()
	if data_file.open("res://assets/events/events.json", File.READ) != OK:
		print("Error while loading the events file...")
		return
	var data_text = data_file.get_as_text()
	data_file.close()
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		return
	var data = data_parse.result
	return data
	
	
func getCurrentEvent(events, eventID):
	for eventKey in events:
		if (events[eventKey]["id"] == eventID):
			var event = events[eventKey]
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
