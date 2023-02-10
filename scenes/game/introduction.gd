extends Control


func _on_animation_finished(anim_name):
	SceneManager.change_scene("res://scenes/game/main.tscn")
