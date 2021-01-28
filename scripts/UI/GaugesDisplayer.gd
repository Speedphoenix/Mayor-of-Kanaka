extends CanvasLayer


onready var gauge_controller := GaugeController.get_instance(get_tree())
onready var turn_controller := TurnController.get_instance(get_tree())
export(bool) var gaugesAsBars := false
# TODO: use a tween to make the changes animated (except the first one)

# Called when the node enters the scene tree for the first time.
func _ready():
	gauge_controller.connect("gauge_changed", self, "_on_gauge_changed")
	gauge_controller.connect("expected_diff_changed", self, "_on_expected_gauge_diff_changed")
	turn_controller.connect("turn_changed", self, "_on_turn_changed")

	var curr_gauges := gauge_controller.get_gauges()
	# Setting the bars' initial values
	$BarsController/Budget/BudgetBar.value = curr_gauges.BUDGET
	$BarsController/Health/HealthBar.value = curr_gauges.HEALTH
	$BarsController/Nature/NatureBar.value = curr_gauges.NATURE
	$BarsController/Satisfation/SatisfactionBar.value = curr_gauges.SATISFACTION
	$BarsController/Stress/StressBar.value = curr_gauges.STRESS
	
	$BarsController/Budget/BudgetLabel.text = str(curr_gauges.BUDGET) + "k $"
	$BarsController/Health/HealthLabel.text = str(curr_gauges.HEALTH) + " %"
	$BarsController/Nature/NatureLabel.text = str(curr_gauges.NATURE) + " %"
	$BarsController/Satisfation/SatisfactionLabel.text = str(curr_gauges.SATISFACTION) + " %"
	$BarsController/Stress/StressLabel.text = str(curr_gauges.STRESS) + " %"
	
	if gaugesAsBars:
		$BarsController/Budget/BudgetLabel.hide()
		$BarsController/Health/HealthLabel.hide()
		$BarsController/Nature/NatureLabel.hide()
		$BarsController/Satisfation/SatisfactionLabel.hide()
		$BarsController/Stress/StressLabel.hide()
		
		$BarsController/Budget/BudgetBar.show()
		$BarsController/Health/HealthBar.show()
		$BarsController/Nature/NatureBar.show()
		$BarsController/Satisfation/SatisfactionBar.show()
		$BarsController/Stress/StressBar.show()
	else:
		$BarsController/Budget/BudgetBar.hide()
		$BarsController/Health/HealthBar.hide()
		$BarsController/Nature/NatureBar.hide()
		$BarsController/Satisfation/SatisfactionBar.hide()
		$BarsController/Stress/StressBar.hide()
		
		$BarsController/Budget/BudgetLabel.show()
		$BarsController/Health/HealthLabel.show()
		$BarsController/Nature/NatureLabel.show()
		$BarsController/Satisfation/SatisfactionLabel.show()
		$BarsController/Stress/StressLabel.show()


func _on_gauge_changed(gauge_name, new_value, _old_value):
	match gauge_name:
		"BUDGET":
			$BarsController/Budget/BudgetBar.value = new_value
			$BarsController/Budget/BudgetLabel.text = str(new_value) + "k $"
		"HEALTH":
			$BarsController/Health/HealthBar.value = new_value
			$BarsController/Health/HealthLabel.text = str(new_value) + " %"
		"SATISFACTION":
			$BarsController/Satisfation/SatisfactionBar.value = new_value
			$BarsController/Satisfation/SatisfactionLabel.text = str(new_value) + " %"
		"NATURE":
			$BarsController/Nature/NatureBar.value = new_value
			$BarsController/Nature/NatureLabel.text = str(new_value) + " %"
		"STRESS":
			$BarsController/Stress/StressBar.value = new_value
			$BarsController/Stress/StressLabel.text = str(new_value) + " %"

func _on_expected_gauge_diff_changed(gauge_name, new_value):
	print("expecting the next turn to cause a difference of ", new_value,
			" on gauge ", gauge_name)

func _on_turn_changed(_turn_number, _miniturn_number):
	# TODO: reset/hide the stuff concerning the expected changes
	pass
