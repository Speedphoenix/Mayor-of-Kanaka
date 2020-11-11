extends Node

var events

func _ready():
	events = getEventsData()

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