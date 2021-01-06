class_name DecisionSimple
extends BaseEvent
# This has the basic functionality of an event, and is customizable
# should have an effect on the various gauges 

var accept_effects := []

var refuse_or_expire_effects := []

var global_object: Node
var turn_controller: Node

func on_triggered(scene_tree: SceneTree) -> void:
	global_object = scene_tree.get_current_scene().get_node("GlobalObject")
	turn_controller = global_object.get_node("TurnController")

func on_accepted(scene_tree: SceneTree) -> void:
	yield(turn_controller, "turn_changed")
	for effect in accept_effects:
		global_object.bars[effect.on_bar] += effect.value

func _apply_refuse_expire():
	yield(turn_controller, "turn_changed")
	for effect in refuse_or_expire_effects:
		global_object.bars[effect.on_bar] += effect.value

func on_refused(scene_tree: SceneTree) -> void:
	_apply_refuse_expire()

func on_expired(scene_tree: SceneTree) -> void:
	_apply_refuse_expire()
