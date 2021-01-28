extends Node

# This node controls the weight of school events

export(Resource) var school_construction_event: Resource

var triggerable_school_event: EventController.TriggerableEvent

onready var event_controller := EventController.get_instance(get_tree())
onready var gauge_controller := GaugeController.get_instance(get_tree())

func _ready():
	assert(school_construction_event is BaseEvent)
	gauge_controller.connect("gauge_changed", self, "_on_gauge_changed")
	if !gauge_controller.gauge_exists("SCHOOL"):
		gauge_controller.create_gauge("SCHOOL", 0, {
			"LOWER": 0
		})
	# Wait for the next frame so all the event has been added to the event controller
	yield(get_tree(), "idle_frame")
	triggerable_school_event = event_controller.get_triggerable_event(school_construction_event)

# TODO: adjust the weight depending on popultaion/population density
func _on_gauge_changed(gauge_name, new_value, old_value):
	match gauge_name:
		"SCHOOL":
			if triggerable_school_event.weight > 1 && (new_value - old_value > 0):
				triggerable_school_event.weight -= 1
		"POPULATION":
			pass
			# TODO: use that for something...
