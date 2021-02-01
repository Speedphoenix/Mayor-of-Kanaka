class_name PopulationEffect
extends BaseEffect

# Called when the event is created, before the player has interracted with it
func on_triggered(_scene_tree: SceneTree, _event: BaseEvent) -> void:
	pass

# Called when it is accepted/expired/refused
# This is called right before apply_effect with turn_delay=0 if 0 is in the delays
func on_resolved(scene_tree: SceneTree, resolve_type: int) -> void:
	if not (resolve_type in which_resolves):
		return
	var population_controller := PopulationController.get_instance(scene_tree)
	var turn_controller := TurnController.get_instance(scene_tree)
	var remaining_days: int = turn_controller.days_in_a_month - turn_controller.current_miniturn_no

func apply_effect(_scene_tree: SceneTree, resolve_type: int, _turn_delay: int) -> void:
	pass

# Returns false if this should not be accepted
func blocks_accept(_scene_tree: SceneTree) -> bool:
	return false

func _set_delays(value: int):
	delay = value

# This can be overridden if need be
func _get_delays() -> int:
	return delay
