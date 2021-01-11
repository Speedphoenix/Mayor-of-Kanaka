extends CanvasLayer

var currentTurn: int

onready var global = get_tree().get_current_scene().get_node("GlobalObject")
onready var turn_controller: TurnController = global.get_node("TurnController")
onready var event_controller: EventController = global.get_node("EventController")

var active_events: Array = []
var previous_active_events: Array = []


func _ready():
	turn_controller.connect("miniturn_changed", self, "_on_anyturn_changed")
	turn_controller.connect("turn_changed", self, "_on_anyturn_changed")
	
	currentTurn = turn_controller.current_turn_no
	$NextTurnController/CurrentTurnLabel.text =  str(currentTurn)

# TODO : get a signal from the event controller to know when the active events are changed
# To not refresh the list every frame but at every change of events in the list
func _process(_delta):
	active_events = event_controller.active_events
	#print(active_events)
	if(active_events != previous_active_events):
		_clear_previous_active_events()
		_display_eventslist(active_events)
		previous_active_events = active_events.duplicate()
	
func _display_eventslist(events: Array):
	var eventsCounter = 0
	for ev in active_events:
			if ev is EventController.TriggeredEvent:
				eventsCounter += 1
				if eventsCounter <= 5 :
					var event = ev.event_resource
					var eventTitle = event.title
					var detailMenuController = $EventDetailsController/DetailsMenuController
					
					var controller = Control.new()
					controller.name = "Controller" + String(eventsCounter)
					controller.margin_left = 40
					controller.margin_top = 100 + (eventsCounter * 45)
					
					var background = ColorRect.new()
					background.name = "background" + String(eventsCounter)
					background.margin_right = 175
					background.margin_bottom = 35
					background.color = Color("531919")
					
					var button = Button.new()
					background.name = "button" + String(eventsCounter)
					button.flat = true
					button.text = eventTitle
					button.margin_right = 175
					button.margin_bottom = 35
					
					button.connect("pressed", self, "_on_eventButton_pressed", [event])
					
					controller.add_child(background)
					controller.add_child(button)
					detailMenuController.add_child(controller)

# clear and free the graphical nodes used for active events
func _clear_previous_active_events():
	var detailMenuController = $EventDetailsController/DetailsMenuController
	var background = $EventDetailsController/DetailsMenuController/Background
	var backgroundBorder = $EventDetailsController/DetailsMenuController/BackgroundBorder
	for n in detailMenuController.get_children():
		if (n != background && n != backgroundBorder):
			detailMenuController.remove_child(n)
			n.queue_free()

func _on_anyturn_changed(turn_number, miniturn_number):
	$NextTurnController/CurrentTurnLabel.text =  str(turn_number) + "m " +  str(miniturn_number) + "d" 

func _on_EventDetailsButton_toggled(button_pressed: bool):
	if(button_pressed):
		$EventDetailsController/DetailsMenuController.show()
	else:
		$EventDetailsController/DetailsMenuController.hide()
	
func _on_eventButton_pressed(event: BaseEvent):
	event_controller.event_to_display(event)
