extends ConstructionEvent

# The name of the gauge that will be incremented when a building is erected
const gauge_counter_name = "MALL"
var company_names := ['Barker', 'Zabinski', 'Rockdock', 'Sternfild']

func _init():
	#on accept
	#will gain a budget profit
	accept_effects = {
		"on_gauges": {
			"BUDGET": WeightChoice.randi_range(1500, 2500),
			"SATISFACTION": WeightChoice.randi_range(5, 10)
		},
	}
	#on decline
	#o negative effects
	refuse_or_expire_effects = {
		"on_gauges": {
		},
	}

func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	description = (
		'Mayor, the ' + WeightChoice.choose_random_from_array(company_names) 
		+ ' company is willing to construct a shopping mall in the city.' 
		+ ' This will bring a profit to the city budget.'
	)

func on_accepted(scene_tree: SceneTree) -> void:
	.on_accepted(scene_tree)
	if can_build_it:
		# The school building will be constructed!
		if !gauge_controller.gauge_exists(gauge_counter_name):
			gauge_controller.create_gauge(gauge_counter_name, 0, { "LOWER": 0 })
		gauge_controller.apply_to_gauge(gauge_counter_name, 1)
