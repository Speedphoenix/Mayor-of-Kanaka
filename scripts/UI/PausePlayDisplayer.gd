extends CanvasLayer

onready var turn_controller := TurnController.get_turn_controller(get_tree())

func _ready():
	pass # Replace with function body.

func _on_PausePlayButton_toggled(button_pressed):
	if(button_pressed):
		turn_controller.pause_turns()
	else:
		turn_controller.resume_turns()
