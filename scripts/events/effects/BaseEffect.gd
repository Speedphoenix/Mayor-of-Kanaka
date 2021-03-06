class_name BaseEffect
extends Resource

# Emitted once when it has been triggered
signal triggered

enum ResolveType {
	ACCEPT,
	REFUSE,
	EXPIRE,
}

# 0 means immediately, 1 is the first turn...
export(int) var delay := 1 setget _set_delays, _get_delays

export(Array, ResolveType) var which_resolves := [ResolveType.ACCEPT]

var was_triggered := false

# Called when the event is created, before the player has interracted with it
func on_triggered(_scene_tree: SceneTree, _event: BaseEvent) -> void:
	pass

# Called when it is accepted/expired/refused
# This is called right before apply_effect with turn_delay=0 if 0 is in the delays
func on_resolved(_scene_tree: SceneTree, _resolve_type: int) -> void:
	pass

func apply_effect(_scene_tree: SceneTree, _resolve_type: int, _turn_delay: int) -> void:
	pass

# Call this from child classes to signal that the initialization sequece of the effect is over
func set_as_triggered() -> void:
	was_triggered = true
	emit_signal("triggered")

# Returns false if this should not be accepted
func blocks_accept(_scene_tree: SceneTree) -> bool:
	return false

func _set_delays(value: int):
	delay = value

# This can be overridden if need be
func _get_delays() -> int:
	return delay
