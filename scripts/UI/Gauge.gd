extends Control

# Set to true if the value should display as an integer
export(float) var tween_duration := 0.6

# Set to 1 to display an integer
export(float) var step := 0.1

var value: float = 0 setget _set_value, _get_value

onready var arrow_texture_rect: TextureRect = get_node_or_null("MainContainer/ArrowContainer/Arrow")
onready var value_label: Label = $MainContainer/Value
onready var tween: Tween = $Tween

func _ready():
	_set_value(value)
	if arrow_texture_rect != null:
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
	# This shouldn't happen since the gauge displayer wouldn't call this
	# But you never know
	if arrow_texture_rect == null:
		push_warning("Tried setting the diff stonks for a gauge without one")
		return
	if is_equal_approx(diff, 0):
		arrow_texture_rect.visible = false
	elif diff > 0:
		arrow_texture_rect.visible = true
		arrow_texture_rect.flip_v = false
	else:
		arrow_texture_rect.visible = true
		arrow_texture_rect.flip_v = true
