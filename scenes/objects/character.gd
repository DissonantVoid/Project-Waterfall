class_name Character
extends RigidBody2D

onready var _sprite : Sprite = $Sprite

const _shine_shader : ShaderMaterial = preload("res://resources/godot/shine_shader.tres")
const _collision_layers_out_of_bucket : int = 0b11
const _collision_layers_in_bucket : int = 0b101
const _max_speed_normal : float = 222.0
const _max_speed_in_bucket : float = 500.0
var _max_speed : float = _max_speed_normal

const _char_count : int = 15 # how many characters are in the sprite sheet
const _char_sprite_size : int = 16


func _ready():
	var char_index : int = Utility.rng.randi_range(0, _char_count-1) * _char_sprite_size
	_sprite.region_rect.position.x = char_index
	
	apply_central_impulse(Vector2(Utility.rng.randf_range(-100, 100), 0))

func _physics_process(delta):
	# speed limit
	if abs(linear_velocity.x) > _max_speed:
		linear_velocity.x = _max_speed * sign(linear_velocity.x)
	if abs(linear_velocity.y) > _max_speed:
		linear_velocity.y = _max_speed * sign(linear_velocity.y) 

func bucket_interacted(is_inside : bool):
	if is_inside:
		collision_mask = _collision_layers_in_bucket
		_max_speed = _max_speed_in_bucket
		set_material(_shine_shader)
	else:
		collision_mask = _collision_layers_out_of_bucket
		_max_speed = _max_speed_normal
		set_material(null)

func set_material(material : Material):
	_sprite.material = material
