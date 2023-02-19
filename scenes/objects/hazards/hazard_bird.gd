class_name HazardBird
extends Area2D

onready var _sprite : AnimatedSprite = $Sprite
onready var _held_character_sprite : Sprite = $HeldCharacter
onready var _warning_sprite : Sprite = $Warning
onready var _collider : CollisionShape2D = $CollisionShape2D

const _warning_time : float = 2.0
var _speed : float
var _direction : Vector2
var _x_edges : Vector2
var _is_moving : bool = false
var _is_holding_character : bool = false
var _slowed : bool = false


func setup(view_size : Vector2, min_speed : float, max_speed : float):
	var y_25_percent : float = lerp(0, view_size.y, 0.25)
	var end_position : Vector2
	global_position.y = Utility.rng.randi_range(0, view_size.y - y_25_percent)
	if Utility.rng.randi_range(0,1) == 0:
		end_position.x = 0
		global_position.x = view_size.x
	else:
		end_position.x = view_size.x
		global_position.x = 0
		_sprite.flip_h = true
	
	end_position.y = Utility.rng.randi_range(0, view_size.y - y_25_percent)
	
	_direction = (end_position - global_position).normalized()
	_speed = Utility.rng.randf_range(min_speed, max_speed)
	_x_edges = Vector2(0, view_size.x)
	
	# warn before showing the bird
	# TODO: feels hacky, maybe hazards_maker.gd should do this for rocks and birds
	_sprite.hide()
	_warning_sprite.show()
	_warning_sprite.global_position.x = clamp(_warning_sprite.global_position.x, 32, view_size.x-32)
	_collider.disabled = true
	yield(get_tree().create_timer(_warning_time), "timeout")
	
	_sprite.show()
	_warning_sprite.hide()
	_collider.disabled = false
	_is_moving = true

func _process(delta : float):
	if _is_moving:
		_check_slowing()
		global_position += _direction * _speed * delta
		if global_position.x < _x_edges[0] || global_position.x > _x_edges[1]:
			queue_free()

func _on_body_entered(body):
	if body is Character && _is_holding_character == false:
		body.queue_free()
		_speed *= 2.0
		_held_character_sprite.texture = body.get_texture()
		_is_holding_character = true
	elif body is HazardFallingRock:
		body.queue_free()

func _check_slowing():
	if TimeManipulator._is_slow and not _slowed:
		_speed *= TimeManipulator._slowing_factor
		_slowed = true
	if not TimeManipulator._is_slow and _slowed:
		_speed /= TimeManipulator._slowing_factor
		_slowed = false
