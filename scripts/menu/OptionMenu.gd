extends Control

signal CloseOptionsMenu


func _enter_tree():
	if get_parent().filename == "res://scenes/menu/GameMenu.tscn":
		set_size(Vector2(600,360))
		set_position(Vector2(100,50))
	if get_parent().filename == "res://scenes/menu/PauseMenu.tscn":
		set_size(Vector2(600,360))
		set_position(Vector2(0,0))

func _on_Exit_pressed():
	emit_signal("CloseOptionsMenu")
	

func _on_HowToPlay_pressed():
	var how_to_play = load("res://scenes/menu/HowToPlay.tscn").instance()
	add_child(how_to_play)
	get_node("HowToPlay").connect("CloseHowToPlay", self, "CloseHowToPlay")

func CloseHowToPlay():
	get_node("HowToPlay").queue_free()


func _on_SoundEffects_pressed():
	pass # Replace with function body.
	

func _on_Music_pressed():
	pass # Replace with function body.

func _on_Credits_pressed():
	var credits = load("res://scenes/menu/Credits.tscn").instance()
	add_child(credits)
	get_node("Credits").connect("CloseCredits", self, "CloseCredits")

func CloseCredits():
	get_node("Credits").queue_free()

