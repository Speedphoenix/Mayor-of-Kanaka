extends Control

var value: float = 0 setget set_value

onready var value_label: Label = $MainContainer/Value
onready var arrow_texture_rect: TextureRect = $MainContainer/ArrowContainer/Arrow

func _ready():
	set_value(value)
	set_expected_diff(0)

func set_value(new_val: float):
	value = new_val
	value_label.text = str(new_val)

func set_expected_diff(diff: float):
	if is_equal_approx(diff, 0):
		arrow_texture_rect.visible = false
	elif diff > 0:
		arrow_texture_rect.visible = true
		arrow_texture_rect.flip_v = false
	else:
		arrow_texture_rect.visible = true
		arrow_texture_rect.flip_v = true
