class_name GlobalObject
extends Node

enum Bars {HEALTH, SATISFACTION, NATURE, STRESS, BUDGET}

# Toremove
var events

# List of events for the current turn
# Toremove
var eventsList = []

# Toremove
var currentTurn = 0

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
	_add_events_to_controller()
	events = getEventsData()

func _receive_game_parameters():
	# TODO: try to fetch the given parameters from a global singleton
	game_params = default_params

func _add_events_to_controller():
	for event in game_params.initial_possible_events:
		$EventController.add_possible_event(event)

# Toremove
func getEventsData():
	var data_file = File.new()
	if data_file.open("res://assets/events/events.json", File.READ) != OK:
		print("Error while loading the events file...")
		return
	var data_text = data_file.get_as_text()
	data_file.close()
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		return
	var data = data_parse.result
	return data

