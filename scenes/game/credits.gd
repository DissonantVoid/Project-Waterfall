extends Control

onready var _back_btn : TextureButton = $Back
onready var _music_player : AudioStreamPlayer = $Music

const _loop_music : AudioStream = preload("res://resources/music/credits loop.mp3")

# TODO: now that we no longer use a RichTextLabel we can put
#       text on top of images, so there is no need for the images in
#       res://resources/textures/credits/

func _input(event : InputEvent):
	if event.is_action_pressed("back"):
		SceneManager.change_scene("res://scenes/game/menu.tscn")

func _on_back_pressed():
	SceneManager.change_scene("res://scenes/game/menu.tscn")

func _on_animation_finished(anim_name):
	if anim_name == "main":
		_back_btn.show()

func _on_music_finished():
	_music_player.stream = _loop_music
	_music_player.play()
