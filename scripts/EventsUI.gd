extends CanvasLayer

onready var global = get_tree().get_current_scene().get_node("GlobalObject")
onready var turn_controller: TurnController = global.get_node("TurnController")

func _ready():
	pass

func _process(_delta):
	pass

func _on_AcceptButton_pressed():
	pass

func _on_RefuseButton_pressed():
	pass

func _on_HoldButton_pressed():
	pass

func _on_CloseButton_pressed():
	pass
