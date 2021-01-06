class_name GameParameters
extends Resource
# A resource to contain all parameters defining a game 
#
# This should contain elements that are specific to the current game
# For example:
# - The initial possible events
# - The initial size of the city
# - The difficulty level, if it applies

export(Array, Resource) var initial_possible_events = []
