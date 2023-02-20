class_name PowerUpStone
extends Area2D

signal destroyed(was_picked)

onready var _sprite : Sprite = $Sprite
onready var _aura : Sprite = $Aura

const _powerups : Array = [
	{"sprite_region":Rect2(Vector2(80, 0), Vector2(16, 16)), "scene_path":"<random>"}, # this has to be first, don't change
	{"sprite_region":Rect2(Vector2(0, 0), Vector2(16, 16)), "scene_path":"res://scenes/objects/powerups/powerup_full_health.tscn", "is_good_aura":true},
	{"sprite_region":Rect2(Vector2(64, 0), Vector2(16, 16)), "scene_path":"res://scenes/objects/powerups/powerup_magnet.tscn", "is_good_aura":true},
	{"sprite_region":Rect2(Vector2(48, 0), Vector2(16, 16)), "scene_path":"res://scenes/objects/powerups/powerup_shrink.tscn", "is_good_aura":false},
	{"sprite_region":Rect2(Vector2(16, 0), Vector2(16, 16)), "scene_path":"res://scenes/objects/powerups/powerup_shield.tscn", "is_good_aura":true},
	{"sprite_region":Rect2(Vector2(32, 0), Vector2(16, 16)), "scene_path":"res://scenes/objects/powerups/powerup_clock.tscn", "is_good_aura":true},
]
var _self_powerup_data : Dictionary

var _speed : float
var _picked_up : bool = false # we can do better than this


func _ready():
	_self_powerup_data = _powerups[Utility.rng.randi_range(0, _powerups.size()-1)]
	
	# if it's the random stone.. well.. pick a random powerup
	if _self_powerup_data["scene_path"] == "<random>":
		var random_idx : int = Utility.rng.randi_range(1, _powerups.size()-1)
		# don't foget to duplicate, otherwise we'll edit _powerups content directly
		_self_powerup_data = _self_powerup_data.duplicate(true)
		_self_powerup_data["scene_path"] = _powerups[random_idx]["scene_path"]
	else:
		_aura.show()
		if _self_powerup_data["is_good_aura"] == false:
			_aura.region_rect.position.x = 32
	
	_sprite.texture.region = _self_powerup_data["sprite_region"]

func _process(delta : float):
	position.y += _speed * delta

func _exit_tree():
	if _picked_up == false:
		emit_signal("destroyed", false)

func setup(min_speed : float, max_speed : float):
	global_position = Vector2(
		Utility.rng.randi_range(0, LevelData.view_size.x),
		-_sprite.texture.get_height()
	)
	_speed = Utility.rng.randf_range(min_speed, max_speed)

func pickup() -> String:
	emit_signal("destroyed", true)
	_picked_up = true
	queue_free()
	
	return _self_powerup_data["scene_path"]
