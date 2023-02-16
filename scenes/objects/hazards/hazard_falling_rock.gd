class_name HazardFallingRock
extends KinematicBody2D

onready var _sprite : Sprite = $Sprite

var _fall_speed : float
var _bottom_y : float


func setup(view_size : Vector2, min_speed : float, max_speed : float):
	global_position = Vector2(
		Utility.rng.randi_range(0, view_size.x),
		-_sprite.texture.get_height()
	)
	_bottom_y = view_size.y
	_fall_speed = Utility.rng.randf_range(min_speed, max_speed)

func _process(delta : float):
	rotation_degrees += _fall_speed * delta
	move_and_collide(Vector2(0, _fall_speed) * delta)
	
	if position.y > _bottom_y:
		queue_free()
