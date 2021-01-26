class_name TurnController
extends Node

# Note that if it gets paused, on resume will wait the whole time, not just what was remaining

signal miniturn_changed(turn_number, miniturn_number)

# Sent when a turn ends, but before the turn_changed
# turn_number is the number of the turn that is ending
signal turn_ended(turn_number, miniturn_number)

# Sent after turn_ended, when the new turn is in effect
# turn_number is the number of the new turn
signal turn_changed(turn_number, miniturn_number)

# Sent if the pause state has changed
signal pause_changed(pause_state)

# A miniturn is a 'day', the intermediary turns inside a 'month' (a full 'turn')
export var days_in_a_month: int = 30
export var inter_miniturn_delay := 0.7
export var inter_turn_delay := 2.0
export var trigger_first_miniturn: bool = false
export var is_paused := false

# Do we count from 1 or from 0? or something else?
export var FIRST_MINITURN_NUMBER := 1

var current_turn_no := 0
var current_miniturn_no := FIRST_MINITURN_NUMBER
var _turn_timer: Timer
var _miniturn_timer: Timer

static func get_turn_controller(scene_tree: SceneTree) -> TurnController:
	# Not using GlobalObject.get_global_object because cyclic reference
	return scene_tree.get_current_scene().get_node("GlobalObject/TurnController") as TurnController

# Called when the node enters the scene tree for the first time.
func _ready():
	_miniturn_timer = Timer.new()
	add_child(_miniturn_timer)
	_miniturn_timer.wait_time = inter_miniturn_delay
	_miniturn_timer.one_shot = true # We may need to stop it often
	_miniturn_timer.connect("timeout", self, "on_miniturn_timeout")
	_turn_timer = Timer.new()
	add_child(_turn_timer)
	_turn_timer.wait_time = inter_turn_delay
	_turn_timer.one_shot = true # We may need to stop it often
	_turn_timer.connect("timeout", self, "on_turn_timeout")
	launch_next_timers()
	
# prevent memory leak
func _exit_tree():
	for n in get_children():
		self.remove_child(n)
		n.queue_free()

func launch_next_timers():
	if current_miniturn_no >= days_in_a_month:
		_turn_timer.start()
		trigger_end_turn()
	else:
		_miniturn_timer.start()

func on_miniturn_timeout():
	current_miniturn_no += 1
	launch_next_timers()
	trigger_next_miniturn()

func on_turn_timeout():
	current_turn_no += 1
	current_miniturn_no = FIRST_MINITURN_NUMBER
	launch_next_timers()
	trigger_next_turn()

func trigger_next_miniturn():
	emit_signal("miniturn_changed", current_turn_no, current_miniturn_no)

func trigger_end_turn():
	emit_signal("turn_ended", current_turn_no, current_miniturn_no)

func trigger_next_turn():
	emit_signal("turn_changed", current_turn_no, current_miniturn_no)
	if trigger_first_miniturn:
		trigger_next_miniturn()

func pause_turns():
	_turn_timer.stop()
	_miniturn_timer.stop()
	is_paused = true
	emit_signal("pause_changed", is_paused)


# This will also reset the time left to next turn
func resume_turns(force_timer_reset: bool = false):
	if !is_paused && !force_timer_reset:
		return
	is_paused = false
	launch_next_timers()
	emit_signal("pause_changed", is_paused)
	
