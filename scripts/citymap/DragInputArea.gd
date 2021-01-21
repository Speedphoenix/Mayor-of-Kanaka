extends Area2D

# difference is a Vector2
# This signal does not indicate that the map moved, but rather that the player tried to drag it
signal map_dragged(difference)

var hovering := false
var clicking := false

func move_map(diff: Vector2):
	emit_signal("map_dragged", diff)

func _input(event: InputEvent):
	if (
		(
			event is InputEventScreenTouch
			or (event is InputEventMouseButton and event.button_index == BUTTON_RIGHT)
		) and not event.is_pressed()
	):
		clicking = false

	if (
		clicking
		and (
			event is InputEventScreenDrag
			or event is InputEventMouseMotion
		)
	):
		move_map(event.relative)

# Handle clicks here so that it doesn't trigger through the UI or clickable tiles
func _unhandled_input(event: InputEvent):
	if (
		(
			event is InputEventScreenTouch
			or (hovering and event is InputEventMouseButton and event.button_index == BUTTON_RIGHT)
		) and event.is_pressed()
	):
		clicking = true

func _on_DragInputArea_mouse_entered():
	hovering = true

func _on_DragInputArea_mouse_exited():
	hovering = false
