class_name DecisionSimple
extends BaseEvent
# This has the basic functionality of an event, and is customizable
# should have an effect on the various gauges 

var accept_effects := {}

var refuse_or_expire_effects := {}

var global_object: GlobalObject
var turn_controller: TurnController
var gauge_controller: GaugeController

func on_triggered(scene_tree: SceneTree) -> void:
	global_object = scene_tree.get_current_scene().get_node("GlobalObject")
	turn_controller = global_object.get_node("TurnController")
	gauge_controller = global_object.get_node("GaugeController")

func on_accepted(scene_tree: SceneTree) -> void:
	yield(turn_controller, "turn_changed")
	gauge_controller.apply_to_gauges(accept_effects.on_gauges)

func _apply_refuse_expire():
	yield(turn_controller, "turn_changed")
	gauge_controller.apply_to_gauges(refuse_or_expire_effects.on_gauges)

func on_refused(scene_tree: SceneTree) -> void:
	_apply_refuse_expire()

func on_expired(scene_tree: SceneTree) -> void:
	_apply_refuse_expire()
