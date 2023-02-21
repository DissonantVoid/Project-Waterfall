extends Control

onready var _back_btn : TextureButton = $Back
onready var _music_player : AudioStreamPlayer = $Music

const _loop_music : AudioStream = preload("res://resources/music/credits loop.mp3")

# TODO: there is a problematic difference in how the text is displayed in editor
#       vs in window, which leads to text stopping at different position in
#       the animation where we reach the play button
#       this is due to oversampling (rendering/quality/dynamic_fonts/use_oversampling)
#       we can disable oversampling for the entire project but it would make text ugly
#       we need someway to enable it in the editor, or some other workaround
#       if nothing works, we'll have to brute force it until we get the right
#       text position

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
