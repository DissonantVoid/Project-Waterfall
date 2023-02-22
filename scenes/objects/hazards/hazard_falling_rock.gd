class_name HazardFallingRock
extends KinematicBody2D

onready var _sprite : Sprite = $Sprite

const _rock_width : int = 32
var _fall_speed : float


func _ready():
	var rocks_count : int = _sprite.texture.get_width() / _rock_width
	_sprite.region_rect.position.x = Utility.rng.randi_range(0, rocks_count-1) * _rock_width

func _process(delta : float):
	rotation_degrees += _fall_speed * delta * LevelData.time_factor
	move_and_collide(Vector2(0, _fall_speed) * delta * LevelData.time_factor)

func setup(min_speed : float, max_speed : float):
	global_position = Vector2(
		Utility.rng.randi_range(0, LevelData.view_size.x),
		-_sprite.texture.get_height()
	)
	_fall_speed = Utility.rng.randf_range(min_speed, max_speed)

func destroy():
	AudioManager.play_sound("rock_destroyed", false)
	# particles here
	queue_free()
