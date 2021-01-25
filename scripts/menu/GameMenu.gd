extends Control

export(PackedScene) var mainscene = preload("res://scenes/MainScene.tscn")
export(PackedScene) var options_menu = preload("res://scenes/menu/OptionMenu.tscn")


func _on_Options_pressed():
	var option_menu = options_menu.instance()
	add_child(option_menu)
	get_node("OptionMenu").connect("CloseOptionsMenu", self, "CloseOptionsMenu")
	var language_bar_option = get_node("OptionMenu/HBoxContainer/Colum1/languageBar")
	language_bar_option.add_item("English")
	get_tree().paused = true


func CloseOptionsMenu():
	get_node("OptionMenu").queue_free()
	get_tree().paused = false

func _on_Exit_pressed():
	get_tree().quit()


func _on_NewGame_pressed():
	get_tree().change_scene(mainscene.resource_path)
	queue_free()
	
