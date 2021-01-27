extends Control

var eventDisplayer

func _ready():
	# TODO : find a better solution to get the EventDisplayer Node
	eventDisplayer = get_parent().get_parent().get_parent()
	if !(eventDisplayer is CanvasLayer) or eventDisplayer == null:
		print("Error : the Event Displayer has not been found or is of the wrong type")
	else:
		var refuseButton = $RefuseFrame/RefuseButton
		var acceptButton = $AcceptFrame/AcceptButton
		
		refuseButton.connect("pressed", eventDisplayer, "_on_RefuseButton_pressed")
		acceptButton.connect("pressed", eventDisplayer, "_on_AcceptButton_pressed")
		
func change_accept_label(new_text: String):
	var acceptLabel = $AcceptFrame/AcceptLabel
	acceptLabel.text = new_text
	
func change_refuse_label(new_text: String):
	var refuseLabel = $RefuseFrame/RefuseLabel
	refuseLabel.text = new_text
