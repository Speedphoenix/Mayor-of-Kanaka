extends CanvasLayer

var DateLabel: Label

onready var global = get_tree().get_current_scene().get_node("GlobalObject")
onready var turn_controller: TurnController = global.get_node("TurnController")

func _ready():
	turn_controller.connect("miniturn_changed", self, "_on_anyturn_changed")
	turn_controller.connect("turn_changed", self, "_on_anyturn_changed")
	
	DateLabel = $DateController/DateLabel
	DateLabel.text =  "0 m 0 d"
	
func _on_anyturn_changed(turn_number, miniturn_number):
	DateLabel.text =  str(turn_number) + "m " +  str(miniturn_number) + "d"
	



