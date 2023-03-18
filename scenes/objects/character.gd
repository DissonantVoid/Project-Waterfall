class_name Character
extends RigidBody2D

onready var _sprite : Sprite = $Sprite
onready var _parachute_sprite : Sprite = $Parachute

const _shine_shader : ShaderMaterial = preload("res://resources/godot/shine_shader.tres")
const _collision_layers_out_of_bucket : int = 0b11
const _collision_layers_in_bucket : int = 0b101
const _max_speed_normal : float = 222.0
const _max_speed_in_bucket : float = 1300.0
const _parachute_slowdown_factor : float = 0.2
var _max_speed : float = _max_speed_normal

const _char_sprite_size : int = 16
var _curr_character_idx : int

const _character_volume : float = -4.2 # don't want a soup'o'sounds when you have bunch of characters spawning

# in the same order as the sprite sheet
const _sounds_per_character : Array = [
	{"spawn":"void_spawn", "saved":"void_saved", "fall":"void_fall"},
	{"spawn":"default_spawn", "saved":"default_saved", "fall":"default_fall"},
	{"spawn":"vgamer_spawn", "saved":"default_saved", "fall":"vgamer_fall"},
	{"spawn":"default_spawn", "saved":"default_saved", "fall":"default_fall"},
	{"spawn":"default_spawn", "saved":"default_saved", "fall":"default_fall"},
	{"spawn":"default_spawn", "saved":"default_saved", "fall":"default_fall"},
	{"spawn":"addin_spawn", "saved":"addin_saved", "fall":"addin_fall"},
	{"spawn":"default_spawn", "saved":"default_saved", "fall":"default_fall"},
	{"spawn":"default_spawn", "saved":"default_saved", "fall":"default_fall"},
	{"spawn":"default_spawn", "saved":"default_saved", "fall":"default_fall"},
	{"spawn":"default_spawn", "saved":"default_saved", "fall":"default_fall"},
	{"spawn":"default_spawn", "saved":"default_saved", "fall":"default_fall"},
	{"spawn":"default_spawn", "saved":"default_saved", "fall":"default_fall"},
	{"spawn":"default_spawn", "saved":"default_saved", "fall":"default_fall"},
	{"spawn":"aleiocus_spawn", "saved":"aleiocus_saved", "fall":"aleiocus_fall"},
	{"spawn":"default_spawn", "saved":"default_saved", "fall":"default_fall"},
	{"spawn":"default_spawn", "saved":"default_saved", "fall":"default_fall"},
	{"spawn":"default_spawn", "saved":"default_saved", "fall":"default_fall"},
	{"spawn":"default_spawn", "saved":"default_saved", "fall":"default_fall"},
	{"spawn":"default_spawn", "saved":"default_saved", "fall":"default_fall"}
]


func _ready():
	var characters_count : int = _sprite.texture.atlas.get_width() / _char_sprite_size
	
	# make sure _sounds_per_character size matches characters count
	# just in case we forget to update this
	assert(_sounds_per_character.size() == characters_count)
	
	_curr_character_idx = Utility.rng.randi_range(0, characters_count-1)
	_sprite.texture.region.position.x = _curr_character_idx * _char_sprite_size
	
	apply_central_impulse(Vector2(Utility.rng.randf_range(-100, 100), 0))
	AudioManager.play_sound(
		"characters/" + _sounds_per_character[_curr_character_idx]["spawn"], true,
		_character_volume
	)

func setup(_parachute_chance : int):
	global_position = Vector2(Utility.rng.randf_range(0, LevelData.view_size.x), -10)
	if Utility.rng.randf_range(0, 100) < _parachute_chance:
		_parachute_sprite.show()
		_max_speed *= _parachute_slowdown_factor
		linear_damp = 0.3

func _physics_process(delta : float):
	# speed limit
	var max_speed : float = _max_speed * LevelData.time_factor
	if abs(linear_velocity.x) > max_speed:
		linear_velocity.x = max_speed * sign(linear_velocity.x)
	if abs(linear_velocity.y) > max_speed:
		linear_velocity.y = max_speed * sign(linear_velocity.y)
	
	if _parachute_sprite.visible:
		_parachute_sprite.rotation_degrees = -rotation_degrees

func free_self(was_saved : bool):
	# NOTE: call this func if you want to allow character to make a sound before
	#       dying/saved
	if was_saved:
		LevelData.increment_stat("characters saved", 1)
	else:
		LevelData.increment_stat("characters lost", 1)
	
	var sound : String = "saved" if was_saved else "fall"
	AudioManager.play_sound(
		"characters/" + _sounds_per_character[_curr_character_idx][sound], true,
		_character_volume
	)
	
	queue_free()

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

func _on_body_entered(body):
	if body is HazardFallingRock:
		AudioManager.play_sound("character_hit_rock", false)
