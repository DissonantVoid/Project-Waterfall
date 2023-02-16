extends Control

onready var _anim_player : AnimationPlayer = $AnimationPlayer
onready var _camera_anim_player : AnimationPlayer = $Camera2D/AnimationPlayer


func _on_animation_finished(anim_name : String):
	# predict next animation name by adding 1 to the frame number
	var num_index : int = anim_name.length()-1
	var num : int = int(anim_name[num_index])
	var next_anim_name : String = anim_name.substr(0, num_index) + str(num+1)
	
	# if the animation we predicted exists, play it
	# otherwise we've reached the last frame
	if _anim_player.has_animation(next_anim_name):
		_anim_player.play(next_anim_name)
	else:
		SceneManager.change_scene("res://scenes/game/main.tscn")

func _set_shake(should_shake : bool):
	if should_shake:
		_camera_anim_player.play("natural_shake")
	else:
		_camera_anim_player.play("RESET")
