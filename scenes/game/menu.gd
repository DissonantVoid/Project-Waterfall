extends MarginContainer

onready var _next_bird_timer : Timer = $NextBirdTimer
onready var _birds_container : Node2D = $Birds

const _bird_scene : PackedScene = preload("res://scenes/objects/main_menu/dummy_bird.tscn")

const _min_bird_time : float = 1.0
const _max_bird_time : float = 2.5


func _on_start_pressed():
	SceneManager.change_scene("res://scenes/game/introduction.tscn")

func _on_credits_pressed():
	SceneManager.change_scene("res://scenes/game/credits.tscn")

func _on_quit_pressed():
	get_tree().quit(0)

func _on_next_bird_timeout():
	var bird_instance := _bird_scene.instance()
	_birds_container.add_child(bird_instance)
	
	_next_bird_timer.wait_time = Utility.rng.randf_range(_min_bird_time, _max_bird_time)
	_next_bird_timer.start()
