class_name PopulationEffect
extends BaseEffect

export(int) var house_count := 1

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
	var house_delay = 0
	if delay > 0:
		house_delay += remaining_days
		if delay > 1:
			house_delay += (delay - 1) * turn_controller.days_in_a_month
	population_controller.add_random_houses(house_count, house_delay)
