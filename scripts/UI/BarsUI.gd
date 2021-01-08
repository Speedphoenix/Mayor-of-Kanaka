extends CanvasLayer

onready var global_object: GlobalObject = get_tree().get_current_scene().get_node("GlobalObject")
onready var gauge_controller: GaugeController = global_object.get_node("GaugeController")

# TODO: use a tween to make the changes animated

# Called when the node enters the scene tree for the first time.
func _ready():
	gauge_controller.connect("gauges_changed", self, "_on_gauges_changed")
	
	var curr_gauges := gauge_controller.get_gauges()
	# Setting the bars' initial values
	$BarsController/Budget/BudgetBar.value = curr_gauges.BUDGET

	$BarsController/Health/HealthBar.value = curr_gauges.HEALTH
	$BarsController/Nature/NatureBar.value = curr_gauges.NATURE
	$BarsController/Satisfation/SatisfactionBar.value = curr_gauges.SATISFACTION
#	$BarsController/Stress/StressBar.value = curr_gauges.STRESS

func _on_gauges_changed(new_gauges: Dictionary, old_gauges: Dictionary):
	$BarsController/Budget/BudgetBar.value = new_gauges.BUDGET
	$BarsController/Health/HealthBar.value = new_gauges.HEALTH
	$BarsController/Nature/NatureBar.value = new_gauges.NATURE
	$BarsController/Satisfation/SatisfactionBar.value = new_gauges.SATISFACTION
#	$BarsController/Stress/StressBar.value = new_gauges.STRESS
