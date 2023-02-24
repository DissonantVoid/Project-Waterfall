extends Node

signal time_factor_changed
signal level_rules_updated


var view_size : Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/width"),
	ProjectSettings.get_setting("display/window/size/height")
) * 2

var levels_rules : Array
var current_level : int = 0 setget _set_current_level
var _stats : Dictionary = {
	"characters saved":0, "characters lost":0, "bird food":0, "powerups collected":0,
	"hazards hit":0, "health taken":0, "level ups":0, "level downs":0, "time played":0
}

var time_factor : float = 1.0 setget _set_time_factor
var game_won : bool = false


func _enter_tree():
	_load_rules_from_file()

func _set_time_factor(value : float):
	time_factor = value
	emit_signal("time_factor_changed")

func _set_current_level(value : int):
	# read only, can only be changed from inside the class
	assert(false, "read only")

func reset():
	time_factor = 1.0
	game_won = false
	current_level = 0
	for stat in _stats.values():
		stat = 0

func change_level(new_level : int):
	current_level = new_level
	emit_signal("level_rules_updated")

func increment_stat(stat_name : String, increment : int):
	assert(_stats.has(stat_name), "stat name doesn't exist")
	_stats[stat_name] += increment

func get_stats() -> Dictionary:
	return _stats

func _load_rules_from_file():
	var config_file : ConfigFile = ConfigFile.new()
	# Load data from a file.
	var err : int = config_file.load("res://resources/files/level_rules.cfg")
	# If the file didn't load, stop.
	assert(err == OK, "couldn't open the config file")
	# Iterate over all sections.
	for level in config_file.get_sections():
		var level_dict : Dictionary = {}
		level_dict["time_between_characters"]    = config_file.get_value(level, "time_between_characters")
		level_dict["characters_parachute_chance"]= config_file.get_value(level, "characters_parachute_chance")
		level_dict["points_per_save"]            = config_file.get_value(level, "points_per_save")
		level_dict["points_per_miss"]            = config_file.get_value(level, "points_per_miss")
		level_dict["time_between_clouds"]        = config_file.get_value(level, "time_between_clouds")
		level_dict["time_between_hazards"]       = config_file.get_value(level, "time_between_hazards")
		level_dict["hazard_hit_points"]          = config_file.get_value(level, "hazard_hit_points")
		level_dict["falling_rock_min_speed"]     = config_file.get_value(level, "falling_rock_min_speed")
		level_dict["falling_rock_max_speed"]     = config_file.get_value(level, "falling_rock_max_speed")
		level_dict["multiple_rocks_chance"]      = config_file.get_value(level, "multiple_rocks_chance")
		level_dict["bird_min_speed"]             = config_file.get_value(level, "bird_min_speed")
		level_dict["bird_max_speed"]             = config_file.get_value(level, "bird_max_speed")
		level_dict["bird_warning_time"]          = config_file.get_value(level, "bird_warning_time")
		level_dict["multiple_birds_chance"]      = config_file.get_value(level, "multiple_birds_chance")
		level_dict["time_between_powerups"]      = config_file.get_value(level, "time_between_powerups")
		level_dict["powerup_min_speed"]          = config_file.get_value(level, "powerup_min_speed")
		level_dict["powerup_max_speed"]          = config_file.get_value(level, "powerup_max_speed")
		level_dict["time_between_health"]        = config_file.get_value(level, "time_between_health")
		level_dict["health_item_speed"]          = config_file.get_value(level, "health_item_speed")
		levels_rules.append(level_dict)
