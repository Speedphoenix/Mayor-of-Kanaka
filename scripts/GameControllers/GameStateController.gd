class_name GameStateController
extends Node

# Parameters are subject to change, but well...
signal game_ended(end_reason)

var new_turn_diffs := {
	"BUDGET": 20
}

# Will trigger game over if one of the 4 main gauges falls to zero
export(bool) var end_on_empty_gauge := true

# If set to false (through the game parameters),
# a gauge reaching critical values will not trigger game_ended
var game_can_end := true

onready var turn_controller := TurnController.get_instance(get_tree())
onready var gauge_controller := GaugeController.get_instance(get_tree())

static func get_instance(scene_tree: SceneTree) -> GameStateController:
	return scene_tree.get_current_scene().get_node("GlobalObject/GameControllers/GameStateController") as GameStateController

func _ready():
	turn_controller.connect("turn_changed", self, "_on_turn_changed")
	gauge_controller.connect("gauge_changed", self, "_on_gauge_changed")

func _on_turn_changed(_turn_number, _miniturn_number):
	gauge_controller.apply_to_gauges(new_turn_diffs)

func _on_gauge_changed(gauge_name, new_value, _old_value):
	if !game_can_end:
		return
	match gauge_name:
		"HEALTH", "SATISFACTION", "NATURE":
			if new_value <= 0:
				emit_signal("game_ended", { "victory": false })
		"STRESS":
			if new_value >= 100:
				emit_signal("game_ended", { "victory": false })
