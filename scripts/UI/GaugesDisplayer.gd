extends CanvasLayer


onready var gauge_controller := GaugeController.get_gauge_controller(get_tree())

# TODO: use a tween to make the changes animated (except the first one)

# Called when the node enters the scene tree for the first time.
func _ready():
	gauge_controller.connect("gauge_changed", self, "_on_gauge_changed")

	var curr_gauges := gauge_controller.get_gauges()
	# Setting the bars' initial values
	$BarsController/Budget/BudgetBar.value = curr_gauges.BUDGET

	$BarsController/Health/HealthBar.value = curr_gauges.HEALTH
	$BarsController/Nature/NatureBar.value = curr_gauges.NATURE
	$BarsController/Satisfation/SatisfactionBar.value = curr_gauges.SATISFACTION
#	$BarsController/Stress/StressBar.value = curr_gauges.STRESS

func _on_gauge_changed(gauge_name, new_value, old_value):
	match gauge_name:
		"BUDGET":
			$BarsController/Budget/BudgetBar.value = new_value
		"HEALTH":
			$BarsController/Health/HealthBar.value = new_value
		"SATISFACTION":
			$BarsController/Satisfation/SatisfactionBar.value = new_value
		"NATURE":
			$BarsController/Nature/NatureBar.value = new_value
		"STRESS":
#			$BarsController/Stress/StressBar.value = new_value
			pass
