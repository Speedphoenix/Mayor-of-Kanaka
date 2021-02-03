# Some construction works not illustrated on the main city map:
# Basically we are paying a reasonable amount of money per month and get some bonuses for it
# Ex: upgrading the electricity network
extends DecisionSimple

export(Array, Array, String) var event_title_description = [
	['Renovate the water supply system', 'The system is worn down.'],
	['Renovate the water filtering system', 'The system has deteriorated.'],
	['Upgrade the electricity delivery system', 'The system is out of date.'],
	['Reform the electricity consumption policies', 'Policies are too old.'],
]

func _init():
	#on accept
	accept_effects = {
		"on_gauges": {
			#BUDGET is added in on_triggered,
			#SATISFACTION is added is added in on_triggered ,
			#NATURE is is added in on_triggered,
		},
	}
	#on decline
	# Citizens are unsatisfied by City Hall's passiveness
	refuse_or_expire_effects = {
		"on_gauges": {
			"SATISFACTION": WeightChoice.randi_range(-20,-15),
		},
	}

func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	
	var event_chosen = WeightChoice.randi_range(0, event_title_description.size() - 1)
	title = event_title_description[event_chosen][0]
	#money spent mothly to conduct the improvement
	var improvement_monthly_cost = WeightChoice.randi_range(-50, -15)
	#monthly ecological benefit from the improvement
	var ecological_benefit = WeightChoice.randi_range(2, 3)
	#monthly citiznes satisfaction benefit from the improvement
	var satisfaction_benefit = WeightChoice.randi_range(1, 3)
	
	description = ('Mayor, we need to ' + title.to_lower() + '. '
		+ event_title_description[event_chosen][1]
		+ ' The necessary intervention will cost ' + str(improvement_monthly_cost * -1) 
		+ 'K $ monthly')
	accept_effects['on_gauges']['BUDGET'] = improvement_monthly_cost
	accept_effects['on_gauges']['SATISFACTION'] = satisfaction_benefit
	accept_effects['on_gauges']['NATURE'] = ecological_benefit

func on_accepted(_scene_tree: SceneTree) -> void:
	#effects will take place for 6 to 12 months, parent class on_accepted is NOT called
	#manually announce differences
	gauge_controller.announce_gauges_diff(accept_effects.on_gauges)
	for _duration in range(1, WeightChoice.randi_range(6, 12)):
		yield(turn_controller, "turn_changed")
		gauge_controller.apply_to_gauges(accept_effects.on_gauges)
		
		# Make sure the next diff is announced after the previous turn is over
		yield(_scene_tree, "idle_frame")
		gauge_controller.announce_gauges_diff(accept_effects.on_gauges)

func on_refused(scene_tree: SceneTree) -> void:
	.on_refused(scene_tree)
	#will add and trigger a BankLoan event
	#var test_event: BaseEvent = depending_event.duplicate()
	#test_event.title
	event_controller.enable_or_add_possible_event(depending_event)
	event_controller.trigger_immediate_event(depending_event)
