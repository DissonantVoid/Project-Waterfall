class_name PowerUpStone
extends Area2D

signal destroyed(was_picked)

onready var _sprite : Sprite = $Sprite

const _powerups : Array = [
	{"sprite_region":Rect2(Vector2(16, 16), Vector2(16, 16)), "powerup_scene":"<random>"}, # this has to be first, don't change
	{"sprite_region":Rect2(Vector2.ZERO, Vector2(16, 16)), "powerup_scene":"res://scenes/objects/powerups/powerup_magnet.tscn"},
	{"sprite_region":Rect2(Vector2(16, 0), Vector2(16, 16)), "powerup_scene":"res://scenes/objects/powerups/powerup_shrink.tscn"},
]
var _self_powerup_data : Dictionary

var _y_bound : float
var _speed : float


func _ready():
	_self_powerup_data = _powerups[Utility.rng.randi_range(0, _powerups.size()-1)]
	_sprite.texture.region = _self_powerup_data["sprite_region"]
	
	# if it's the random stone.. well.. pick a random powerup
	if _self_powerup_data["powerup_scene"] == "<random>":
		var random_idx : int = Utility.rng.randi_range(1, _powerups.size()-1)
		_self_powerup_data["powerup_scene"] =\
			_powerups[random_idx]["powerup_scene"]

func _process(delta : float):
	position.y += _speed * delta
	if position.y > _y_bound:
		emit_signal("destroyed", false)
		queue_free()

func setup(view_size : Vector2, min_speed : float, max_speed : float):
	global_position = Vector2(
		Utility.rng.randi_range(0, view_size.x),
		-_sprite.texture.get_height()
	)
	_y_bound = view_size.y
	_speed = Utility.rng.randf_range(min_speed, max_speed)

func pickup() -> String:
	emit_signal("destroyed", true)
	queue_free()
	
	return _self_powerup_data["powerup_scene"]
