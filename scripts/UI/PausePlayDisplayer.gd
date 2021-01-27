extends CanvasLayer

onready var turn_controller := TurnController.get_turn_controller(get_tree())
export(Texture) var pause_icon
export(Texture) var play_icon

func _ready():
	turn_controller.connect("pause_changed", self, "_on_pause_changed")

func _on_PausePlayButton_toggled(button_pressed):
	if button_pressed:
		turn_controller.pause_turns()
	else:
		turn_controller.resume_turns()

func _on_pause_changed(pause_state: bool):
	if pause_state == true:
		$PausePlayIcon.texture = pause_icon
	else:
		$PausePlayIcon.texture = play_icon
