extends CanvasLayer

export(float) var bounce_duration := 0.25
export(float) var bounce_scale := 1.25


var initial_scale: Vector2

onready var date_label: Label = $DateController/DateLabel
onready var tween: Tween = $Tween
onready var turn_controller := TurnController.get_instance(get_tree())

func _ready():
	turn_controller.connect("miniturn_changed", self, "_on_anyturn_changed")
	turn_controller.connect("turn_changed", self, "_on_anyturn_changed")
	
	date_label.text =  "0m 1d"
	initial_scale = date_label.rect_scale
	
func _on_anyturn_changed(turn_number, miniturn_number):
	date_label.text =  str(turn_number) + "m " +  str(miniturn_number) + "d"

	tween.interpolate_property(date_label, "rect_scale", initial_scale, initial_scale * bounce_scale, bounce_duration / 2)
	if not tween.is_active():
		tween.start()
	yield(tween, "tween_completed")
	# now back to normal
	tween.interpolate_property(date_label, "rect_scale", date_label.rect_scale, initial_scale, bounce_duration / 2)
