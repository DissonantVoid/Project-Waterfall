extends Node2D

onready var _background : AnimatedSprite = $Background
onready var _ui : CanvasLayer = $UI
onready var _camera : Camera2D = $GameCamera
onready var _spawn_timer : Timer = $Timers/SpawnTimer
onready var _chars_container : Node2D = $Characters
onready var _bucket : Node2D = $Bucket

onready var _hazards_maker : Node2D = $Spawners/HazardsMaker
onready var _clouds : Node2D = $Spawners/Clouds
onready var _powerups_spawner : Node2D = $Spawners/PowerupsSpawner

# TODO: maybe we should move this to another class, why is characters spawning this calss's responsibility?
const _character_scene : PackedScene = preload("res://scenes/objects/character.tscn")

var _view_width : int = ProjectSettings.get_setting("display/window/size/width") * 2
const _levels_count : int = 5 # if you change this, you have to add/remove levels from res://resources/files/level_rules.cfg
const _points_to_win : int = 100
const _points_to_levelup : int = _points_to_win / _levels_count
var _current_progress : float = 0
var _current_level : int = 0

var _levels_rules : Array
var _is_paused : bool = false

# TODO: the game starts immidiatly, we need to give player
#       time to process what's what first, a delay at the start before
#       characters start to fall would do the trick


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	# have to do this manually, otherwise everytime I commit a change
	# the background animation will be in a different frame leading
	# to a commit history full of frame=2, frame=5, frame=12.....
	_background.playing = true
	
	# all children should pause when scene tree is paused
	for child in get_children():
		child.pause_mode = Node.PAUSE_MODE_STOP
	
	_bucket.connect("character_saved",self,"_on_bucket_character_saved")
	_bucket.connect("hit_hazard",self,"_on_bucket_hit_hazard")
	_bucket.connect("powerup_finished",self,"_on_bucket_powerup_finished")
	_ui.setup(_points_to_win)
	
	_load_rules_from_file()
	_apply_rules()
	_spawn_timer.start()

func _input(event : InputEvent):
	if event.is_action_pressed("pause"):
		# TODO: test potential bugs, like pausing right after winning
		_is_paused = !_is_paused
		_ui.set_pause(_is_paused)
		get_tree().paused = _is_paused

func _exit_tree():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_spawn_timeout():
	var instance := _character_scene.instance()
	_chars_container.add_child(instance)
	instance.global_position = Vector2(Utility.rng.randf_range(0, _view_width), -10)
	MusicManager.play_sound("falling", true)
	
	_spawn_timer.start()

func _on_bucket_character_saved():
	_increment_points(_levels_rules[_current_level]["points_per_catch"])
	MusicManager.play_sound("score", true)

func _on_bucket_hit_hazard():
	_increment_points(_levels_rules[_current_level]["hazard_hit_points"])
	_camera.shake(_camera.ShakeLevel.low)
	MusicManager.play_sound("collide", true)

func _on_bucket_powerup_finished():
	_powerups_spawner.bucket_powerup_finished()

func _on_abyss_body_entered(body : Node):
	if body is Character:
		body.queue_free()
		_increment_points(_levels_rules[_current_level]["points_per_miss"])
		MusicManager.play_sound("splash", true)

func _increment_points(value : float):
	_current_progress = clamp(_current_progress + value, 0, _points_to_win)
	
	if sign(value) == 1:
		_ui.increment_point(value, _bucket.global_position)
		# level up
		if int(_current_progress) / _points_to_levelup > _current_level:
			_current_level += 1
			if _current_level == (_points_to_win / _points_to_levelup):
				# we won!
				# do some particles n stuff first
				SceneManager.change_scene("res://scenes/game/credits.tscn")
			else:
				prints("LEVEL UP", _current_level)
				_ui.level_up()
				_apply_rules()
				
	elif sign(value) == -1:
		_ui.decrement_points(value)
		# level down
		if int(_current_progress) / _points_to_levelup < _current_level:
			_current_level -= 1
			prints("LEVEL DOWN", _current_level)
			_ui.level_down()
			_apply_rules()

func _apply_rules():
	var curr_level_data : Dictionary = _levels_rules[_current_level]
	_spawn_timer.wait_time = curr_level_data["time_between_spawn"]
	_clouds.update_rules(curr_level_data["time_between_clouds"])
	_hazards_maker.update_rules(
		curr_level_data["time_between_hazards"],
		curr_level_data["falling_rock_min_speed"],
		curr_level_data["falling_rock_max_speed"],
		curr_level_data["bird_min_speed"],
		curr_level_data["bird_max_speed"]
	)
	_powerups_spawner.update_rules(
		curr_level_data["time_between_powerups"],
		curr_level_data["powerup_min_speed"],
		curr_level_data["powerup_max_speed"]
	)
	#...

func _load_rules_from_file():
	var config_file : ConfigFile = ConfigFile.new()
	# Load data from a file.
	var err : int = config_file.load("res://resources/files/level_rules.cfg")
	# If the file didn't load, stop.
	assert(err == OK, "couldn't open the config file")
	# Iterate over all sections.
	for level in config_file.get_sections():
		var level_dict : Dictionary = {}
		level_dict["time_between_spawn"]     = config_file.get_value(level, "time_between_spawn")
		level_dict["points_per_catch"]       = config_file.get_value(level, "points_per_catch")
		level_dict["points_per_miss"]        = config_file.get_value(level, "points_per_miss")
		level_dict["time_between_clouds"]    = config_file.get_value(level, "time_between_clouds")
		level_dict["time_between_hazards"]   = config_file.get_value(level, "time_between_hazards")
		level_dict["hazard_hit_points"]      = config_file.get_value(level, "hazard_hit_points")
		level_dict["falling_rock_min_speed"] = config_file.get_value(level, "falling_rock_min_speed")
		level_dict["falling_rock_max_speed"] = config_file.get_value(level, "falling_rock_max_speed")
		level_dict["bird_min_speed"]         = config_file.get_value(level, "bird_min_speed")
		level_dict["bird_max_speed"]         = config_file.get_value(level, "bird_max_speed")
		level_dict["time_between_powerups"]  = config_file.get_value(level, "time_between_powerups")
		level_dict["powerup_min_speed"]      = config_file.get_value(level, "powerup_min_speed")
		level_dict["powerup_max_speed"]      = config_file.get_value(level, "powerup_max_speed")
		_levels_rules.append(level_dict)
	
	# for debugging:
	#for k in range(5):
	#	prints("level----")
	#	for j in _levels_rules[k]:
	#		prints("%s : %d" % [j, _levels_rules[k][j]]) 
