extends BaseEvent

class_name EventNonInteractive

# TODO: Make this a list of possible answers, and one is picked randomly
export(String) var dismiss_msg := "I understand now"

func on_dismissed() -> void:
	pass
