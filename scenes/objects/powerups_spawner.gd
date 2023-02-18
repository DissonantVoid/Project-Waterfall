extends Node2D

onready var _spawn_timer : Timer = $SpawnTimer
onready var _stones_container : Node2D = $StonesContainer

const _powerup_stone_scene : PackedScene = preload("res://scenes/objects/powerup_stone.tscn")

var _min_stone_speed : float
var _max_stone_speed : float
var _slowed : bool = false

# NOTE: there can only be 1 powerup at any given time


func _ready():
	_spawn_timer.start()
	
func _process(delta : float):
	if Utility._is_slow and not _slowed:
		_spawn_timer.wait_time /= Utility._slowing_factor
		_slowed = true
	if not Utility._is_slow and _slowed:
		_spawn_timer.wait_time *= Utility._slowing_factor
		_slowed = false

func update_rules(time_between_spawn : float, min_stone_speed : float, max_stone_speed : float):
	_spawn_timer.wait_time = time_between_spawn
	_min_stone_speed = min_stone_speed
	_max_stone_speed = max_stone_speed

func bucket_powerup_finished():
	# bucket used the powerup untill it ran out, now we can spawn another
	_spawn_timer.start()

func _on_spawn_timer_timeout():
	var instance := _powerup_stone_scene.instance()
	instance.connect("destroyed", self, "_on_powerup_stone_destroyed")
	_stones_container.add_child(instance)
	instance.setup(Vector2(
		ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height")) * 2,
		_min_stone_speed,
		_max_stone_speed
	)

func _on_powerup_stone_destroyed(was_picked : bool):
	if was_picked == false:
		_spawn_timer.start()
	
	# otherwise the bucket has picked the powerup, and now we have
	# to wait for it to finish (bucket_powerup_ended())
