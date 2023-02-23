extends Control

onready var _anim_player : AnimationPlayer = $AnimationPlayer
onready var _camera_anim_player : AnimationPlayer = $Camera2D/AnimationPlayer
onready var _next_button : TextureButton = $Next

var _next_animation_name : String


func _ready():
	_next_button.hide()

func _input(event : InputEvent):
	if event.is_action_pressed("back"):
		SceneManager.change_scene("res://scenes/game/main.tscn")

func _on_animation_finished(anim_name : String):
	# predict next animation name by adding 1 to the frame number
	var num_index : int = anim_name.length()-1
	var num : int = int(anim_name[num_index])
	_next_animation_name = anim_name.substr(0, num_index) + str(num+1)
	_next_button.show()

func _set_shake(should_shake : bool):
	if should_shake:
		_camera_anim_player.play("natural_shake")
	else:
		_camera_anim_player.play("RESET")

func _on_next_button_pressed():
	# if the animation we predicted exists, play it
	# otherwise we've reached the last frame
	if _anim_player.has_animation(_next_animation_name):
		_anim_player.play(_next_animation_name)
	else:
		SceneManager.change_scene("res://scenes/game/main.tscn")
	_next_button.hide()
