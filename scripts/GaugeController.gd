class_name GaugeController
extends Node

# Emitted for every gauge that has changed
signal gauge_changed(gauge_name, new_value, old_value)

# Emittedd when the gauges change, and gives the full gauges everytime
# signal gauges_changed(new_gauges, old_gauges)

# Emitted when a new gauge is created
signal gauge_created(gauge_name, value)

signal expected_diff_changed(gauge_name, new_value)

export(bool) var emit_signal_on_identical_new_value = false

# This is set through the GameParameters
var _gauge_limits: Dictionary = {}

# These will generally be set through the game parameters
var _gauges: Dictionary = {
	"HEALTH": 50,
	"SATISFACTION": 50,
	"NATURE": 50,
	"STRESS": 50,
	"BUDGET": 50,
}

# Used for buffering the gauges, does not have use any limits
var _next_gauges_state := {}

# Note that this may be innacurate depending on which events have just resolved
var expected_next_turn_gauge_diff := {}

static func get_instance(scene_tree: SceneTree) -> GaugeController:
	# Not using GlobalObject.get_instance because cyclic reference
	return scene_tree.get_current_scene().get_node("GlobalObject/GaugeController") as GaugeController

func _ready():
	TurnController.get_instance(get_tree()).connect("turn_changed", self, "_on_turn_changed")

func _process(_delta):
	# idle_frame is triggered before _process is called on ever node.
	# This ensures the following code is run before or after everything else
	yield(get_tree(), "idle_frame")
	if !_next_gauges_state.empty():
		for name in _next_gauges_state:
			var old_value = _gauges[name]
			_set_gauge(name, _next_gauges_state[name])
			var new_value = _gauges[name]
			if emit_signal_on_identical_new_value || old_value != new_value:
				emit_signal("gauge_changed", name, new_value, old_value)
		_next_gauges_state.clear()

func gauge_exists(name: String) -> bool:
	return _gauges.has(name)

# TODO: handle if the gauge already exists
func create_gauge(name: String, initial_value: float = 0, limits := {}):
	_gauges[name] = initial_value
	if !limits.empty():
		_set_gauge_limits(name, limits)
	emit_signal("gauge_created", name, initial_value)

# limits should contain either "LOWER", "UPPER" or both
# Will emit a signal if the value of the gauge changed
func set_gauge_limits(name: String, limits: Dictionary) -> void:
	var old_value: float = _gauges[name]
	_set_gauge_limits(name, limits)
	var new_value: float = _gauges[name]
	if old_value != new_value:
		emit_signal("gauge_changed", name, new_value, old_value)

# limits should be a dictionary of the same type as _gauge_limits
func set_gauges_limits(limits: Dictionary):
	for name in limits:
		set_gauge_limits(name, limits[name])

func get_gauge(name: String) -> float:
	assert(name in _gauges)
	return _gauges[name]

# Returns the current gauges
# Warning: the modifying the returned dictionary will not change the values
# of the actual gauges
func get_gauges() -> Dictionary:
	return _gauges.duplicate()

# Sets gauge and emits the signal
func set_gauge(name: String, value: float) -> void:
	assert(name in _gauges)
	_next_gauges_state[name] = value

func apply_to_gauge(name: String, diff: float) -> void:
	assert(name in _gauges)
	if !(name in _next_gauges_state):
		_next_gauges_state[name] = _gauges[name]
	_next_gauges_state[name] += diff

func set_gauges(values: Dictionary) -> void:
	for gauge_name in values:
		set_gauge(gauge_name, values[gauge_name])

func apply_to_gauges(differences: Dictionary) -> void:
	for gauge_name in differences:
		apply_to_gauge(gauge_name, differences[gauge_name])

func announce_gauge_diff(name: String, diff: float) -> void:
	if is_equal_approx(diff, 0):
		return
	if !(name in expected_next_turn_gauge_diff):
		expected_next_turn_gauge_diff[name] = 0
	expected_next_turn_gauge_diff[name] += diff
	emit_signal("expected_diff_changed", name, expected_next_turn_gauge_diff[name])
	
func announce_gauges_diff(differences: Dictionary) -> void:
	for gauge_name in differences:
		announce_gauge_diff(gauge_name, differences[gauge_name])

func reset_expected_diffs() -> void:
	expected_next_turn_gauge_diff.clear()

func _on_turn_changed(_turn_number, _miniturn_number):
	reset_expected_diffs()

# Actually sets the gauge, without passing through the buffer,
# and applies the limits as well
func _set_gauge(name: String, value: float):
	_gauges[name] = value
	_apply_limits(name)

# limits should contain either "LOWER", "UPPER" or both
func _set_gauge_limits(name: String, limits: Dictionary) -> void:
	if !(name in _gauge_limits):
		_gauge_limits[name] = {}
	if "LOWER" in limits:
		_gauge_limits[name]["LOWER"] = limits["LOWER"]
	if "UPPER" in limits:
		_gauge_limits[name]["UPPER"] = limits["UPPER"]
	if "LOWER" in limits && "UPPER" in limits:
		assert(_gauge_limits[name]["UPPER"] >= _gauge_limits[name]["LOWER"])
		if _gauge_limits[name]["UPPER"] < _gauge_limits[name]["LOWER"]:
			_gauge_limits[name]["LOWER"] = _gauge_limits[name]["UPPER"]
		# assert only kills the execution in debug builds.
		# In production builds we want it to keep playing silently
	_apply_limits(name)

func _gauges_are_different(gauges1: Dictionary, gauges2: Dictionary):
	for el in gauges1:
		if gauges1[el] != gauges2[el]:
			return true
	return false

func _apply_limits(name: String):
	if _gauge_limits.has(name):
		if _gauge_limits[name].has("LOWER") && _gauges[name] < _gauge_limits[name].LOWER:
			_gauges[name] = _gauge_limits[name].LOWER
		if _gauge_limits[name].has("UPPER") && _gauges[name] > _gauge_limits[name].UPPER:
			_gauges[name] = _gauge_limits[name].UPPER
