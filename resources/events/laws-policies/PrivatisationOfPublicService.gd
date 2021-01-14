#Basically this event will offer a great profit for the city budget,
#little fluctuation of citizens satisfaction 
#AND some huge random negative effect after a certain time
extends DecisionSimple
 
var company_name := ['Tin', 'Lin', 'Back', 'Zbub']
var company_suffix := ['er', 'ski']
var service_name := ['heating', 'transportation', 'garbage collection']

func _init():
	#on accept
	#gaining important money profit
	#some little citizens mood fluctuation
	accept_effects = {
		"on_gauges": {
			"BUDGET": rng.randi_range(80, 140),
			"STRESS": rng.randi_range(-2, 2),
			"SATISFACTION": rng.randi_range(-2, 2),
		},
	}
	
	#on decline
	#some small fluctuations in citizens minds 
	refuse_or_expire_effects = {
		"on_gauges": {
			"STRESS": rng.randi_range(-2, 2),
			"SATISFACTION": rng.randi_range(-2, 2),
		},
	}
	
func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	
	# ex: Outsource public transport
	title = (
		'Outsource public '
		+ service_name[rng.randi_range(0, service_name.size() - 1)]
	)
	# ex: Zbubski company is willing to offer its services to the City Hall
	description = (
		'The '
		+ company_name[rng.randi_range(0, service_name.size() - 1)]
		+ company_suffix[rng.randi_range(0, service_name.size() - 1)]
		+ ' company is willing to offer its services to the City Hall'
	)
	
func on_accepted(scene_tree: SceneTree) -> void:
	#Supposing it's a long term decision, the effects will take place for 6 to 12 months
	for duration in range(1, rng.randi_range(6, 12)):
		yield(turn_controller, "turn_changed")
		gauge_controller.apply_to_gauges(accept_effects.on_gauges)
	#Final hidden consequences
	var sudden_effects = {
		"on_gauges": {
			"NATURE": rng.randi_range(-30, -10),
			"STRESS": rng.randi_range(-10, -5),
			"SATISFACTION": rng.randi_range(-20, -10),
		},
	}
	#Final negative effect
	yield(turn_controller, "turn_changed")
	gauge_controller.apply_to_gauges(sudden_effects.on_gauges)
