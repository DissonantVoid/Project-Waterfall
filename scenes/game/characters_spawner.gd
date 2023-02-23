extends Node2D

onready var _chars_container : Node2D = $Characters
onready var _spawn_timer : Timer = $SpawnTimer

const _character_scene : PackedScene = preload("res://scenes/objects/character.tscn")

const _pulse_force : float = 380.0
var _spawn_time : float
var _parachute_chance : int


func _ready():
	LevelData.connect("level_rules_updated", self, "_on_level_rules_updated")

func do_pulse():
	# push characters along with the pulse
	for character in _chars_container.get_children():
		var x_direction : float = character.global_position.x - LevelData.view_size.x/2
		character.apply_central_impulse(Vector2(x_direction * _pulse_force, 0))

func _on_level_rules_updated():
	var current_rules : Dictionary = LevelData.levels_rules[LevelData.current_level]
	_spawn_time = current_rules["time_between_characters"]
	_spawn_timer.wait_time = _spawn_time / LevelData.time_factor
	_parachute_chance = current_rules["characters_parachute_chance"]
	
	_spawn_timer.start()

func _on_spawn_timeout():
	var instance := _character_scene.instance()
	_chars_container.add_child(instance)
	instance.setup(_parachute_chance)
	
	_spawn_timer.wait_time = _spawn_time / LevelData.time_factor
	_spawn_timer.start()
