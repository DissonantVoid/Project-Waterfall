extends Node2D

onready var _camera_anim_player : AnimationPlayer = $Camera2D/AnimationPlayer


func _input(event : InputEvent):
	if event.is_action_pressed("back"):
		SceneManager.change_scene("res://scenes/game/main.tscn")

func _on_animation_finished(anim_name : String):
	if anim_name == "full":
		SceneManager.change_scene("res://scenes/game/main.tscn")

func _set_shake(should_shake : bool):
	if should_shake:
		_camera_anim_player.play("natural_shake")
	else:
		_camera_anim_player.play("RESET")
