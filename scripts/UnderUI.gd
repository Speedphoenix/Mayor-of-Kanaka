extends CanvasLayer

signal nextTurn
signal eventToDisplay(eventID)

var currentTurn
var eventsList

onready var global = get_tree().get_current_scene().get_node("GlobalObject")
onready var turnController = global.get_node("TurnController")

# Called when the node enters the scene tree for the first time.
func _ready():
	turnController.connect("miniturn_changed", self, "_on_anyturn_changed")
	turnController.connect("turn_changed", self, "_on_anyturn_changed")
	currentTurn = global.currentTurn
	$NextTurnController/CurrentTurnLabel.text =  str(currentTurn)

func _on_NextTurnButton_pressed():
	pass
#	var currentTurnText = int($NextTurnController/CurrentTurnLabel.text)
#	var newCurrentTurn = currentTurnText + 1
#	$NextTurnController/CurrentTurnLabel.text =  String(newCurrentTurn)
#	$EventDetailsController/DetailsMenuController.hide()
#	global.currentTurn += 1
#	emit_signal("nextTurn")

func _on_anyturn_changed(turn_number, miniturn_number):
	$NextTurnController/CurrentTurnLabel.text =  str(turn_number) + "m " +  str(miniturn_number) + "d" 

func _on_EventDetailsButton_toggled(button_pressed):
	if(button_pressed):
		eventsList = global.eventsList
		var eventCounter = 0
		for event in eventsList:
			eventCounter += 1
			if eventCounter <= 5 :
				var eventTitle = event["title"]
				var eventID = event["id"]
				var detailMenuController = $EventDetailsController/DetailsMenuController
				
				var controller = Control.new()
				controller.name = "Controller" + str(eventCounter)
				controller.margin_left = 40
				controller.margin_top = 100 + (eventCounter * 45)
				
				var background = ColorRect.new()
				background.name = "background" + str(eventCounter)
				background.margin_right = 175
				background.margin_bottom = 35
				background.color = Color("531919")
				
				var button = Button.new()
				background.name = "button" + str(eventCounter)
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
	eventsList = global.eventsList
	#var eventID = event["id"]
	eventsList.erase(event)
	global.eventsList = eventsList
	$EventDetailsController/DetailsMenuController.hide()


func _on_event_refused(event):
	eventsList = global.eventsList
	#var eventID = event["id"]
	eventsList.erase(event)
	global.eventsList = eventsList
	$EventDetailsController/DetailsMenuController.hide()
