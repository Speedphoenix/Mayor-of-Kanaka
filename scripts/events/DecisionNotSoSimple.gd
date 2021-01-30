class_name DecisionNotSoSimple
extends BaseEvent

# An array of EventEffects
export(Array, Resource) var effects := []

var turn_controller: TurnController

# Called when the event is created, before the player has interracted with it
func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	turn_controller = TurnController.get_instance(scene_tree)
	for effect in effects:
		assert(effect is EventEffect)
		effect.on_triggered(scene_tree)

func apply_effects(scene_tree: SceneTree, resolve_type: int):
	var last_turn_with_effect: int = -1
	for effect in effects:
		var currmax: int = effect.delays.max()
		if currmax > last_turn_with_effect:
			last_turn_with_effect = currmax
	if last_turn_with_effect == -1:
		return
	for curr_turn in range(last_turn_with_effect + 1):
		for effect in effects:
			if curr_turn in effect.delays:
				effect.apply_effect(scene_tree, resolve_type, curr_turn)
		if curr_turn != last_turn_with_effect:
			yield(turn_controller, "turn_changed")

func on_accepted(scene_tree: SceneTree) -> void:
	.on_accepted(scene_tree)
	apply_effects(scene_tree, EventEffect.ResolveType.ACCEPT)
	
func on_refused(scene_tree: SceneTree) -> void:
	.on_refused(scene_tree)
	apply_effects(scene_tree, EventEffect.ResolveType.REFUSE)

func on_expired(scene_tree: SceneTree) -> void:
	.on_expired(scene_tree)
	apply_effects(scene_tree, EventEffect.ResolveType.EXPIRE)

# Returns true if the event can be accepted (eg The current budget is sufficient)
func can_accept(_scene_tree: SceneTree) -> bool:
	for effect in effects:
		if effect.blocks_accept(_scene_tree):
			return false
	return true
