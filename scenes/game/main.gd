extends Node2D

onready var _waterfall_bg : AnimatedSprite = $Background/Waterfall
onready var _waterfall_particles : Particles2D = $Background/WaterParticles
onready var _ui : CanvasLayer = $UI
onready var _camera : Camera2D = $GameCamera
onready var _bucket : Node2D = $Bucket

onready var _characters_spawner : Node2D = $Spawners/CharactersSpawner
onready var _hazards_maker : Node2D = $Spawners/HazardsMaker
onready var _clouds : Node2D = $Spawners/Clouds
onready var _powerups_spawner : Node2D = $Spawners/PowerupsSpawner

const _levels_count : int = 5 # if you change this, you have to add/remove levels from res://resources/files/level_rules.cfg, you'd also need to change the progress bar and.. just don't do it alright?
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
	_waterfall_bg.playing = true
	
	# reconfigure children pause mode, since we are root, we can't change
	# our pause mode without affecting the rest of the tree, we need to
	# remove this effect by getting rid of INHERIT pause mode
	for child in get_children():
		if child.pause_mode == Node.PAUSE_MODE_INHERIT:
			child.pause_mode = Node.PAUSE_MODE_STOP
	
	LevelData.connect("time_factor_changed", self, "_on_level_time_factor_changed")
	
	_bucket.connect("character_saved",self,"_on_bucket_character_saved")
	_bucket.connect("hit_hazard",self,"_on_bucket_hit_hazard")
	_bucket.connect("powerup_picked",self,"_on_bucket_powerup_picked")
	_bucket.connect("powerup_finished",self,"_on_bucket_powerup_finished")
	_bucket.connect("time_factor_changed",self,"_on_bucket_time_factor_changed")
	_ui.connect("pulsed", self, "_on_ui_pulsed")
	_ui.connect("forced_unpause", self, "_on_ui_forced_unpause")
	_ui.setup(_points_to_win)
	
	_load_rules_from_file()
	_apply_rules()

func _input(event : InputEvent):
	if event.is_action_pressed("pause"):
		_set_pause(!_is_paused)
	
	#if event is InputEventKey && event.pressed:
	#	_increment_points(10)

func _exit_tree():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = false
	LevelData.reset()

func _on_level_time_factor_changed():
	_waterfall_particles.speed_scale = LevelData.time_factor
	_waterfall_particles.speed_scale = LevelData.time_factor

func _on_bucket_character_saved():
	_increment_points(_levels_rules[_current_level]["points_per_catch"])
	AudioManager.play_sound("score", true)

func _on_bucket_hit_hazard():
	_increment_points(_levels_rules[_current_level]["hazard_hit_points"])
	_camera.shake(_camera.ShakeLevel.med)
	
	# TODO: remove this, instead have hazards play their own sfx
	#       when destroyed, this allows for more freedom when hazards
	#       hit each other, or hit shield powerup etc..
	AudioManager.play_sound("collide", true)

func _on_bucket_powerup_picked():
	_camera.shake(_camera.ShakeLevel.low)

func _on_bucket_powerup_finished():
	_powerups_spawner.bucket_powerup_finished()

func _on_bucket_time_factor_changed(factor : float):
	LevelData.time_factor = factor

func _on_ui_pulsed():
	_characters_spawner.do_pulse()
	_camera.shake(_camera.ShakeLevel.med)

func _on_ui_forced_unpause():
	_set_pause(false)

func _on_abyss_body_entered(body : Node):
	if body is Character:
		body.queue_free()
		_increment_points(_levels_rules[_current_level]["points_per_miss"])
		AudioManager.play_sound("splash", true)

func _set_pause(should_pause : bool):
	# TODO: test potential bugs, like pausing right after winning
	_is_paused = should_pause
	_ui.set_pause(_is_paused)
	get_tree().paused = _is_paused
	
	if _is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _increment_points(value : float):
	_current_progress = clamp(_current_progress + value, 0, _points_to_win)
	
	if sign(value) == 1:
		_ui.increment_points(value, _bucket.global_position)
		# level up
		if int(_current_progress) / _points_to_levelup > _current_level:
			_current_level += 1
			if _current_level == (_points_to_win / _points_to_levelup):
				# we won!
				# do some particles n stuff first
				SceneManager.change_scene("res://scenes/game/credits.tscn")
			else:
				_ui.level_up(_current_level)
				_apply_rules()
				
	elif sign(value) == -1:
		_ui.decrement_points(value)
		# level down
		if int(_current_progress) / _points_to_levelup < _current_level:
			_current_level -= 1
			_ui.level_down(_current_level)
			_apply_rules()

func _apply_rules():
	var curr_level_data : Dictionary = _levels_rules[_current_level]
	_characters_spawner.update_rules(curr_level_data["time_between_spawn"])
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
