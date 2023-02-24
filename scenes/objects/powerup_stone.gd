class_name PowerUpStone
extends Area2D

signal destroyed(was_picked)

onready var _sprite : Sprite = $Sprite
onready var _aura : Sprite = $Aura

const _powerups : Array = [
	{"x_position_in_sprite":0, "scene_path":"<random>"}, # this has to be first, don't change
	{"x_position_in_sprite":16, "scene_path":"res://scenes/objects/powerups/powerup_full_health.tscn", "is_good_aura":true},
	{"x_position_in_sprite":32, "scene_path":"res://scenes/objects/powerups/powerup_shield.tscn", "is_good_aura":true},
	{"x_position_in_sprite":48, "scene_path":"res://scenes/objects/powerups/powerup_clock.tscn", "is_good_aura":true},
	{"x_position_in_sprite":64, "scene_path":"res://scenes/objects/powerups/powerup_shrink.tscn", "is_good_aura":false},
	{"x_position_in_sprite":80, "scene_path":"res://scenes/objects/powerups/powerup_magnet.tscn", "is_good_aura":true},
	{"x_position_in_sprite":96, "scene_path":"res://scenes/objects/powerups/powerup_bad_vision.tscn", "is_good_aura":false},
]
var _self_powerup_data : Dictionary

const _aura_rotation_speed : float = 120.0
var _speed : float
var _picked_up : bool = false # we can do better than this


func _process(delta : float):
	position.y += _speed * delta
	_aura.rotation_degrees += _aura_rotation_speed * delta

func _exit_tree():
	if _picked_up == false:
		emit_signal("destroyed", false)

func setup(min_speed : float, max_speed : float, last_powerup_idx : int) -> int:
	global_position = Vector2(
		Utility.rng.randi_range(0, LevelData.view_size.x),
		-_sprite.texture.get_height()
	)
	_speed = Utility.rng.randf_range(min_speed, max_speed)
	
	var random_idx : int = Utility.rng.randi_range(0, _powerups.size()-2)
	# make sure we don't spawn same stone as last time
	if random_idx >= last_powerup_idx:
		random_idx += 1
	_self_powerup_data = _powerups[random_idx]
	
	# if it's the random stone.. well.. pick a random powerup
	if _self_powerup_data["scene_path"] == "<random>":
		var new_random_idx : int = Utility.rng.randi_range(1, _powerups.size()-1)
		# don't foget to duplicate, otherwise we'll edit _powerups content directly
		_self_powerup_data = _self_powerup_data.duplicate(true)
		_self_powerup_data["scene_path"] = _powerups[new_random_idx]["scene_path"]
	else:
		_aura.show()
		if _self_powerup_data["is_good_aura"] == false:
			_aura.region_rect.position.x = 32
	
	_sprite.texture.region = Rect2(
		Vector2(_self_powerup_data["x_position_in_sprite"], 0),
		Vector2(16, 16)
	)
	
	return random_idx

func pickup() -> String:
	emit_signal("destroyed", true)
	_picked_up = true
	queue_free()
	
	return _self_powerup_data["scene_path"]
