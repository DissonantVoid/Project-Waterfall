class_name HazardBird
extends Area2D

onready var _sprite : Sprite = $Sprite
onready var _warning_sprite : Sprite = $Warning
onready var _collider : CollisionShape2D = $CollisionShape2D

var _speed : float
var _direction : Vector2
var _x_edges : Vector2
var _is_moving : bool = false

func setup(view_size : Vector2, min_speed : float, max_speed : float):
	var view_25_percent : Vector2 = Vector2(lerp(0, view_size.x, 0.25), lerp(0, view_size.y, 0.25))
	global_position.y = Utility.rng.randi_range(0, view_size.y - view_25_percent.y)
	if Utility.rng.randi_range(0,1) == 0:
		_direction = Vector2.LEFT
		global_position.x = view_size.x
	else:
		_direction = Vector2.RIGHT
		global_position.x = 0
		_sprite.flip_h = true
	
	_speed = Utility.rng.randf_range(min_speed, max_speed)
	_x_edges = Vector2(0, view_size.x)
	
	# warn before showing the bird
	# TODO: feels hacky, maybe hazard_maker should do this for rocks and birds
	_sprite.hide()
	_warning_sprite.show()
	_warning_sprite.global_position.x = clamp(_warning_sprite.global_position.x, 32, view_size.x-32)
	_collider.disabled = true
	yield(get_tree().create_timer(2), "timeout")
	
	_sprite.show()
	_warning_sprite.hide()
	_collider.disabled = false
	_is_moving = true

func _process(delta):
	if _is_moving:
		global_position += _direction * _speed * delta
		if global_position.x < _x_edges[0] || global_position.x > _x_edges[1]:
			queue_free()
