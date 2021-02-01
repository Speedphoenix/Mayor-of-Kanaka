extends CanvasLayer

export(bool) var draggable := false

onready var turn_controller := TurnController.get_instance(get_tree())
onready var event_controller := EventController.get_instance(get_tree())
onready var music_controller := MusicController.get_instance(get_tree())
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
	$SingleEventController/ButtonsController/DecisionButtons.hide()
	$SingleEventController/ButtonsController/NonInteractiveButtons.hide()
	
	window_start_position = $SingleEventController.rect_position
	window_init_position = $SingleEventController.rect_position
# warning-ignore:return_value_discarded
	event_controller.connect("events_arrived", self, "_on_events_arrived")
# warning-ignore:return_value_discarded
	interface_controller.connect("event_to_display", self, "_on_event_to_display")
	
func _process(_delta):
	if Input.is_action_pressed("ui_cancel"):
		close_window()
	
func _input(ev: InputEvent):
	if draggable == true:
		drag_and_drop_window(ev)
	
# An array of events as arrived and need to be displayed
func _on_events_arrived(events: Array):
	event = events[0]
	display_event()
	
func _on_event_to_display(ev: BaseEvent):
	event = ev
	display_event()

func display_event():
	if event != null:
		var Window = $SingleEventController
		# put the window back to its initial place
		Window.rect_position = window_init_position
		$SingleEventController/DescriptionController/Description.text = event.description
		$SingleEventController/TitleController/Title.text = event.title
		
		# If the event is Non Interactive, there is just a button to accept it
		# else it is just a regular event, both accept and refuse button are visible 
		var DecisionButtons = $SingleEventController/ButtonsController/DecisionButtons
		var NonInteractiveButtons = $SingleEventController/ButtonsController/NonInteractiveButtons
		if event is EventNonInteractive:
			DecisionButtons.hide()
			NonInteractiveButtons.show()
			NonInteractiveButtons.change_non_interactive_label(event.dismiss_msg)
		else:
			NonInteractiveButtons.hide()
			DecisionButtons.show()
			DecisionButtons.change_accept_label(event.accept_msg)
			DecisionButtons.change_refuse_label(event.refuse_msg)
			
		# stop time
		turn_controller.pause_turns()
		remaining_time_label()
		
		#play the sound effect music
		music_controller.play_event_sound_effect()
		
		$SingleEventController.show()
		

# Set the label of the remaining time in days
func remaining_time_label():
	var remaining_days_label := $SingleEventController/RemainingTimeController/RemainingDaysLabel
	var _days_in_a_month := turn_controller.days_in_a_month
	var _current_miniturn := turn_controller.current_miniturn_no
	var event_remaining_turns := event.active_duration
	# remaining time in days
	var remaining_time = _days_in_a_month * event_remaining_turns + (_days_in_a_month - _current_miniturn)
	if remaining_time > 1:
		remaining_days_label.text = str(remaining_time) + " days"
	else:
		remaining_days_label.text = str(remaining_time) + " day"
	#Add funky font color relative to the remaining time
	var color: Color = Color.white
	if remaining_time <= 30:
		color = Color(0.8, 0.2, 0)
	elif remaining_time <= 60:
		color = Color(0.8, 0.45, 0)
	else:
		color = Color(0.45, 0.8, 0)
	remaining_days_label.set("custom_colors/default_color", color)

func close_window():
	var Window = $SingleEventController
	Window.hide()
	# put the window back to its initial place
	Window.rect_position = window_init_position
	# end holding the window
	holding_window = false
	turn_controller.resume_turns()

# drag and drop the event window with the mouse based on the Window ColorRect selection
# TODO : improve the selection of the window (not based on background)
func drag_and_drop_window(ev: InputEvent):
	var Window = $SingleEventController
	
	if ev is InputEventMouseButton and ev.is_pressed() and hover_window == true:
		mouse_start_position = ev.position
		window_start_position = Window.rect_position
		holding_window = true
		
	elif ev is InputEventMouseButton and !ev.is_pressed() and hover_window == true :
		holding_window = false
		
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

func _on_CloseButton_pressed():
	close_window()

func _on_Window_mouse_entered():
	hover_window = true
	
func _on_Window_mouse_exited():
	hover_window = false
