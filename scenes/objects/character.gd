class_name Character
extends RigidBody2D

onready var _sprite : Sprite = $Sprite

const _shine_shader : ShaderMaterial = preload("res://resources/godot/shine_shader.tres")
const _collision_layers_out_of_bucket : int = 0b11
const _collision_layers_in_bucket : int = 0b101
const _max_speed_normal : float = 222.0
const _max_speed_in_bucket : float = 1300.0
var _max_speed : float = _max_speed_normal

const _char_sprite_size : int = 16
var _curr_character_idx : int
var _slowed : bool = false

# in the same order as the sprite sheet
const _sounds_per_character : Array = [
	{"spawn":"characters/default_spawn", "saved":"", "fall":""},
	{"spawn":"characters/default_spawn", "saved":"", "fall":""},
	{"spawn":"characters/vgamer_spawn", "saved":"", "fall":"characters/vgamer_fall"},
	{"spawn":"characters/default_spawn", "saved":"", "fall":""},
	{"spawn":"characters/default_spawn", "saved":"", "fall":""},
	{"spawn":"characters/default_spawn", "saved":"", "fall":""},
	{"spawn":"characters/default_spawn", "saved":"", "fall":""},
	{"spawn":"characters/default_spawn", "saved":"", "fall":""},
	{"spawn":"characters/default_spawn", "saved":"", "fall":""},
	{"spawn":"characters/default_spawn", "saved":"", "fall":""},
	{"spawn":"characters/default_spawn", "saved":"", "fall":""},
	{"spawn":"characters/default_spawn", "saved":"", "fall":""},
	{"spawn":"characters/default_spawn", "saved":"", "fall":""},
	{"spawn":"characters/default_spawn", "saved":"", "fall":""},
	{"spawn":"characters/default_spawn", "saved":"", "fall":""},
	{"spawn":"characters/default_spawn", "saved":"", "fall":""},
	{"spawn":"characters/default_spawn", "saved":"", "fall":""},
	{"spawn":"characters/default_spawn", "saved":"", "fall":""},
]


func _ready():
	var characters_count : int = _sprite.texture.atlas.get_width() / _char_sprite_size
	_curr_character_idx = Utility.rng.randi_range(0, characters_count-1)
	_sprite.texture.region.position.x = _curr_character_idx * _char_sprite_size
	
	apply_central_impulse(Vector2(Utility.rng.randf_range(-100, 100), 0))
	AudioManager.play_sound(
		_sounds_per_character[_curr_character_idx]["spawn"], true
	)

func _physics_process(delta : float):
	# speed limit
	if abs(linear_velocity.x) > _max_speed:
		linear_velocity.x = _max_speed * sign(linear_velocity.x)
	if abs(linear_velocity.y) > _max_speed:
		linear_velocity.y = _max_speed * sign(linear_velocity.y)
	
	if Utility._is_slow and not _slowed:
		linear_velocity.x *= Utility._slowing_factor
		linear_velocity.y *= Utility._slowing_factor
		_max_speed *= Utility._slowing_factor
		_slowed = true
	if not Utility._is_slow and _slowed:
		linear_velocity.x /= Utility._slowing_factor
		linear_velocity.y /= Utility._slowing_factor
		_max_speed /= Utility._slowing_factor
		_slowed = false


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

func get_texture() -> Texture:
	return _sprite.texture
