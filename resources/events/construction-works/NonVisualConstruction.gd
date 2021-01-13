# Some construction works not illustrated on the main city map:
# Basically we are paying a reasonable amount of money per month and get some bonuses for it
# Ex: upgrading the electricity network 
extends DecisionSimple

#will generate a random number 
var rng = RandomNumberGenerator.new()

var event_title_description = [['Water supply system', 'The system is used'], 
	['Water filtering system', 'The system is used'], 
	['Electricity delivery system', 'The system is used'], 
	['Electricity consumption policies', 'Policies are too old.']]

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
			"SATISFACTION": rng.randi_range(-20,-15),
		},
	}
	
func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	
	rng.randomize()
	var event_chosen = rng.randi_range(0, event_title_description.size() - 1)
	title = event_title_description[event_chosen][0]
	#money spent mothly to conduct the improvement
	var improvement_monthly_cost = rng.randi_range(-50, -15)
	#monthly ecological benefit from the improvement
	var ecological_benefit = rng.randi_range(2, 3)
	#monthly citiznes satisfaction benefit from the improvement
	var satisfaction_benefit = rng.randi_range(1, 3)
	
	description = ('Mayor, our ' + title + ' needs an improvement. ' 
		+ event_title_description[event_chosen][1]
		+ ' The necessary intervention will cost ' + str(improvement_monthly_cost * -1) 
		+ ' $ monthly')
	accept_effects['on_gauges']['BUDGET'] = improvement_monthly_cost
	accept_effects['on_gauges']['SATISFACTION'] = improvement_monthly_cost
	accept_effects['on_gauges']['NATURE'] = improvement_monthly_cost

func on_accepted(scene_tree: SceneTree) -> void:
	#effects will take place for 6 to 12 months
	for duration in range(1, rng.randi_range(6, 12)):
		yield(turn_controller, "turn_changed")
		gauge_controller.apply_to_gauges(accept_effects.on_gauges)
	
