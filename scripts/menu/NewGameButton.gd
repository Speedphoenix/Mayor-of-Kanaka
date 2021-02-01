extends TextureButton

export(Resource) var game_parameters: Resource = null

onready var global_game_info: GlobalGameInfo = get_node("/root/GlobalGameInfo")

export (String) var title


func _ready():
	var budget = str(stepify(game_parameters.initial_gauges["BUDGET"], 1))
	var health = str(stepify(game_parameters.initial_gauges["HEALTH"], 0.1))
	var satisfaction = str(stepify(game_parameters.initial_gauges["SATISFACTION"], 0.1))
	var stress = str(stepify(game_parameters.initial_gauges["STRESS"], 0.1))
	var nature = str(stepify(game_parameters.initial_gauges["NATURE"], 0.1))
	$GameTitle.text = title
	$GameInfos.text = ("Budget: " + budget + "K$\nHealth: " + health + "\nEcology: "
			+ nature + "\nCitizen satisfaction: " + satisfaction + "\nMayor's Stress: " + stress)
	assert(game_parameters is GameParameters or game_parameters == null)

func _pressed():
	var current_scene = get_tree().get_current_scene()
	global_game_info.game_params = self.game_parameters
	get_tree().change_scene("res://scenes/MainScene.tscn")
	current_scene.queue_free()
