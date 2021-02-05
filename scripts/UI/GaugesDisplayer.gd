extends CanvasLayer

onready var gauge_controller := GaugeController.get_instance(get_tree())
onready var turn_controller := TurnController.get_instance(get_tree())
onready var global_object := GlobalObject.get_instance(get_tree())

# Called when the node enters the scene tree for the first time.
func _ready():
	gauge_controller.connect("gauge_changed", self, "_on_gauge_changed")
	gauge_controller.connect("expected_diff_changed", self, "_on_expected_gauge_diff_changed")
	turn_controller.connect("turn_changed", self, "_on_turn_changed")

	var curr_gauges := gauge_controller.get_gauges()

	# Setting the bars' initial values
	$BarsController/Budget.value = curr_gauges.BUDGET
	$BarsController/Health.value = curr_gauges.HEALTH
	$BarsController/Nature.value = curr_gauges.NATURE
	$BarsController/Satisfation.value = curr_gauges.SATISFACTION
	$BarsController/Stress.value = curr_gauges.STRESS
	if curr_gauges.has("POPULATION"):
		$BarsController/Population.value = curr_gauges.POPULATION


func _on_gauge_changed(gauge_name, new_value, _old_value):
	var on_gauge: Node = null
	match gauge_name:
		"BUDGET":
			on_gauge = $BarsController/Budget
		"HEALTH":
			on_gauge = $BarsController/Health
		"SATISFACTION":
			on_gauge = $BarsController/Satisfation
		"NATURE":
			on_gauge = $BarsController/Nature
		"STRESS":
			on_gauge = $BarsController/Stress
		"POPULATION":
			on_gauge = $BarsController/Population
	
	if on_gauge != null:
		if !global_object.initialization_did_finish:
			# This will NOT animate it with the tween
			on_gauge.value = new_value
		else:
			on_gauge.set_value(new_value)

func _on_expected_gauge_diff_changed(gauge_name, diff):
	match gauge_name:
		"BUDGET":
			$BarsController/Budget.set_expected_diff(diff)
		"HEALTH":
			$BarsController/Health.set_expected_diff(diff)
		"SATISFACTION":
			$BarsController/Satisfation.set_expected_diff(diff)
		"NATURE":
			$BarsController/Nature.set_expected_diff(diff)
		"STRESS":
			$BarsController/Stress.set_expected_diff(diff)

func _on_turn_changed(_turn_number, _miniturn_number):
	$BarsController/Budget.set_expected_diff(0)
	$BarsController/Health.set_expected_diff(0)
	$BarsController/Satisfation.set_expected_diff(0)
	$BarsController/Nature.set_expected_diff(0)
	$BarsController/Stress.set_expected_diff(0)
