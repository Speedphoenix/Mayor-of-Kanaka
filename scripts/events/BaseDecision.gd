extends BaseEvent

class_name BaseDecision

export(String) var accept_msg := "Accept!"
export(String) var refuse_msg := "Refuse!"

func on_accepted() -> void:
	pass
	
func on_refused() -> void:
	pass

func on_expired() -> void:
	pass
