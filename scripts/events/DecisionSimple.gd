class_name DecisionSimple
extends BaseDecision
# This has the basic functionality of an event, and is customizable
# should have an effect on the various gauges 


# BarEffect needs to inherit Resource
# will nee to test to see how this works out
# export(Array, BarEffect) effects = []
export var effects: Array = []

func on_accepted() -> void:
	pass
	
func on_refused() -> void:
	pass

func on_expired() -> void:
	pass
