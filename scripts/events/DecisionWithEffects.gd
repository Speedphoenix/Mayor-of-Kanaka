class_name DecisionWithEffects
extends BaseEvent

# An array of EventEffects
export(Array, Resource) var effects := []

# Will duplicate effects to avoid having multiple events
# having the same reference to an effect
# Effects are duplicated manually rather than with subresources=true
# from the eventcontroller for performance reasons in case we add stuff like images
var effects_to_use := []
var turn_controller: TurnController

# Called when the event is created, before the player has interracted with it
func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	for el in effects:
		effects_to_use.append(el.duplicate())
	turn_controller = TurnController.get_instance(scene_tree)
	for effect in effects_to_use:
		assert(effect is BaseEffect)
		effect.on_triggered(scene_tree, self)

func apply_effects(scene_tree: SceneTree, resolve_type: int):
	var last_turn_with_effect: int = -1
	for effect in effects_to_use:
		effect.on_resolved(scene_tree, resolve_type)
	for effect in effects_to_use:
		var curr: int = effect.delay
		if curr > last_turn_with_effect:
			last_turn_with_effect = curr
	if last_turn_with_effect == -1:
		return
	for curr_turn in range(last_turn_with_effect + 1):
		for effect in effects_to_use:
			if curr_turn == effect.delay:
				effect.apply_effect(scene_tree, resolve_type, curr_turn)
		if curr_turn != last_turn_with_effect:
			yield(turn_controller, "turn_changed")

func on_accepted(scene_tree: SceneTree) -> void:
	.on_accepted(scene_tree)
	apply_effects(scene_tree, BaseEffect.ResolveType.ACCEPT)
	
func on_refused(scene_tree: SceneTree) -> void:
	.on_refused(scene_tree)
	apply_effects(scene_tree, BaseEffect.ResolveType.REFUSE)

func on_expired(scene_tree: SceneTree) -> void:
	.on_expired(scene_tree)
	apply_effects(scene_tree, BaseEffect.ResolveType.EXPIRE)

# Returns true if the event can be accepted (eg The current budget is sufficient)
func can_accept(_scene_tree: SceneTree) -> bool:
	for effect in effects_to_use:
		if effect.blocks_accept(_scene_tree):
			return false
	return true
