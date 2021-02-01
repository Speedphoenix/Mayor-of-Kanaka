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
			"BUDGET": WeightChoice.randi_range(200, 900),
			"STRESS": WeightChoice.randi_range(-1, 1),
			"SATISFACTION": WeightChoice.randi_range(-1, 1),
		},
	}
	
	#on decline
	#some small fluctuations in citizens minds 
	refuse_or_expire_effects = {
		"on_gauges": {
			"STRESS": WeightChoice.randi_range(-1, 1),
			"SATISFACTION": WeightChoice.randi_range(-1, 1),
		},
	}
	
func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	# ex: Outsource public transport
	title = (
		'Outsource public '
		+ WeightChoice.choose_random_from_array(service_name)
	)
	# ex: Zbubski company is willing to offer its services to the City Hall
	description = (
		'The '
		+ WeightChoice.choose_random_from_array(company_name)
		+ WeightChoice.choose_random_from_array(company_suffix)
		+ ' company is willing to offer its services to the City Hall.'
	)
	
func on_accepted(_scene_tree: SceneTree) -> void:
	#Supposing it's a long term decision, the effects will take place for 6 to 12 months
	for _duration in range(1, WeightChoice.randi_range(6, 12)):
		gauge_controller.announce_gauges_diff(accept_effects.on_gauges)
		yield(turn_controller, "turn_changed")
		gauge_controller.apply_to_gauges(accept_effects.on_gauges)
	#Final hidden consequences
	var sudden_effects = {
		"on_gauges": {
			"NATURE": WeightChoice.randi_range(-20, -5),
			"STRESS": WeightChoice.randi_range(3, 7),
			"SATISFACTION": WeightChoice.randi_range(-15, -5),
		},
	}
	#Final negative effect
	yield(turn_controller, "turn_changed")
	gauge_controller.apply_to_gauges(sudden_effects.on_gauges)
