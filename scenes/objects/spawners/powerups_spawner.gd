extends Node2D

onready var _spawn_timer : Timer = $SpawnTimer
onready var _stones_container : Node2D = $StonesContainer

const _powerup_stone_scene : PackedScene = preload("res://scenes/objects/powerup_stone.tscn")

var _min_stone_speed : float
var _max_stone_speed : float

# NOTE: there can only be 1 powerup at any given time


func _ready():
	LevelData.connect("level_rules_updated", self, "_on_level_rules_updated")

func bucket_powerup_finished():
	# bucket used the powerup untill it ran out, now we can spawn another
	_spawn_timer.start()

func _on_level_rules_updated():
	var current_rules : Dictionary = LevelData.levels_rules[LevelData.current_level]
	_spawn_timer.wait_time = current_rules["time_between_powerups"]
	_min_stone_speed = current_rules["powerup_min_speed"]
	_max_stone_speed = current_rules["powerup_max_speed"]
	
	_spawn_timer.start()

func _on_spawn_timer_timeout():
	var instance := _powerup_stone_scene.instance()
	instance.connect("destroyed", self, "_on_powerup_stone_destroyed")
	_stones_container.add_child(instance)
	instance.setup(
		_min_stone_speed,
		_max_stone_speed
	)

func _on_powerup_stone_destroyed(was_picked : bool):
	if was_picked == false:
		_spawn_timer.start()
	
	# otherwise the bucket has picked the powerup, and now we have
	# to wait for it to finish (bucket_powerup_ended())
