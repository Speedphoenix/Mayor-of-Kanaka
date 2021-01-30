class_name BaseEvent
extends Resource


# There are two types of possible events, decisions an non interactive events
# Both of those will inherit BaseEvent

export(String) var title: String
export(String, MULTILINE) var description: String

# 0 means it will expire at the end of the current turn
export(int) var active_duration: int = 0

# This could be 'open letter' or 'dismiss letter' for example
export(String) var accept_msg := "Accept"
export(String) var refuse_msg := "Refuse"

export(int) var weight := 1

# The number of *other* event triggers over which the weight of *this* event 
# eases back to normal after it has been triggered
#
# For example, with an ease duration of 10, after having been triggered
# the next 9 random event triggers will have reduced chances of picking this one
export(int) var weight_ease_duration := 5
# This will be passed as second parameter to the ease function
export(float) var weight_ease_exponent: float = 4

# -1 to trigger as many times as needed,
# a positive value to define how many times it should be triggered at most
export(int) var available_trigger_count := -1

# supposed to contain a dependable event
export(Resource) var depending_event

# These functions should be overridden

# Called when the event is created, before the player has interracted with it
func on_triggered(_scene_tree: SceneTree) -> void:
	pass

func on_accepted(_scene_tree: SceneTree) -> void:
	pass
	
func on_refused(_scene_tree: SceneTree) -> void:
	pass

func on_expired(_scene_tree: SceneTree) -> void:
	pass

# Returns true if the event can be accepted (eg The current budget is sufficient)
func can_accept(_scene_tree: SceneTree) -> bool:
	return true
