extends Control


signal CloseHowToPlay

func _on_Exit_pressed():
	emit_signal("CloseHowToPlay")
