class_name BaseEvent
extends Resource


# There are two types of possible events, decisions an non interactive events
# Both of those will inherit BaseEvent

export(String) var title: String
export(String, MULTILINE) var description: String

# 0 means it will expire at the end of the current turn
export(int) var active_duration: int = 0

# This could be 'open letter' or 'dismiss letter' for example
export(String) var accept_msg := "Accept"
export(String) var refuse_msg := "Refuse"

# These functions should be overridden

# Called when the event is created, before the player has interracted with it
func on_triggered(scene_tree: SceneTree) -> void:
	pass

func on_accepted(scene_tree: SceneTree) -> void:
	pass
	
func on_refused(scene_tree: SceneTree) -> void:
	pass

func on_expired(scene_tree: SceneTree) -> void:
	pass
