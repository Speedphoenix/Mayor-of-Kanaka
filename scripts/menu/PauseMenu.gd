extends Control

signal ClosePauseMenu

func _on_Exit_pressed():
	emit_signal("ClosePauseMenu")
	

func _on_MainMenu_pressed():
	get_tree().change_scene("res://scenes/menu/GameMenu.tscn")


func _on_Options_pressed():
	var option_menu = load("res://scenes/menu/OptionMenu.tscn").instance()
	add_child(option_menu)
	get_node("OptionMenu").connect("CloseOptionsMenu", self, "CloseOptionsMenu")
	var language_bar_option = get_node("OptionMenu/HBoxContainer/Colum1/languageBar")
	language_bar_option.add_item("English")

func CloseOptionsMenu():
	get_node("OptionMenu").queue_free()
