extends Control

signal eventChanged(eventID)

export (PackedScene) var EventsUI
var devmode

func _ready():
	var Global = get_node("/root/Global")
	devmode = Global.devmode
	$EventsUIController/EventsUI.get_child(0).hide()
	initSelector()
	if(devmode == true):
		$CreateEventButton.show()
		$EventIDSelector.show()

func _process(_delta):
	pass

func initSelector():
	$EventIDSelector.add_item("Earthquake", 1)
	$EventIDSelector.add_item("School", 2)
	$EventIDSelector.add_item("Chaos", 3)

func _on_CreateEventButton_pressed():
	var eventID = $EventIDSelector.get_item_id($EventIDSelector.selected)
	#print("eventID to be printed :", eventID)
	emit_signal("eventChanged", eventID)
	$EventsUIController/EventsUI.get_child(0).show()

func _on_EventsUI_close():
	$EventsUIController/EventsUI.get_child(0).hide()
