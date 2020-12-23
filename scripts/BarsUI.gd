extends CanvasLayer

onready var global = get_tree().get_current_scene().get_node("GlobalObject")
onready var bars = global.bars

# Called when the node enters the scene tree for the first time.
func _ready():
	var turnController = global.get_node("TurnController")
	#turnController.connect("miniturn_changed", self, "_on_anyturn_changed")
	turnController.connect("turn_changed", self, "_on_turn_changed")
	
	# Setting the bars initial values
	$BarsController/Budget/BudgetBar.value = bars.BUDGET
	$BarsController/Health/HealthBar.value = bars.HEALTH
	$BarsController/Nature/NatureBar.value = bars.NATURE
	$BarsController/Satisfation/SatisfactionBar.value = bars.SATISFACTION


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_event_accepted(event):
	var effects = event["effects"]["onAccepted"]
	for effectIndex in effects.size():
		var effect = effects[String(effectIndex+1)]
		var onBar = effect["onBar"]
		match onBar:
			"BUDGET":
				print("Budget affected")
				bars.BUDGET += effect["value"]
			"HEALTH":
				print("Health affected")
				bars.HEALTH += effect["value"]
			"SATISFACTION":
				print("Satisfaction affected")
				bars.SATISFACTION += effect["value"]
			"NATURE":
				print("Nature affected")
				bars.NATURE += effect["value"]

func _on_event_refused(event):
	var effects = event["effects"]["onRefused"]
	for effectIndex in effects.size():
		var effect = effects[String(effectIndex+1)]
		var onBar = effect["onBar"]
		match onBar:
			"BUDGET":
				print("Budget affected")
				bars.BUDGET += effect["value"]
			"HEALTH":
				print("Health affected")
				bars.HEALTH += effect["value"]
			"SATISFACTION":
				print("Satisfaction affected")
				bars.SATISFACTION += effect["value"]
			"NATURE":
				print("Nature affected")
				bars.NATURE += effect["value"]


func _on_event_onHold(_event):
	pass # Replace with function body.


func _on_nextTurn():
	pass
#	$BarsController/Budget/BudgetBar.value = bars.BUDGET
#	$BarsController/Health/HealthBar.value = bars.HEALTH
#	$BarsController/Nature/NatureBar.value = bars.NATURE
#	$BarsController/Satisfation/SatisfactionBar.value = bars.SATISFACTION
	
func _on_turn_changed(turn_number, miniturn_number):
	$BarsController/Budget/BudgetBar.value = bars.BUDGET
	$BarsController/Health/HealthBar.value = bars.HEALTH
	$BarsController/Nature/NatureBar.value = bars.NATURE
	$BarsController/Satisfation/SatisfactionBar.value = bars.SATISFACTION
