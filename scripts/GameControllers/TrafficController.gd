class_name TrafficController
extends Node

export(Array, PackedScene) var car_scenes := []

export(float) var min_roads_per_car := 10.0
export(float) var min_population_per_car := 10.0

var current_vehicles := []

onready var gauge_controller := GaugeController.get_instance(get_tree())
onready var city_map := CityMap.get_instance(get_tree())

static func get_instance(scene_tree: SceneTree) -> TrafficController:
	return scene_tree.get_current_scene().get_node("GlobalObject/GameControllers/TrafficController") as TrafficController

func _ready():
	assert(car_scenes.size() != 0)
	for el in car_scenes:
		assert(el.can_instance())
	gauge_controller.connect("gauge_changed", self, "_on_gauge_changed")

# Using force = false will respect the min_roads_per_car ratio
func add_traffic_element(what: PackedScene, force := true) -> void:
	var possible_roads: Array = city_map.get_drivable_roads()
	var current_car_count = current_vehicles.size() if current_vehicles.size() >= 1 else 1
	if !force && float(possible_roads.size()) / current_car_count < min_roads_per_car:
		return
	var instanced = what.instance()
	
	city_map.traffic_layer.add_child(instanced)
	var chosen_pos: Vector2 = WeightChoice.choose_random_from_array(possible_roads)
	instanced.initialize(chosen_pos)
	current_vehicles.append(instanced)

func _on_gauge_changed(gauge_name: String, new_value: float, _old_value):
	if gauge_name != "POPULATION":
		return
	var current_car_count = current_vehicles.size() if current_vehicles.size() >= 1 else 1
	var population_car_ratio: float = new_value / current_car_count
	if population_car_ratio < min_population_per_car:
		return
	add_traffic_element(WeightChoice.choose_random_from_array(car_scenes), false)
