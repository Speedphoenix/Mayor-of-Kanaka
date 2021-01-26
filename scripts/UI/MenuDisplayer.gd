extends CanvasLayer

func _ready():
	pass

func _on_BackMenuButton_pressed():
	# TODO : Save the current scene, i.e. put every variables needed into the scene
	# then save the scene and on every ready function, put the right variable from
	# this global object into it... good luck
	
	# Then go back to the main menu
	get_tree().change_scene("res://scenes/menu/GameMenu.tscn")
	queue_free()
