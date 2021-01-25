extends CanvasLayer

func _ready():
	pass

func _on_BackMenuButton_pressed():
	# TODO : Save the current scene, i.e. put every variables needed into the scene
	# then save the scene and on every ready function, put the right variable from
	# this global object into it... good luck
	var saved_scene = PackedScene.new()
	saved_scene.pack(get_tree().get_current_scene())
	var save_error = ResourceSaver.save("res://scenes/saves/saved_game.tscn", saved_scene)
	if save_error != 0:
		print("Error while saving the scene : ", save_error)
	
	# Then go back to the main menu
	get_tree().change_scene("res://scenes/menu/GameMenu.tscn")
	queue_free()
