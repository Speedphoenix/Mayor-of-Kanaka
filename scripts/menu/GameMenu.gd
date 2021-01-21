extends Control

const mainscene = preload("res://scenes/MainScene.tscn")

func _on_Options_pressed():
	var option_menu = load("res://scenes/menu/OptionMenu.tscn").instance()
	add_child(option_menu)
	get_node("OptionMenu").connect("CloseOptionsMenu", self, "CloseOptionsMenu")

func CloseOptionsMenu():
	get_node("OptionMenu").queue_free()

func _on_Exit_pressed():
	get_tree().quit()


func _on_NewGame_pressed():
	print("new game")
	get_tree().change_scene("res://scenes/MainScene.tscn")
	queue_free()
	
