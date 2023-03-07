extends Control

onready var _back_btn : TextureButton = $Back
onready var _music_player : AudioStreamPlayer = $Music

const _loop_music : AudioStream = preload("res://resources/music/credits loop.mp3")


func _input(event : InputEvent):
	if event.is_action_pressed("skip"):
		SceneManager.change_scene("res://scenes/game/menu.tscn")

func _on_back_pressed():
	SceneManager.change_scene("res://scenes/game/menu.tscn")

func _on_animation_finished(anim_name):
	if anim_name == "main":
		_back_btn.show()

func _on_music_finished():
	_music_player.stream = _loop_music
	_music_player.play()
