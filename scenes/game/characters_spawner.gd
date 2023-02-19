extends Node2D

onready var _chars_container : Node2D = $Characters
onready var _spawn_timer : Timer = $SpawnTimer

const _character_scene : PackedScene = preload("res://scenes/objects/character.tscn")

const _pulse_force : float = 420.0
var _spawn_time : float

var _view_size : Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/width"),
	ProjectSettings.get_setting("display/window/size/height")
) * 2


func _ready():
	_spawn_timer.start()

func update_rules(time_between_spawn : float):
	_spawn_time = time_between_spawn
	_spawn_timer.wait_time = _spawn_time / LevelData.time_factor

func do_pulse():
	# push character along with the pulse
	for character in _chars_container.get_children():
		var x_direction : float = character.global_position.x - _view_size.x/2
		character.apply_central_impulse(Vector2(x_direction * _pulse_force, 0))

func _on_spawn_timeout():
	var instance := _character_scene.instance()
	_chars_container.add_child(instance)
	instance.global_position = Vector2(Utility.rng.randf_range(0, _view_size.x), -10)
	
	_spawn_timer.wait_time = _spawn_time / LevelData.time_factor
	_spawn_timer.start()
