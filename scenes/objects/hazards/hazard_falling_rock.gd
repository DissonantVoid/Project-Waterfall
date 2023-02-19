class_name HazardFallingRock
extends KinematicBody2D

onready var _sprite : Sprite = $Sprite

var _fall_speed : float
var _bottom_y : float
var _slowed : bool = false


func setup(view_size : Vector2, min_speed : float, max_speed : float):
	global_position = Vector2(
		Utility.rng.randi_range(0, view_size.x),
		-_sprite.texture.get_height()
	)
	_bottom_y = view_size.y
	_fall_speed = Utility.rng.randf_range(min_speed, max_speed)

func _process(delta : float):
	_check_slowing()
	rotation_degrees += _fall_speed * delta
	move_and_collide(Vector2(0, _fall_speed) * delta)
	
	if position.y > _bottom_y:
		queue_free()

func _check_slowing():
	if TimeManipulator._is_slow and not _slowed:
		_fall_speed *= TimeManipulator._slowing_factor
		_slowed = true
	if not TimeManipulator._is_slow and _slowed:
		_fall_speed /= TimeManipulator._slowing_factor
		_slowed = false
