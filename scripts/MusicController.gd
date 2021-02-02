class_name MusicController
extends Node

export(float) var main_volume := -20.0
export(float) var reduced_volume := -35.0

onready var turn_controller := TurnController.get_instance(get_tree())

static func get_instance(scene_tree: SceneTree) -> MusicController:
	# Not using GlobalObject.get_instance because cyclic reference
	return scene_tree.get_current_scene().get_node("GlobalObject/MusicController") as MusicController

func _ready():
	turn_controller.connect("turn_changed", self, "_on_turn_changed")

func play_main_music() -> void:
	$MainMusic.play()
	
func play_event_sound_effect() -> void:
	$EventSoundEffect.play()
	
func play_turn_sound_effect() -> void:
	$TurnSoundEffect.play()
	
func reduce_volume() -> void:
	$MainMusic.volume_db = reduced_volume

func normal_volume() -> void:
	$MainMusic.volume_db = main_volume

func _on_turn_changed(_turn_number, _miniturn_number):
	play_turn_sound_effect()
