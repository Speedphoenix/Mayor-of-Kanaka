extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	$CurrentTurnLabel.text =  "0"

func _on_NextTurnButton_pressed():
	var currentTurn = int($CurrentTurnLabel.text)
	var newCurrentTurn = currentTurn + 1
	$CurrentTurnLabel.text =  String(newCurrentTurn)
