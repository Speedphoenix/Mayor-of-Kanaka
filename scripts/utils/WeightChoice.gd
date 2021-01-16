class_name WeightChoice
extends Reference

static func choose_by_weight(tab: Array) -> Dictionary:
	var bag := []
	for el in tab:
		for i in range(el.weight):
			bag.append(el)
	if bag.empty():
		return {}
	bag.shuffle()
	return bag[0]

func _ready():
	pass
