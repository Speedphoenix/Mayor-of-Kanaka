extends CanvasLayer

onready var event_controller := EventController.get_event_controller(get_tree())
# the interface controller is the immediate parent node
onready var interface_controller : InterfaceController = get_parent()

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
	var eventListContainer = $EventDetailsController/DetailsMenuController/ScrollContainer/MarginContainer/EventListContainer
	for ev in active_events:
		if ev is EventController.TriggeredEvent:
			eventsCounter += 1
			var event = ev.event_resource
			var eventTitle = event.title

			var marginContainer = MarginContainer.new()
			marginContainer.name = "MarginContainer" + str(eventsCounter)
			
			var background = ColorRect.new()
			background.name = "Background" + str(eventsCounter)
			background.color = Color("531919")
			background.rect_min_size.x = 200
			background.rect_min_size.y = 35
			
			var button = Button.new()
			button.name = "Button" + str(eventsCounter)
			button.flat = true
			var text_to_display = eventTitle
			if text_to_display.length() > 20:
				text_to_display = text_to_display.substr(0, 20) + "..."
			button.text = text_to_display
			button.connect("pressed", self, "_on_eventButton_pressed", [event])
			
			# TODO : get rid of this pseudo-whitespace
			var whitespace = Control.new()
			whitespace.rect_min_size.y = 3
			
			marginContainer.add_child(background)
			marginContainer.add_child(button)
			eventListContainer.add_child(whitespace)
			
			eventListContainer.add_child(marginContainer)
			

# clear and free the graphical nodes used for active events
func _clear_previous_active_events():
	var eventListContainer = $EventDetailsController/DetailsMenuController/ScrollContainer/MarginContainer/EventListContainer
	for n in eventListContainer.get_children():
		eventListContainer.remove_child(n)
		n.queue_free()

func _on_EventDetailsButton_toggled(button_pressed: bool):
	if(button_pressed):
		$EventDetailsController/DetailsMenuController.show()
	else:
		$EventDetailsController/DetailsMenuController.hide()
	
func _on_eventButton_pressed(event: BaseEvent):
	interface_controller.event_to_display(event)
