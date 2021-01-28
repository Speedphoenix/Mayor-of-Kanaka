class_name PopulationController
extends Node

export(String) var population_gauge_name := "POPULATION"
export(float, 0, 1) var new_house_probability := 0.5
export(int) var new_house_choices_max_count := 100
export(Array, Dictionary) var houses := [
	{
		"tilename": "house",
		"dimensions": Vector2(1, 1),
		"weight": 8,
	},
	{
		"tilename": "house_long_horizontal",
		"dimensions": Vector2(2, 1),
		"weight": 1,
	},
	{
		"tilename": "house_long_vertical",
		"dimensions": Vector2(1, 2),
		"weight": 1,
	},
]

var inhabitants_per_house_size := {
	1: 2, # house takes up one tile, probably a couple
	2: 5, # two tiles, contains a family?
}

onready var turn_controller := TurnController.get_instance(get_tree())
onready var gauge_controller := GaugeController.get_instance(get_tree())
onready var city_map := CityMap.get_instance(get_tree())

static func get_instance(scene_tree: SceneTree) -> PopulationController:
	return scene_tree.get_current_scene().get_node("GlobalObject/GameControllers/PopulationController") as PopulationController

func _ready():
	turn_controller.connect("miniturn_changed", self, "_on_miniturn_changed")
	turn_controller.connect("turn_changed", self, "_on_turn_changed")
	if !gauge_controller.gauge_exists(population_gauge_name):
		gauge_controller.create_gauge(population_gauge_name, 0, {
			"LOWER": 0
		})

func add_random_houses(count: int) -> void:
	var size_diff := 0
	for _i in range(count):
		size_diff += _add_random_house()
	gauge_controller.apply_to_gauge(population_gauge_name, _inhabitant_per_size(size_diff))

# Randomly adds a house and returns its size
# (0 for no house added, 2 for a 2x1 house etc...)
func _add_random_house() -> int:
	assert(!houses.empty())
	var chosen_house: Dictionary = WeightChoice.choose_dict_by_weight(houses)
	assert(chosen_house.has("dimensions"))
	var house_dims: Vector2 = chosen_house.dimensions
	var spots := city_map.get_available_spots(house_dims, city_map.get_town_hall_position(),
			new_house_choices_max_count, CityMap.BLOCK_OVERLAP_NONE)
	if spots.size() > 0:
		var chosen_spot = WeightChoice.choose_random_from_array(spots)
		city_map.add_building(chosen_house.tilename, chosen_spot, house_dims)
		return int(house_dims.x) * int(house_dims.y)
	return 0

func _inhabitant_per_size(size: int) -> int:
	if inhabitants_per_house_size.has(size):
		return inhabitants_per_house_size[size]
	return size * 2

# TODO: add randomness (don't always add a house, add a random amount...)
func _on_miniturn_changed(_turn_number, _miniturn_number):
	if randf() <= new_house_probability:
		var size = _add_random_house()
		gauge_controller.apply_to_gauge(population_gauge_name, _inhabitant_per_size(size))

func _on_turn_changed(_turn_number, _miniturn_number):
	var size = _add_random_house()
	gauge_controller.apply_to_gauge(population_gauge_name, _inhabitant_per_size(size))
