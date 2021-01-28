extends TextureButton

export(Resource) var game_parameters: Resource = null

onready var global_game_info: GlobalGameInfo = get_node("/root/GlobalGameInfo")

export (String ) var title
export (String ) var budget
export (String ) var health
export (String ) var nature
export (String ) var satisfaction
export (String ) var mayor

func _ready():
	$GameTitle.text = title
	$GameInfos.text = "Budget: "+budget+ "M$\nHealth: "+ health + "\nEcology: "+ nature + "\nCitizen satisfaction: " + satisfaction + "\nMayor Stress: " +mayor 
	assert(game_parameters is GameParameters or game_parameters == null)

func _pressed():
	var current_scene = get_tree().get_current_scene()
	global_game_info.game_params = self.game_parameters
	get_tree().change_scene("res://scenes/MainScene.tscn")
	current_scene.queue_free()
