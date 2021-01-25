extends Control

signal CloseCredits

func _on_Exit_pressed():
	emit_signal("CloseCredits")
