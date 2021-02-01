class_name GaugeEffect
extends BaseEffect

# This should look something like
#{
#	"HEALTH": -5,
#	"STRESS": 20,
#}
export(Dictionary) var gauge_diffs := {}

export(bool) var announce_first_turn_effects := true

export(bool) var block_accept_on_no_budget := true
export(bool) var create_gauge_if_needed := true

func on_resolved(scene_tree: SceneTree, resolve_type: int) -> void:
	var gauge_controller := GaugeController.get_instance(scene_tree)
	if not (resolve_type in which_resolves):
		return
	if announce_first_turn_effects:
		gauge_controller.announce_gauges_diff(gauge_diffs)

func apply_effect(scene_tree: SceneTree, resolve_type: int, _turn_delay: int) -> void:
	var gauge_controller := GaugeController.get_instance(scene_tree)
	if not (resolve_type in which_resolves):
		return
	for gauge_name in gauge_diffs:
		# Creating gauges because we could apply on non-existing ones like SCHOOL
		if create_gauge_if_needed && !gauge_controller.gauge_exists(gauge_name):
			gauge_controller.create_gauge(gauge_name, 0, { "LOWER": 0 })
	gauge_controller.apply_to_gauges(gauge_diffs)

# Returns false if this should not be accepted
func blocks_accept(scene_tree: SceneTree) -> bool:
	if block_accept_on_no_budget:
		var gauge_controller := GaugeController.get_instance(scene_tree)
		if("BUDGET" in gauge_diffs && gauge_diffs["BUDGET"] < 0):
			return gauge_controller.get_gauge("BUDGET") + gauge_diffs["BUDGET"] >= 0
	return false
