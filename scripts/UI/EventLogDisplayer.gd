extends CanvasLayer

onready var event_controller := EventController.get_event_controller(get_tree())

var active_events: Array = []
var previous_active_events: Array = []

func _ready():
	$EventDetailsController/DetailsMenuController.hide()
	$EventDetailsController/EventCounterController.hide()

# TODO : get a signal from the event controller to know when the active events are changed
# To not refresh the list every frame but at every change of events in the list
func _process(_delta):
	active_events = event_controller.active_events
	if(active_events != previous_active_events):
		_clear_previous_active_events()
		_display_eventslist(active_events)
		previous_active_events = active_events.duplicate()
		
	#If we have one or more events that are active, we display the active event counter
	if(active_events.size() >= 1):
		$EventDetailsController/EventCounterController.show()
		var CounterLabel = $EventDetailsController/EventCounterController/CounterLabel
		CounterLabel.text = str(active_events.size())
	else:
		$EventDetailsController/EventCounterController.hide()
	
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
	var frame = $EventDetailsController/DetailsMenuController/Frame
	for n in detailMenuController.get_children():
		if (n != background && n != frame):
			detailMenuController.remove_child(n)
			n.queue_free()

func _on_EventDetailsButton_toggled(button_pressed: bool):
	if(button_pressed):
		$EventDetailsController/DetailsMenuController.show()
	else:
		$EventDetailsController/DetailsMenuController.hide()
	
func _on_eventButton_pressed(event: BaseEvent):
	event_controller.event_to_display(event)
