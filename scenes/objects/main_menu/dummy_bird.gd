extends Node2D

# a more simplified version of hazard_bird

onready var _sprite : Sprite = $Sprite

const _fly_speed : float = 120.0
var _x_direction : float
var _window_size : Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/width"),
	ProjectSettings.get_setting("display/window/size/height")
)

# TODO: pick random bird sprite n animate
func _ready():
	if Utility.rng.randi_range(0,1) == 0:
		global_position.x = -32
		_x_direction = 1
		_sprite.flip_h = true
	else:
		global_position.x = _window_size.x + 32
		_x_direction = -1
	global_position.y = Utility.rng.randf_range(0, _window_size.y)

func _process(delta : float):
	global_position.x += _fly_speed * _x_direction * delta
	
	if ((_x_direction == -1 && global_position.x < 0) ||
	(_x_direction == 1 && global_position.x > _window_size.x)):
		queue_free()
