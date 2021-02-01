#class_name MusicController
extends Node

#static func get_instance(scene_tree: SceneTree) -> MusicController:
#	# Not using GlobalObject.get_instance because cyclic reference
#	return scene_tree.get_current_scene().get_node("GlobalObject/MusicController") as MusicController

func play_main_music():
	$MainMusic.play()
	
func stop_main_music():
	$MainMusic.stop()

func play_event_sound_effect():
	$EventSoundEffect.play()

func stop_event_sound_effect():
	$EventSoundEffect.stop()

