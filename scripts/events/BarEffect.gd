class_name BarEffect
# This is a simple action that will apply a difference on one of the bars

# To limit the number, use
# export(int, MINVALUE, MAXVALUE)
export(int) var amount: int = 0

# This will map in the same order as the enum GlobalObject.bars
export(int, "Health", "Satisfaction", "Nature", "Stress", "Budget") var affectedBar

func apply():
	# Use a function from the eventController or the game state to update
	# the bars
	pass
