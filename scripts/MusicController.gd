class_name MusicController
extends Node

onready var turn_controller := TurnController.get_instance(get_tree())

static func get_instance(scene_tree: SceneTree) -> MusicController:
	# Not using GlobalObject.get_instance because cyclic reference
	return scene_tree.get_current_scene().get_node("GlobalObject/MusicController") as MusicController

func _ready():
	turn_controller.connect("turn_changed", self, "_on_turn_changed")

func play_main_music():
	$MainMusic.play()
	
func play_event_sound_effect():
	$EventSoundEffect.play()
	
func play_turn_sound_effect():
	$TurnSoundEffect.play()
	
func reduce_volume():
	$MainMusic.volume_db = -35.0

func normal_volume():
	$MainMusic.volume_db = -20.0

func _on_turn_changed(_turn_number, _miniturn_number):
	play_turn_sound_effect()
