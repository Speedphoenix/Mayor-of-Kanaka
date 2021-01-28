class_name EventNonInteractive
extends BaseEvent

# TODO: Make this a list of possible answers, and one is picked randomly
export(String) var dismiss_msg := "I understand now"

var turn_controller: TurnController
var gauge_controller: GaugeController
var event_controller: EventController

func on_triggered(scene_tree: SceneTree) -> void:
	turn_controller = TurnController.get_instance(scene_tree)
	gauge_controller = GaugeController.get_instance(scene_tree)
	event_controller = EventController.get_instance(scene_tree)

func on_accepted(_scene_tree: SceneTree) -> void:
	pass
