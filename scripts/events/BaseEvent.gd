class_name BaseEvent
extends Resource


# There are two types of possible events, decisions an non interactive events
# Both of those will inherit BaseEvent

export(String) var title: String
export(String, MULTILINE) var description: String

# 0 means it will expire at the end of the current turn
export(int) var active_duration: int = 0
