extends Node

var events

# List of events for the current turn
var eventsList

var devmode

var currentTurn

enum Bars {ECONOMY, HEALTH, SATISFACTION, NATURE}

func _ready():
	events = getEventsData()
	# disable if you do not want to display dev tools
	devmode = false
	currentTurn = 0
	eventsList = []
	Bars.ECONOMY = 50
	Bars.HEALTH = 50
	Bars.SATISFACTION = 50
	Bars.NATURE = 50

func _process(_delta):
	pass

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

