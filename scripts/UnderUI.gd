extends CanvasLayer

signal nextTurn
signal eventToDisplay(eventID)

onready var currentTurn
onready var eventsList

# Called when the node enters the scene tree for the first time.
func _ready():
	var Global = get_node("/root/Global")
	currentTurn = Global.currentTurn
	$NextTurnController/CurrentTurnLabel.text =  String(currentTurn)

func _on_NextTurnButton_pressed():
	var currentTurnText = int($NextTurnController/CurrentTurnLabel.text)
	var newCurrentTurn = currentTurnText + 1
	$NextTurnController/CurrentTurnLabel.text =  String(newCurrentTurn)
	$EventDetailsController/DetailsMenuController.hide()
	var Global = get_node("/root/Global")
	Global.currentTurn += 1
	emit_signal("nextTurn")


func _on_EventDetailsButton_toggled(button_pressed):
	if(button_pressed):
		var Global = get_node("/root/Global")
		eventsList = Global.eventsList
		var eventCounter = 0
		for event in eventsList:
			eventCounter += 1
			if eventCounter <= 5 :
				var eventTitle = event["title"]
				var eventID = event["id"]
				var detailMenuController = $EventDetailsController/DetailsMenuController
				
				var controller = Control.new()
				controller.name = "Controller" + String(eventCounter)
				controller.margin_left = 40
				controller.margin_top = 100 + (eventCounter * 45)
				
				var background = ColorRect.new()
				background.name = "background" + String(eventCounter)
				background.margin_right = 175
				background.margin_bottom = 35
				background.color = Color("531919")
				
				var button = Button.new()
				background.name = "button" + String(eventCounter)
				button.flat = true
				button.text = eventTitle
				button.margin_right = 175
				button.margin_bottom = 35
				
				button.connect("pressed", self, "_on_eventButton_pressed", [eventID])
				
				controller.add_child(background)
				controller.add_child(button)
				detailMenuController.add_child(controller)
			
		$EventDetailsController/DetailsMenuController.show()
	else:
		var detailMenuController = $EventDetailsController/DetailsMenuController
		var background = $EventDetailsController/DetailsMenuController/Background
		var backgroundBorder = $EventDetailsController/DetailsMenuController/BackgroundBorder
		for n in detailMenuController.get_children():
			if (n != background && n != backgroundBorder):
				detailMenuController.remove_child(n)
				n.queue_free()
		$EventDetailsController/DetailsMenuController.hide()


func _on_eventButton_pressed(eventID):
	#print("Event ID to be displayed : ", eventID)
	emit_signal("eventToDisplay", eventID)


func _on_event_accepted(event):
	var Global = get_node("/root/Global")
	eventsList = Global.eventsList
	#var eventID = event["id"]
	eventsList.erase(event)
	Global.eventsList = eventsList
	$EventDetailsController/DetailsMenuController.hide()


func _on_event_refused(event):
	var Global = get_node("/root/Global")
	eventsList = Global.eventsList
	#var eventID = event["id"]
	eventsList.erase(event)
	Global.eventsList = eventsList
	$EventDetailsController/DetailsMenuController.hide()
