class_name GlobalObject
extends Node

# not currently used
var devmode := false

export(Resource) var default_params

var game_params: GameParameters

onready var global_game_info: GlobalGameInfo = get_node("/root/GlobalGameInfo")

static func get_global_object(scene_tree: SceneTree) -> GlobalObject:
	return scene_tree.get_current_scene().get_node("GlobalObject") as GlobalObject

func _ready():
	randomize()
	assert(default_params is GameParameters)
	_receive_game_parameters()
	game_params.apply(get_tree())

func _receive_game_parameters():
	game_params = global_game_info.game_params
	if game_params == null:
		game_params = default_params

