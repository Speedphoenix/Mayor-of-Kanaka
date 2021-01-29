class_name GlobalObject
extends Node

# not currently used
var devmode := false

var initialization_did_finish = false

export(Resource) var default_params

var game_params: GameParameters

onready var global_game_info: GlobalGameInfo = get_node("/root/GlobalGameInfo")

static func get_instance(scene_tree: SceneTree) -> GlobalObject:
	return scene_tree.get_current_scene().get_node("GlobalObject") as GlobalObject

func _enter_tree():
	initialization_did_finish = false

func _ready():
	assert(default_params is GameParameters)
	_receive_game_parameters()
	game_params.apply(get_tree())
	initialization_did_finish = true

func _receive_game_parameters():
	game_params = global_game_info.game_params
	if game_params == null:
		game_params = default_params

