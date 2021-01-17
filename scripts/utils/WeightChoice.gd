class_name WeightChoice
extends Reference

# Takes an array of weights
# returns an array of chosen indices
# Note that the returned array may be smaller than count if the total weight of tab is too small
# Also note that an element cannot be chosen multiple times
# If an element can be chosen multiple times, include it in the input Array tab
static func choose_by_weight(tab: Array, count := 1) -> Array:
	assert(!tab.empty())
	var tab_dup = tab.duplicate()
	var full_weight := 0
	var rep := []
	for el in tab_dup:
		assert(el >= 0)
		full_weight += el
	for i in range(count):
		var rand_pos: int = randi() % full_weight
		var index: int = 0
		while rand_pos > 0 && index < tab_dup.size():
			rand_pos -= tab_dup[index]
			if rand_pos >= 0:
				index += 1
		if index > tab_dup.size():
			break
		rep.append(index)
		full_weight -= tab_dup[index]
		tab_dup[index] = 0
	return rep

# Takes an array of dicts containing a weight attribute
# Returns an array of weights
static func get_weights_from_dicts(tab: Array) -> Array:
	var rep := []
	for el in tab:
		rep.append(el.weight)
	return rep

static func choose_dict_by_weight(tab: Array) -> Dictionary:
	var hey := choose_by_weight(get_weights_from_dicts(tab), 1)
	return tab[hey[0]]

static func choose_random_from_array(tab: Array):
	return tab[randi() % tab.size()]
