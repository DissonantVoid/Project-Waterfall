extends Node2D

#TODO: maybe clouds should manage themselves without main.gd just like bucket
 
signal Passed

onready var _sprite : Sprite = $Sprite

const _cloud_spr_count : int = 4
const _half_cloud_size : Vector2 = Vector2(72,32)

var _spawn_bounds : Dictionary = {
	"x":Vector2(-_half_cloud_size.x,ProjectSettings.get_setting("display/window/size/width")+_half_cloud_size.x),
	"y":Vector2(_half_cloud_size.y,ProjectSettings.get_setting("display/window/size/height")-_half_cloud_size.y)
}
var _direction_x : float
var _target_pos_x : float
var _is_active : bool
const _float_speed : float = 40.0

func spawn_cloud(rng : RandomNumberGenerator):
	_is_active = true
	
	_sprite.show()
	_sprite.region_rect.position.x = rng.randi_range(0,_cloud_spr_count-1) * 144
	
	if rng.randi_range(0,1) == 1:
		_sprite.global_position.x = _spawn_bounds["x"][0]
		_direction_x = 1
		_target_pos_x = _spawn_bounds["x"][1]+_half_cloud_size.x
	else:
		_sprite.global_position.x = _spawn_bounds["x"][1]
		_direction_x = -1
		_target_pos_x = _spawn_bounds["x"][0]-_half_cloud_size.x
	
	_sprite.global_position.y = rng.randf_range(_spawn_bounds["y"][0],_spawn_bounds["y"][1])

func _process(delta: float) -> void:
	if _is_active == false: return
	
	global_position.x += _float_speed * _direction_x * delta
	if ( (_direction_x == 1 && global_position.x > _target_pos_x) ||
		 (_direction_x == -1 && global_position.x < _target_pos_x)):
		_is_active = false
		_sprite.hide()
		emit_signal("Passed")
