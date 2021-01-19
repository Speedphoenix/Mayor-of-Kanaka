extends BaseEvent

export(int) var how_much_to_kill = 5

# Called when the event is created, before the player has interracted with it
func on_triggered(scene_tree: SceneTree) -> void:
#	print("testevent2 triggered")
	pass

func on_accepted(scene_tree: SceneTree) -> void:
	var global_object = scene_tree.get_current_scene().get_node("GlobalObject")
	var turn_controller = global_object.get_node("TurnController")
	var gauge_controller: GaugeController = global_object.get_node("GaugeController")
	
	print("testevent2 accepted")
	
	yield(turn_controller, "turn_changed")
	gauge_controller.apply_to_gauge("HEALTH", how_much_to_kill)
	yield(turn_controller, "turn_changed")
	
	
func on_refused(scene_tree: SceneTree) -> void:
#	print("testevent2 refused")
	pass

func on_expired(scene_tree: SceneTree) -> void:
	pass
#	print("oh no testevent2 expired")
