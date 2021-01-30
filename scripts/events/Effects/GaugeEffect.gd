class_name GaugeEffect
extends EventEffect

# This should look something like
#{
#	"HEALTH": -5,
#	"STRESS": 20,
#}
export(Dictionary) var gauge_diffs := {}

export(bool) var announce_first_turn_effects := true

export(bool) var block_accept_on_no_budget := true

func on_triggered(_scene_tree: SceneTree) -> void:
	if announce_first_turn_effects && not 0 in delays:
		delays.push_back(0)

func apply_effect(scene_tree: SceneTree, resolve_type: int, turn_delay: int) -> void:
	var gauge_controller := GaugeController.get_instance(scene_tree)
	if not resolve_type in which_resolves:
		return
	if turn_delay == 0:
		if announce_first_turn_effects:
			gauge_controller.announce_gauges_diff(gauge_diffs)
	else:
		gauge_controller.apply_to_gauges(gauge_diffs)

# Returns false if this should not be accepted
func blocks_accept(scene_tree: SceneTree) -> bool:
	if block_accept_on_no_budget:
		var gauge_controller := GaugeController.get_instance(scene_tree)
		if("BUDGET" in gauge_diffs && gauge_diffs["BUDGET"] < 0):
			return gauge_controller.get_gauge("BUDGET") + gauge_diffs["BUDGET"] >= 0
	return false
