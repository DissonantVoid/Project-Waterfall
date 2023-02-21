extends Node2D

# a bit out of touch to have a spawner for 1 type but this doesn't fit anywhere
# else, I initially had an "items_spawner" class, but there are really no other
# items other than health

onready var _spawn_timer : Timer = $SpawnTimer
onready var _items_container : Node2D = $ItemsContainer

const _health_scene : PackedScene = preload("res://scenes/objects/health.tscn")

var _spawn_time : float
var _health_item_speed : float


func _ready():
	LevelData.connect("level_rules_updated", self, "_on_level_rules_updated")
	_spawn_timer.start()

func _on_level_rules_updated():
	var current_rules : Dictionary = LevelData.levels_rules[LevelData.current_level]
	_spawn_time = current_rules["time_between_health"]
	_spawn_timer.wait_time = _spawn_time / LevelData.time_factor
	_health_item_speed = current_rules["health_item_speed"]

func _on_spawn_timer_timeout():
	var instance := _health_scene.instance()
	_items_container.add_child(instance)
	instance.setup(_health_item_speed)
	
	_spawn_timer.wait_time = _spawn_time / LevelData.time_factor
	_spawn_timer.start()
