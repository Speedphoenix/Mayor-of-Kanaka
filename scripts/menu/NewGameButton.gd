extends TextureButton

export(Resource) var game_parameters: Resource = null
onready var global_game_info: GlobalGameInfo = get_node("/root/GlobalGameInfo")

func _ready():
	assert(game_parameters is GameParameters or game_parameters == null)

func _pressed():
	var current_scene = get_tree().get_current_scene()
	global_game_info.game_params = self.game_parameters
	get_tree().change_scene("res://scenes/MainScene.tscn")
	current_scene.queue_free()
