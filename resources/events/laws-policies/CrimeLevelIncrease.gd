#local crime level has increased for some reason, city hall msut take some measures
extends DecisionSimple

var district_name := ['Backler', 'Central', 'Forest Hill', 'Sunny']

func _init():
	#on accept
	#spending extra budget money to enforce local police patrols
	accept_effects = {
		"on_gauges": {
			"BUDGET": WeightChoice.randi_range(-20, -10),
			"STRESS": WeightChoice.randi_range(-5, -3),
		},
	}
	#on decline
	# Citizens are unsatisfied by the City Hall's passiveness
	refuse_or_expire_effects = {
		"on_gauges": {
			"SATISFACTION": WeightChoice.randi_range(-10, -5),
			"STRESS": WeightChoice.randi_range(3, 5)
		},
	}

func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	description = (
		'Mayor, crime level in ' 
		+ WeightChoice.choose_random_from_array(district_name)
		+' District has severly increased.\nWe must act in order to protect our citizens.'
	)

func on_refused(scene_tree: SceneTree) -> void:
	.on_refused(scene_tree)
	#will trigger citizen unsatisfaction event
	event_controller.enable_or_add_possible_event(depending_event)
	event_controller.trigger_immediate_event(depending_event)
