extends Control

# Set to true if the value should display as an integer
export(float) var tween_duration := 0.6

# Set to 1 to display an integer
export(float) var step := 0.1

var value: float = 0 setget _set_value, _get_value

onready var value_label: Label = $MainContainer/Value
onready var arrow_texture_rect: TextureRect = $MainContainer/ArrowContainer/Arrow
onready var tween: Tween = $Tween

func _ready():
	_set_value(value)
	set_expected_diff(0)

func set_value(new_val: float) -> void:
	tween.interpolate_property(self, "value", value, new_val, tween_duration)

	if not tween.is_active():
		tween.start()

func _set_value(new_val: float):
	value = stepify(new_val, step)
	value_label.text = str(value)

func _get_value() -> float:
	return value

func set_expected_diff(diff: float) -> void:
	if is_equal_approx(diff, 0):
		arrow_texture_rect.visible = false
	elif diff > 0:
		arrow_texture_rect.visible = true
		arrow_texture_rect.flip_v = false
	else:
		arrow_texture_rect.visible = true
		arrow_texture_rect.flip_v = true
