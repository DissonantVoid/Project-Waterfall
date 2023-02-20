extends Node2D

onready var _spawn_timer : Timer = $SpawnTimer
onready var _hazards_container : Node2D = $HazardsContainer

var _spawn_time : float
const _hazards : Dictionary = {
	"falling_rock": preload("res://scenes/objects/hazards/hazard_falling_rock.tscn"),
	"bird": preload("res://scenes/objects/hazards/hazard_bird.tscn")
}

var _falling_rock_min_speed : float
var _falling_rock_max_speed : float
var _bird_min_speed : float
var _bird_max_speed : float


func _ready():
	_spawn_timer.start()

func update_rules(time_between_spawn : float, min_rock_speed : float,
				max_rock_speed : float, min_bird_speed : float, max_bird_speed : float):
	_spawn_time = time_between_spawn
	_spawn_timer.wait_time = _spawn_time / LevelData.time_factor
	_falling_rock_min_speed = min_rock_speed
	_falling_rock_max_speed = max_rock_speed
	_bird_min_speed = min_bird_speed
	_bird_max_speed = max_bird_speed

func destroy_all():
	for hazard in _hazards_container.get_children():
		hazard.queue_free()

func _on_spawn_timer_timeout():
	_spawn_hazard()
	_spawn_timer.wait_time = _spawn_time / LevelData.time_factor
	_spawn_timer.start()

func _spawn_hazard():
	var rnd_key : String = _hazards.keys()[Utility.rng.randi_range(0, _hazards.keys().size()-1)]
	var instance = _hazards[rnd_key].instance()
	_hazards_container.add_child(instance)
	
	# type dependent setup
	match rnd_key:
		"falling_rock":
			instance.setup(
				_falling_rock_min_speed,
				_falling_rock_max_speed
			)
		"bird":
			instance.setup(
				_bird_min_speed,
				_bird_max_speed
			)
