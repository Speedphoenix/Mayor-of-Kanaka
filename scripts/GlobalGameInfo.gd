extends Node

# Also contains user settings

# Get the instance through get_node("/root/GlobalGameInfo")

var volume: float = 0
var is_muted: bool = false

var game_params: GameParameters = null setget set_game_params, get_game_params

func _ready():
	randomize()

func set_game_params(val: GameParameters):
	assert(val == null || val is GameParameters)
	game_params = val

func get_game_params() -> GameParameters:
	return game_params
