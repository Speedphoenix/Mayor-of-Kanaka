class_name EventNonInteractive
extends BaseEvent

# TODO: Make this a list of possible answers, and one is picked randomly
export(String) var dismiss_msg := "I understand now"

func on_accepted(scene_tree: SceneTree) -> void:
	pass
