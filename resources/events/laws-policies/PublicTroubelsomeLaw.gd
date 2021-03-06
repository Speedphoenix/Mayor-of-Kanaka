#This event generates an unpopular public law preserving nature/ecology
extends DecisionSimple

export(Array, Array, String) var possible_title_and_description := [
	[ 'Implement a curfew', 'Restrict citizen mobility between 8PM and 6AM' ],
	[
		'Add restrictions in order to limit CO2 emissions.',
		'Only vehicles having a licence plate with even numbers should be allowed to move in the city. (Concerns only civilian private transport)',
	],
]

func _init():
	#Budget< (city s spending some money on the laws) 
	#Stress> (people r ucomfortable) 
	#Nature> (laws preserving nature/ecology) 
	#Satisfaction< (people unsatisfied with governments policies)
	accept_effects = {
		"on_gauges": {
			"BUDGET": WeightChoice.randi_range(-60, -25),
			"STRESS": WeightChoice.randi_range(5, 20),
			"NATURE": WeightChoice.randi_range(10, 20),
			"SATISFACTION": WeightChoice.randi_range(-10, -5),
		},
	}
	
	#on decline
	# Nature< (no preserving laws in action)
	refuse_or_expire_effects = {
		"on_gauges": {
			"NATURE": WeightChoice.randi_range(-10, -5),
		},
	}
func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	var name_desc_chooser = WeightChoice.randi_range(0, possible_title_and_description.size() - 1)
	title = possible_title_and_description[name_desc_chooser][0]
	description = possible_title_and_description[name_desc_chooser][1]

func on_accepted(scene_tree: SceneTree) -> void:
	.on_accepted(scene_tree)
	#if citizens stress is too elevated, this event will trigger public unsatisfaction
	if (gauge_controller.get_gauge('STRESS') > 51):
		event_controller.enable_or_add_possible_event(depending_event)
		event_controller.trigger_immediate_event(depending_event)
