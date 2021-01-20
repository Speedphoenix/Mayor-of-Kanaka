class_name InterfaceController
extends Control

# Events to be displayed, asked by the player via the UnderUI script
signal event_to_display(event)

func _ready():
	pass # Replace with function body.
	
# Emit a signal to display an event
func event_to_display(event: BaseEvent):
	emit_signal("event_to_display", event)

