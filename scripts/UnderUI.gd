extends CanvasLayer

signal nextTurn

onready var currentTurn

# Called when the node enters the scene tree for the first time.
func _ready():
	var Global = get_node("/root/Global")
	currentTurn = Global.currentTurn
	$CurrentTurnLabel.text =  String(currentTurn)

func _on_NextTurnButton_pressed():
	var currentTurn = int($CurrentTurnLabel.text)
	var newCurrentTurn = currentTurn + 1
	$CurrentTurnLabel.text =  String(newCurrentTurn)
	var Global = get_node("/root/Global")
	Global.currentTurn += 1
	emit_signal("nextTurn")

