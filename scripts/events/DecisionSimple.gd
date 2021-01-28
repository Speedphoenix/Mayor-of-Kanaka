class_name DecisionSimple
extends BaseEvent
# This has the basic functionality of an event, and is customizable
# should have an effect on the various gauges 

var accept_effects := {}

var refuse_or_expire_effects := {}

var turn_controller: TurnController
var gauge_controller: GaugeController
var event_controller: EventController

func on_triggered(scene_tree: SceneTree) -> void:
	turn_controller = TurnController.get_instance(scene_tree)
	gauge_controller = GaugeController.get_instance(scene_tree)
	event_controller = EventController.get_instance(scene_tree)

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

func budget_check():
	if(accept_effects['on_gauges']['BUDGET'] && accept_effects['on_gauges']['BUDGET'] < 0):
		if(accept_effects['on_gauges']['BUDGET'] * -1 >= gauge_controller.get_gauge("BUDGET")):
			return false
	return true
