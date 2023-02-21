extends Node2D

onready var _sprites_container : Node2D = $SpritesContainer
onready var _spawn_timer : Timer = $SpawnTimer

const _half_cloud_size : Vector2 = Vector2(72, 32)
const _texture : StreamTexture = preload("res://resources/textures/clouds.png")
var _cloud_sprite_count : int # the number of clouds in the sprite sheet, calculated automatically

var _spawn_time : float
var _spawn_bounds : Dictionary
const _float_speed : float = 48.0


func _ready():
	_cloud_sprite_count = _texture.get_width() / _half_cloud_size.x*2
	_spawn_timer.start()
	
	_spawn_bounds["x"] = Vector2(
		-_half_cloud_size.x,
		LevelData.view_size.x +_half_cloud_size.x
	)
	_spawn_bounds["y"] = Vector2(
		_half_cloud_size.y,
		LevelData.view_size.y -_half_cloud_size.y
	)

func update_rules(time_between_clouds : float):
	_spawn_time = time_between_clouds
	_spawn_timer.wait_time = _spawn_time / LevelData.time_factor

func _on_spawn_timer_timeout():
	_spawn_cloud()
	_spawn_timer.wait_time = _spawn_time / LevelData.time_factor
	_spawn_timer.start()

func _spawn_cloud():
	# make sprite
	var sprite : Sprite = Sprite.new()
	sprite.texture = _texture
	sprite.region_enabled = true
	sprite.region_rect.size = _half_cloud_size * 2
	sprite.region_rect.position.x = Utility.rng.randi_range(0, _cloud_sprite_count-1) * _half_cloud_size.x*2
	_sprites_container.add_child(sprite)
	
	if Utility.rng.randi_range(0, 1) == 1:
		# left to right
		sprite.global_position.x = _spawn_bounds["x"][0]
		sprite.set_meta("x_direction", 1)
	else:
		# right to left
		sprite.global_position.x = _spawn_bounds["x"][1]
		sprite.set_meta("x_direction", -1)
	
	sprite.global_position.y = Utility.rng.randf_range(
		_spawn_bounds["y"][0],_spawn_bounds["y"][1]
	)

func _process(delta : float):
	for sprite in _sprites_container.get_children():
		var x_direction : int = sprite.get_meta("x_direction")
		sprite.global_position.x += _float_speed * LevelData.time_factor * x_direction * delta
		
		# remove if out of bounds in the x axis
		if ( (x_direction == 1 && sprite.global_position.x > _spawn_bounds["x"][1]+_half_cloud_size.x) ||
			 (x_direction == -1 && sprite.global_position.x < _spawn_bounds["x"][0]-_half_cloud_size.x)):
			sprite.queue_free() # don't worry, cloud won't be freed until loop in over
