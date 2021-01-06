class_name DecisionSimple
extends BaseEvent
# This has the basic functionality of an event, and is customizable
# should have an effect on the various gauges 

var accept_effects := []

var refuse_or_expire_effects := []

var globalObject: Node
var turnController: Node

func _accepted_on_turn_changed(turn_number: int, miniturn_number: int):
	for effect in accept_effects:
		globalObject.bars[effect.on_bar] += effect.value
	turnController.disconnect("turn_changed", self, "_accepted_on_turn_changed")

func _refused_on_turn_changed(turn_number: int, miniturn_number: int):
	for effect in refuse_or_expire_effects:
		globalObject.bars[effect.on_bar] += effect.value
	turnController.disconnect("turn_changed", self, "_refused_on_turn_changed")

func on_triggered(scene_tree: SceneTree) -> void:
	globalObject = scene_tree.get_current_scene().get_node("GlobalObject")
	turnController = globalObject.get_node("TurnController")

func on_accepted(scene_tree: SceneTree) -> void:
	turnController.connect("turn_changed", self, "_accepted_on_turn_changed")

func on_refused(scene_tree: SceneTree) -> void:
	turnController.connect("turn_changed", self, "_refused_on_turn_changed")

func on_expired(scene_tree: SceneTree) -> void:
	turnController.connect("turn_changed", self, "_refused_on_turn_changed")
