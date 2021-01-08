extends CanvasLayer

signal nextTurn

var currentTurn

onready var global = get_tree().get_current_scene().get_node("GlobalObject")
onready var turn_controller: TurnController = global.get_node("TurnController")

func _ready():
	turn_controller.connect("miniturn_changed", self, "_on_anyturn_changed")
	turn_controller.connect("turn_changed", self, "_on_anyturn_changed")
	currentTurn = turn_controller.current_turn_no
	$NextTurnController/CurrentTurnLabel.text =  str(currentTurn)

func _on_anyturn_changed(turn_number, miniturn_number):
	$NextTurnController/CurrentTurnLabel.text =  str(turn_number) + "m " +  str(miniturn_number) + "d" 


