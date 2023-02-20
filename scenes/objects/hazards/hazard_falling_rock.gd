class_name HazardFallingRock
extends KinematicBody2D

onready var _sprite : Sprite = $Sprite

var _fall_speed : float


func setup(min_speed : float, max_speed : float):
	global_position = Vector2(
		Utility.rng.randi_range(0, LevelData.view_size.x),
		-_sprite.texture.get_height()
	)
	_fall_speed = Utility.rng.randf_range(min_speed, max_speed)

func _process(delta : float):
	rotation_degrees += _fall_speed * delta * LevelData.time_factor
	move_and_collide(Vector2(0, _fall_speed) * delta * LevelData.time_factor)
