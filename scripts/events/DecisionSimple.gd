class_name DecisionSimple
extends BaseEvent
# This has the basic functionality of an event, and is customizable
# should have an effect on the various gauges 

var accept_effects := {}

var refuse_or_expire_effects := {}

#var global_object: GlobalObject
var turn_controller: TurnController
var gauge_controller: GaugeController
var event_controller: EventController

func on_triggered(scene_tree: SceneTree) -> void:
#	global_object = GlobalObject.get_global_object(scene_tree)
	turn_controller = TurnController.get_turn_controller(scene_tree)
	gauge_controller = GaugeController.get_gauge_controller(scene_tree)
	event_controller = EventController.get_event_controller(scene_tree)

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
