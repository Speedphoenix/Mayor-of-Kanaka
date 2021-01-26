extends CanvasLayer

func _ready():
	pass

func _on_BackMenuButton_pressed():
	# TODO : Save the current scene, i.e. put every variables needed into the scene
	# then save the scene and on every ready function, put the right variable from
	# this global object into it... good luck
	
	var pause_menu = load("res://scenes/menu/PauseMenu.tscn").instance()
	add_child(pause_menu)
	get_node("PauseMenu").connect("ClosePauseMenu", self, "ClosePauseMenu")
	get_tree().paused = true
		
	# Then go back to the main menu
	#get_tree().change_scene("res://scenes/menu/GameMenu.tscn")
	#queue_free()

func ClosePauseMenu():
	get_node("PauseMenu").queue_free()
	get_tree().paused = false
