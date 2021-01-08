class_name GaugeController
extends Node

# Emitted for every gauge that has changed
signal gauge_changed(gauge_name, new_value, old_value)

# Emittedd when the gauges change, and gives the full gauges everytime
signal gauges_changed(new_gauges, old_gauges)

# TODO check for illegal values on setting the gauges

export(bool) var emit_signal_on_identical_new_value = false

export(int) var lower_gauge_limit := 0

# This enum is currently not in use
enum Gauges {HEALTH, SATISFACTION, NATURE, STRESS, BUDGET}

# This may be added to the GameParameters as well
export(Dictionary) var gauge_limits: Dictionary = {
	"HEALTH": 100,
	"SATISFACTION": 100,
	"NATURE": 100,
	"STRESS": 100,
	"BUDGET": 10000,
}

# These will generally be set through the game parameters
var _gauges: Dictionary = {
	"HEALTH": 50,
	"SATISFACTION": 50,
	"NATURE": 50,
	"STRESS": 50,
	"BUDGET": 50,
}


func _ready():
	pass
	# TODO: assert here that every element of the gauge has a limit
	# and every element of the limits has a gauge

func _gauges_are_different(gauges1: Dictionary, gauges2: Dictionary):
	for el in gauges1:
		if gauges1[el] != gauges2[el]:
			return true
	return false

func get_gauge(name: String) -> int:
	assert(name in _gauges)
	return _gauges[name]

# Returns the current gauges
# Warning: the modifying the returned dictionary will not change the values
# of the actual gauges
func get_gauges() -> Dictionary:
	return _gauges.duplicate()

# Sets gauge and emits the signal
func set_gauge(name: String, value: int) -> void:
	assert(name in _gauges)
	var old_value = _gauges[name]
	_gauges[name] = value
	if emit_signal_on_identical_new_value || old_value != value:
		emit_signal("gauge_changed", name, _gauges[name], old_value)

func set_gauges(values: Dictionary, send_signal := true) -> void:
	var old_values = _gauges.duplicate()
	for gauge_name in values:
		set_gauge(gauge_name, values[gauge_name])
	if ((emit_signal_on_identical_new_value
		|| _gauges_are_different(old_values, _gauges))
		&& send_signal):
		emit_signal("gauges_changed", _gauges, old_values)

func apply_to_gauge(name: String, diff: int) -> void:
	assert(name in _gauges)
	var old_value = _gauges[name]
	_gauges[name] += diff
	if _gauges[name] > gauge_limits[name]:
		_gauges[name] = gauge_limits[name]
	if _gauges[name] < lower_gauge_limit:
		_gauges[name] = 0
	if emit_signal_on_identical_new_value || _gauges[name] != old_value:
		emit_signal("gauge_changed", name, _gauges[name], old_value)

func apply_to_gauges(differences: Dictionary) -> void:
	var old_values = _gauges.duplicate()
	for gauge_name in differences:
		apply_to_gauge(gauge_name, differences[gauge_name])
	if emit_signal_on_identical_new_value || _gauges_are_different(old_values, _gauges):
		emit_signal("gauges_changed", _gauges, old_values)
