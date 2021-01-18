extends CanvasLayer

export(bool) var draggable := false

onready var turn_controller := TurnController.get_turn_controller(get_tree())
onready var event_controller := EventController.get_event_controller(get_tree())
# the interface controller is the immediate parent node
onready var interface_controller : InterfaceController = get_parent()

# Event that has to be displayed and handled
var event: BaseEvent

# If an event is displayed, the time is freezed until the window is closed
var stop_time: bool = false

var hover_window: bool = false
var holding_window: bool = false

# Vector2 indicating where the mouse started dragging the event window
var mouse_start_position: Vector2
# Vector2 indicating the initial position and the start position of the window
var window_start_position: Vector2
var window_init_position: Vector2

func _ready():
	$SingleEventController.hide()
	window_start_position = $SingleEventController.rect_position
	window_init_position = $SingleEventController.rect_position
	event_controller.connect("events_arrived", self, "_on_events_arrived")
	interface_controller.connect("event_to_display", self, "_on_event_to_display")
	
func _process(_delta):
	#var _stop_time = stop_time
	#_handle_turns(_stop_time)
	# If the player presses the cancel button, the windows get closed
	if Input.is_action_pressed("ui_cancel"):
		close_window()
	
func _input(ev: InputEvent):
	if draggable == true:
		drag_and_drop_window(ev)
	
# An array of events as arrived and need to be displayed
func _on_events_arrived(events: Array):
	# We print only the first event of the array
	event = events[0]
	display_event()
	
func _on_event_to_display(ev: BaseEvent):
	event = ev
	display_event()

func display_event():
	if event != null:
		$SingleEventController/DescriptionController/Description.text = event.description
		$SingleEventController/TitleController/Title.text = event.title
		$SingleEventController.show()
		turn_controller.pause_turns()
		
func close_window():
	var Window = $SingleEventController
	Window.hide()
	# put the window back to its initial place
	Window.rect_position = window_init_position
	turn_controller.resume_turns()

# drag and drop the event window with the mouse based on the Window ColorRect selection
# TODO : improve the selection of the window (not based on background)
func drag_and_drop_window(ev: InputEvent):
	var Window = $SingleEventController
	
	if ev is InputEventMouseButton and ev.is_pressed() and hover_window == true:
		#print("Mouse Clicked at: ", ev.position)
		mouse_start_position = ev.position
		#print("mouse start : ", mouse_start_position)
		holding_window = true
		
	elif ev is InputEventMouseButton and !ev.is_pressed() and hover_window == true :
		#print("Mouse Unclicked at: ", ev.position)
		holding_window = false
		window_start_position = Window.rect_position
		
	elif ev is InputEventMouseMotion and holding_window == true:
		var mouse_current_position: Vector2 = ev.position
		var mouse_shifting: Vector2 =  mouse_current_position - mouse_start_position
		
		Window.rect_position = window_start_position + mouse_shifting
		window_start_position = Window.rect_position
		mouse_start_position = mouse_current_position

func _on_AcceptButton_pressed():
	if event != null:
		event_controller.accept_event(event)
		close_window()
	
func _on_RefuseButton_pressed():
	if event != null:
		event_controller.refuse_event(event)
		close_window()
	
func _on_HoldButton_pressed():
	close_window()
	
func _on_CloseButton_pressed():
	close_window()

func _on_Window_mouse_entered():
	hover_window = true
	
func _on_Window_mouse_exited():
	hover_window = false
