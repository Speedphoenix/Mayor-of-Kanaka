extends BaseEvent


# Called when the event is created, before the player has interracted with it
func on_triggered(scene_tree: SceneTree) -> void:
	print("testevent2 triggered")

func on_accepted(scene_tree: SceneTree) -> void:
	print("testevent2 accepted")
	
func on_refused(scene_tree: SceneTree) -> void:
	print("testevent2 refused")

func on_expired(scene_tree: SceneTree) -> void:
	print("oh no testevent2 expired")
