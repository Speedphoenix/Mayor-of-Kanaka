extends Resource

class_name BaseEvent

# There are two types of possible events, decisions an non interactive events
# Both of those will inherit BaseEvent

export(String) var title: String
export(String, MULTILINE) var description: String
