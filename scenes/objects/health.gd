class_name Health
extends Node2D

var _move_speed : float
var _initial_x_position : float
const _x_offset : float = 80.0
var _x_bounds : Vector2 = Vector2(
	_x_offset,
	LevelData.view_size.x - _x_offset
)
var _x_direction : int = 1


func setup(speed : float):
	_move_speed = speed
	
	global_position = Vector2(
		Utility.rng.randf_range(_x_bounds[0], _x_bounds[1]),
		0
	)
	_initial_x_position = global_position.x
	
	if Utility.rng.randi_range(0,1) == 0:
		_x_direction = -1
	else:
		_x_direction = 1

func _process(delta):
	global_position.x += _move_speed*2 * _x_direction * delta * LevelData.time_factor
	if abs(global_position.x - _initial_x_position) >= _x_offset:
		_x_direction *= -1
	
	global_position.y += _move_speed * delta * LevelData.time_factor
