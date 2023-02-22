class_name HazardBird
extends Area2D

onready var _sprite : Sprite = $Sprite
onready var _sprite_animation_timer : Timer = $Sprite/AnimationTimer
onready var _held_character_sprite : Sprite = $HeldCharacter
onready var _warning_sprite : Sprite = $Warning
onready var _collider : CollisionShape2D = $CollisionShape2D
onready var _warning_timer : Timer = $WarningTimer

const _birds_sprite_count : int = 2 # the number of birds in the sprite sheet
const _birds_sprite_frames : int = 6 # number of frames in an animation
const _birds_sprite_width : int = 48 # width of a single frame

var _sprite_animation_time : float = 0.1

var _speed : float
var _direction : Vector2
var _x_edges : Vector2
var _is_moving : bool = false
var _is_holding_character : bool = false
const _speed_with_held_character : float = 390.0


func _ready():
	# random bird sprite
	_sprite.frame = Utility.rng.randi_range(0, _birds_sprite_count-1)
	
	_sprite_animation_timer.wait_time = _sprite_animation_time / LevelData.time_factor
	LevelData.connect("time_factor_changed", self, "_on_time_factor_changed")

func setup(min_speed : float, max_speed : float, warning_time : float):
	# setup movement variables
	var y_25_percent : float = lerp(0, LevelData.view_size.y, 0.25)
	var end_position : Vector2
	global_position.y = Utility.rng.randi_range(0, LevelData.view_size.y - y_25_percent)
	if Utility.rng.randi_range(0,1) == 0:
		end_position.x = 0
		global_position.x = LevelData.view_size.x
	else:
		end_position.x = LevelData.view_size.x
		global_position.x = 0
		_sprite.flip_h = true
	
	end_position.y = Utility.rng.randi_range(0, LevelData.view_size.y - y_25_percent)
	
	_direction = (end_position - global_position).normalized()
	_speed = Utility.rng.randf_range(min_speed, max_speed)
	_x_edges = Vector2(0, LevelData.view_size.x)
	
	# warn before showing the bird
	_sprite.hide()
	_warning_sprite.show()
	_warning_sprite.global_position.x = clamp(_warning_sprite.global_position.x, 32, LevelData.view_size.x-32)
	_collider.disabled = true
	_warning_timer.wait_time = warning_time
	_warning_timer.start()

func _process(delta : float):
	if _is_moving:
		global_position += _direction * _speed * delta * LevelData.time_factor
		if global_position.x < _x_edges[0] || global_position.x > _x_edges[1]:
			queue_free()

func _on_warning_timeout():
	_sprite.show()
	_warning_sprite.hide()
	_collider.disabled = false
	_is_moving = true
	AudioManager.play_sound("bird_spawn", true)

func _on_time_factor_changed():
	_sprite_animation_timer.wait_time = _sprite_animation_time / LevelData.time_factor

func _on_body_entered(body):
	if body is Character && _is_holding_character == false:
		body.queue_free()
		_speed = _speed_with_held_character
		_held_character_sprite.texture = body.get_texture()
		_is_holding_character = true
		LevelData.increment_stat("bird food", 1)
	elif body is HazardFallingRock:
		body.destroy()

func _on_animation_timeout():
	_sprite.region_rect.position.x += _birds_sprite_width
	if _sprite.region_rect.position.x == _birds_sprite_width * _birds_sprite_frames:
		_sprite.region_rect.position.x = 0
