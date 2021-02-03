extends Label

var test_dictionary = {
	"HEALTH": 50,
	"SATISFACTION": 50,
}

func _ready():
#	print("HEALTH" in test_dictionary)
#	print("Health" in test_dictionary)
#	for key in test_dictionary:
#		print(key)
#	for i in range(0, 100):
#		print(ease(float(i) / 100, 0.5))
#	print(yield(test_func(), "completed"))
	pass

func test_func() -> float:
	yield($"../Button", "button_down")
	return 5

func showmachin(newturn, newday = 1):
	text = str(newturn) + " " + str(newday)

func pauseit():
	get_node("../GlobalObject/TurnController").pause_turns()

func resumeit():
	get_node("../GlobalObject/TurnController").resume_turns()

func _on_GaugeController_gauge_changed(gauge_name: String, new_value: int, old_value: int):
	pass
#	print("gauge ", gauge_name, " has now this value ", new_value)


func _on_GaugeController_gauges_changed(new_gauges: Dictionary, old_gauges: Dictionary):
	pass
#	print("the gauges as a whole have changed")
