extends Node2D

# a more simplified version of hazard_bird

onready var _sprite : Sprite = $Sprite

const _fly_speed : float = 120.0
var _x_direction : float
var _window_size : Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/width"),
	ProjectSettings.get_setting("display/window/size/height")
)

func _ready():
	var birds_count : int = _sprite.texture.get_height() / 32
	_sprite.frame = Utility.rng.randi_range(0, birds_count-1)
	
	if Utility.rng.randi_range(0,1) == 0:
		global_position.x = -32
		_x_direction = 1
		_sprite.flip_h = true
	else:
		global_position.x = _window_size.x + 32
		_x_direction = -1
	global_position.y = Utility.rng.randf_range(0, _window_size.y)
	
	scale = Vector2.ONE * Utility.rng.randf_range(0.5, 1)

func _process(delta : float):
	global_position.x += _fly_speed * _x_direction * delta
	
	if ((_x_direction == -1 && global_position.x < 0) ||
	(_x_direction == 1 && global_position.x > _window_size.x)):
		queue_free()
