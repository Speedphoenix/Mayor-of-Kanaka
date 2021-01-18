class_name GlobalObject
extends Node

# not currently used
var devmode := false

export(Resource) var default_params

var game_params: GameParameters

static func get_global_object(scene_tree: SceneTree) -> GlobalObject:
	return scene_tree.get_current_scene().get_node("GlobalObject") as GlobalObject

func _ready():
	randomize()
	assert(default_params is GameParameters)
	_receive_game_parameters()
	game_params.apply(get_tree())

func _receive_game_parameters():
	# TODO: try to fetch the given parameters from a global singleton
	game_params = default_params

