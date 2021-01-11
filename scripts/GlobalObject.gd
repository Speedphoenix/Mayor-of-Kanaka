class_name GlobalObject
extends Node

enum Bars {HEALTH, SATISFACTION, NATURE, STRESS, BUDGET}

export(bool) var devmode := false

export(Resource) var default_params

var game_params: GameParameters

var bars = {
	"HEALTH": 50,
	"SATISFACTION": 50,
	"NATURE": 50,
	"STRESS": 50,
	"BUDGET": 50,
}

func _ready():
	randomize()
	assert(default_params is GameParameters)
	_receive_game_parameters()
	game_params.apply(get_tree())

func _receive_game_parameters():
	# TODO: try to fetch the given parameters from a global singleton
	game_params = default_params

