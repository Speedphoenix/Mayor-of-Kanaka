class_name GameStateController
extends Node

# Parameters are subject to change, but well...
signal game_ended(end_reason)

# TODO: Have the game parameters set this
export(float) var new_turn_budget_diff := 20

# Will trigger game over if one of the 4 main gauges falls to zero
export(bool) var end_on_empty_gauge := true

onready var turn_controller := TurnController.get_instance(get_tree())
onready var gauge_controller := GaugeController.get_instance(get_tree())

static func get_instance(scene_tree: SceneTree) -> GameStateController:
	return scene_tree.get_current_scene().get_node("GlobalObject/GameControllers/GameStateController") as GameStateController

func _ready():
	turn_controller.connect("turn_changed", self, "_on_turn_changed")
	gauge_controller.connect("gauge_changed", self, "_on_gauge_changed")

func _on_turn_changed(turn_number, miniturn_number):
	gauge_controller.apply_to_gauge("BUDGET", new_turn_budget_diff)

func _on_gauge_changed(gauge_name, new_value, old_value):
	match gauge_name:
		"HEALTH", "SATISFACTION", "NATURE":
			if new_value <= 0:
				emit_signal("game_ended", { "victory": false })
		"STRESS":
			if new_value >= 100:
				emit_signal("game_ended", { "victory": false })
