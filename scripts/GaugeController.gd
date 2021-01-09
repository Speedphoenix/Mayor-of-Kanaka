class_name GaugeController
extends Node

# Emitted for every gauge that has changed
signal gauge_changed(gauge_name, new_value, old_value)

# Emittedd when the gauges change, and gives the full gauges everytime
# signal gauges_changed(new_gauges, old_gauges)

# Emitted when a new gauge is created
# TODO:
signal gauge_created(gauge_name, value)

export(bool) var emit_signal_on_identical_new_value = false

# This is set through the GameParameters
var gauge_limits: Dictionary = {
	"BUDGET": {
		"LOWER": 0,
		"UPPER": 10000,
	}
}

# These will generally be set through the game parameters
var _gauges: Dictionary = {
	"HEALTH": 50,
	"SATISFACTION": 50,
	"NATURE": 50,
	"STRESS": 50,
	"BUDGET": 50,
}


func _gauges_are_different(gauges1: Dictionary, gauges2: Dictionary):
	for el in gauges1:
		if gauges1[el] != gauges2[el]:
			return true
	return false

func _apply_limits(name: String) -> int:
	if gauge_limits.has(name):
		if gauge_limits[name].has("LOWER") && _gauges[name] < gauge_limits[name].LOWER:
			_gauges[name] = gauge_limits[name].LOWER
		if gauge_limits[name].has("UPPER") && _gauges[name] < gauge_limits[name].UPPER:
			_gauges[name] = gauge_limits[name].UPPER
	return _gauges[name]

# limits should contain either "LOWER", "UPPER" or both
func set_gauge_limits(name: String, limits: Dictionary) -> void:
	if !(name in gauge_limits):
		gauge_limits[name] = {}
	if "LOWER" in limits:
		gauge_limits[name]["LOWER"] = limits["LOWER"]
	if "UPPER" in limits:
		gauge_limits[name]["UPPER"] = limits["UPPER"]
	assert(gauge_limits[name]["UPPER"] >= gauge_limits[name]["LOWER"])

# limits should be a dictionary of the same type as gauge_limits
func set_gauges_limits(limits: Dictionary):
	for name in limits:
		set_gauge_limits(name, limits[name])

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
	var new_value = _apply_limits(name)
	if emit_signal_on_identical_new_value || old_value != new_value:
		emit_signal("gauge_changed", name, new_value, old_value)

func apply_to_gauge(name: String, diff: int) -> void:
	assert(name in _gauges)
	set_gauge(name, _gauges[name] + diff)

func set_gauges(values: Dictionary) -> void:
	for gauge_name in values:
		set_gauge(gauge_name, values[gauge_name])

func apply_to_gauges(differences: Dictionary) -> void:
	for gauge_name in differences:
		apply_to_gauge(gauge_name, differences[gauge_name])
