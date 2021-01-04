class_name BarEffect
# This is a simple action that will apply a difference on one of the bars

# MAKE SURE THIS DOES NOT NEED TO BE DUPLICATED IF IT'S  a RESOURCE
# As in, it should be stateless, and everything it needs should be passed as a parameter
# This is needed because the event resources are not duplicated with their sub-resources

# To limit the number, use
# export(int, MINVALUE, MAXVALUE)
export(int) var amount: int = 0

# This will map in the same order as the enum GlobalObject.bars
export(int, "Health", "Satisfaction", "Nature", "Stress", "Budget") var affectedBar

func apply():
	# Use a function from the eventController or the game state to update
	# the bars
	pass
