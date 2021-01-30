class_name EventAdderEffect
extends EventEffect

export(Array, Resource) var depending_events := []

export(bool) var depending_is_immediate := false

# Called when the event is created, before the player has interracted with it
func on_triggered(_scene_tree: SceneTree) -> void:
	for event in depending_events:
		assert(event is BaseEvent)

func apply_effect(scene_tree: SceneTree, resolve_type: int, _turn_delay: int) -> void:
	var event_controller := EventController.get_instance(scene_tree)
	if not resolve_type in which_resolves:
		return
	for event in depending_events:
		event_controller.enable_or_add_possible_event(event)
		if depending_is_immediate:
			event_controller.trigger_immediate_event(event)
