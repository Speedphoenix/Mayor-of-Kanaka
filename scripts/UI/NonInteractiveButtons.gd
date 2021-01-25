extends Control

var eventDisplayer: CanvasLayer

func _ready():
# TODO : find a better solution to get the EventDisplayer Node
	eventDisplayer = get_parent().get_parent().get_parent()
	if !(eventDisplayer is CanvasLayer) or eventDisplayer == null:
		print("Error : the Event Displayer has not been found or is of the wrong type")
	else:
		var nonInteractiveButton = $NonInteractiveFrame/NonInteractiveButton
		
		# TODO : change the accepted function to the Non Interactive one
		nonInteractiveButton.connect("pressed", eventDisplayer, "_on_AcceptButton_pressed")

func change_non_interactive_label(new_text: String):
	var nonInteractiveLabel = $NonInteractiveFrame/NonInteractiveLabel
	nonInteractiveLabel.text = new_text
