extends Control

onready var _back_btn : TextureButton = $Back

# TODO: in the animation the stop at around 23 seconds aligns with the text
#       in the editor, but not in the window

func _input(event : InputEvent):
	if event.is_action_pressed("back"):
		SceneManager.change_scene("res://scenes/game/menu.tscn")

func _on_back_pressed():
	SceneManager.change_scene("res://scenes/game/menu.tscn")

func _on_animation_finished(anim_name):
	if anim_name == "main":
		_back_btn.show()
