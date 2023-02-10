extends Control


func _on_start_pressed():
	SceneManager.change_scene("res://scenes/game/introduction.tscn")

func _on_credits_pressed():
	pass # TODO

func _on_quit_pressed():
	get_tree().quit(0)
