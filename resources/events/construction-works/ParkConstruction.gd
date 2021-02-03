extends ConstructionEvent

var park_type := ['park', 'forest']

func _init():
	#on accept
	# Satisfaction & health goes up
	accept_effects = {
		"on_gauges": {
			#"BUDGET":added later
			"SATISFACTION": WeightChoice.randi_range(1, 3),
			"HEALTH": WeightChoice.randi_range(1, 3)
		},
	}
	#on decline
	#Satisfaction goes down
	refuse_or_expire_effects = {
		"on_gauges": {
			"SATISFACTION": WeightChoice.randi_range(-3, -1),
		},
	}

func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	tile_name = WeightChoice.choose_random_from_array(park_type)
	accept_effects['on_gauges']['BUDGET'] = WeightChoice.randi_range(-60, -30)
