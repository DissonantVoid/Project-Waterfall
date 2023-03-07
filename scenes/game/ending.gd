extends Node2D


func _input(event : InputEvent):
	if event.is_action_pressed("skip"):
		SceneManager.change_scene("res://scenes/game/credits.tscn")

func _on_animation_finished(anim_name : String):
	if anim_name == "full":
		SceneManager.change_scene("res://scenes/game/credits.tscn")
