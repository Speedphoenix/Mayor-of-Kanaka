extends CanvasLayer

var DateLabel: Label

onready var turn_controller := TurnController.get_turn_controller(get_tree())

func _ready():
	turn_controller.connect("miniturn_changed", self, "_on_anyturn_changed")
	turn_controller.connect("turn_changed", self, "_on_anyturn_changed")
	
	DateLabel = $DateController/DateLabel
	DateLabel.text =  "0m 0 d"
	
func _on_anyturn_changed(turn_number, miniturn_number):
	DateLabel.text =  str(turn_number) + "m " +  str(miniturn_number) + "d"
	



