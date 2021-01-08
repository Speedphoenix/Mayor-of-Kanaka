extends Control

onready var global = get_tree().get_current_scene().get_node("GlobalObject")
onready var turn_controller = global.get_node("TurnController")

func _ready():
	pass
#	turn_controller.connect("miniturn_changed", self, "_on_miniturn_changed")
#	turn_controller.connect("turn_changed", self, "_on_turn_changed")
