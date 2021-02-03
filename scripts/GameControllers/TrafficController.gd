extends Node

export(PackedScene) var car_scene

export(float) var min_roads_per_car := 10.0
export(int) var min_population_per_car := 10

var current_cars := []

onready var gauge_controller := GaugeController.get_instance(get_tree())
onready var city_map := CityMap.get_instance(get_tree())

func _ready():
	assert(car_scene.can_instance())
	gauge_controller.connect("gauge_changed", self, "_on_gauge_changed")

func _on_gauge_changed(gauge_name: String, new_value: float, _old_value):
	if gauge_name != "POPULATION":
		return
	var current_car_count = current_cars.size() if current_cars.size() >= 1 else 1
	var population_car_ratio: float = new_value / current_car_count
	if population_car_ratio < min_population_per_car:
		return
	var possible_roads: Array = city_map.get_drivable_roads()
	if float(possible_roads.size()) / current_car_count < min_roads_per_car:
		return
	var new_car: Node2D = car_scene.instance()
	city_map.traffic_layer.add_child(new_car)
	new_car.initialize(WeightChoice.choose_random_from_array(possible_roads))
	current_cars.append(new_car)
