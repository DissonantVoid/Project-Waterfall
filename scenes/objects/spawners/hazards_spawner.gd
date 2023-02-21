extends Node2D

onready var _spawn_timer : Timer = $SpawnTimer
onready var _hazards_container : Node2D = $HazardsContainer

var _spawn_time : float
const _hazards : Dictionary = {
	"falling_rock": {
		"scene": preload("res://scenes/objects/hazards/hazard_falling_rock.tscn"), "multiple_chance":0,
		"min_speed":0.0, "max_speed":0.0
	},
	"bird": {
		"scene":preload("res://scenes/objects/hazards/hazard_bird.tscn"), "multiple_chance":0,
		"min_speed":0.0, "max_speed":0.0, "warning_time":0.0
	}
}
const _multiple_hazards_count : int = 3 # if we get a multiple chance (_multiple_rocks_chance etc..) we spawn this amount


func _ready():
	LevelData.connect("level_rules_updated", self, "_on_level_rules_updated")
	_spawn_timer.start()

func destroy_all():
	for hazard in _hazards_container.get_children():
		hazard.queue_free()

func _on_level_rules_updated():
	var current_rules : Dictionary = LevelData.levels_rules[LevelData.current_level]
	_spawn_time =  current_rules["time_between_hazards"]
	_spawn_timer.wait_time = _spawn_time / LevelData.time_factor
	_hazards["falling_rock"]["min_speed"] = current_rules["falling_rock_min_speed"]
	_hazards["falling_rock"]["max_speed"] = current_rules["falling_rock_max_speed"]
	_hazards["falling_rock"]["multiple_chance"] = current_rules["multiple_rocks_chance"]
	_hazards["bird"]["min_speed"] = current_rules["bird_min_speed"]
	_hazards["bird"]["max_speed"] = current_rules["bird_max_speed"]
	_hazards["bird"]["warning_time"] = current_rules["bird_warning_time"]
	_hazards["bird"]["multiple_chance"] = current_rules["multiple_birds_chance"]

func _on_spawn_timer_timeout():
	_spawn_hazard()
	
	_spawn_timer.wait_time = _spawn_time / LevelData.time_factor
	_spawn_timer.start()

func _spawn_hazard():
	var rnd_key : String = _hazards.keys()[Utility.rng.randi_range(0, _hazards.keys().size()-1)]
	
	var instances : Array
	if Utility.rng.randi_range(0, 100) < _hazards[rnd_key]["multiple_chance"]:
		instances.resize(_multiple_hazards_count)
	else:
		instances.resize(1)
	
	for i in instances.size():
		instances[i] = _hazards[rnd_key]["scene"].instance()
		_hazards_container.add_child(instances[i])
		
		# type dependent setup
		match rnd_key:
			"falling_rock":
				instances[i].setup(
					_hazards[rnd_key]["min_speed"],
					_hazards[rnd_key]["max_speed"]
				)
			"bird":
				instances[i].setup(
					_hazards[rnd_key]["min_speed"],
					_hazards[rnd_key]["max_speed"],
					_hazards[rnd_key]["warning_time"]
				)
