extends Node2D

onready var _waterfall_bg : AnimatedSprite = $Background/Waterfall
onready var _waterfall_particles : Particles2D = $Background/WaterParticles
onready var _ui : CanvasLayer = $UI
onready var _camera : Camera2D = $GameCamera
onready var _bucket : Node2D = $Bucket

onready var _characters_spawner : Node2D = $Spawners/CharactersSpawner
onready var _hazards_spawner : Node2D = $Spawners/HazardsSpawner
onready var _weather_controller : Node2D = $Spawners/WeatherControler
onready var _powerups_spawner : Node2D = $Spawners/PowerupsSpawner
onready var _health_spawner : Node2D = $Spawners/HealthSpawner

onready var _music_player : AudioStreamPlayer = $Music

const _levels_count : int = 5 # if you change this, you have to add/remove levels from res://resources/files/level_rules.cfg, you'd also need to change the progress bar and.. just don't do it alright?
const _points_to_win : int = 100
const _points_to_levelup : int = _points_to_win / _levels_count
var _current_progress : float = 0

var _is_paused : bool = false
var _start_time : Dictionary

var _music_levels : Dictionary = {
	"1":preload("res://resources/music/main_level_1.mp3"),
	"2":preload("res://resources/music/main_level_2_3.mp3"),
	"4":preload("res://resources/music/main_level_4_5.mp3")
}

# TODO: the game starts immidiatly, we need to give player
#       time to process what's what first, a delay at the start before
#       characters start to fall would do the trick

# TODO: the way objects get freed is inconsistent, some objects
#       are freed by their destroyer while others free themselves


func _ready():
	# we can't call this in tree_exit because the next scene (main_stats) needs it
	LevelData.reset()
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	_start_time = Time.get_datetime_dict_from_system()
	
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
	_bucket.connect("about_to_be_destroyed",self,"_on_bucket_about_to_be_destroyed")
	_bucket.connect("destroyed",self,"_on_bucket_destroyed")
	_ui.connect("pulsed", self, "_on_ui_pulsed")
	_ui.connect("forced_unpause", self, "_on_ui_forced_unpause")
	_ui.setup(_points_to_win)
	
	AudioManager.play_sound_loop("waterfall_ambience", -25)
	LevelData.change_level(0)
	_update_music()

func _input(event : InputEvent):
	if event.is_action_pressed("pause"):
		_set_pause(!_is_paused)
	
	# TEMP for debugging (don't tell anyone :|)
	if OS.is_debug_build() && event is InputEventKey && event.pressed:
		if event.scancode == KEY_SPACE:
			_increment_points(10)
		elif event.scancode == KEY_1:
			_increment_points((_points_to_levelup*0) -_current_progress)
		elif event.scancode == KEY_2:
			_increment_points((_points_to_levelup*1) -_current_progress)
		elif event.scancode == KEY_3:
			_increment_points((_points_to_levelup*2) -_current_progress)
		elif event.scancode == KEY_4:
			_increment_points((_points_to_levelup*3) -_current_progress)
		elif event.scancode == KEY_5:
			_increment_points((_points_to_levelup*4) -_current_progress)

func _exit_tree():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = false
	AudioManager.stop_loop("waterfall_ambience")

func _on_level_time_factor_changed():
	_waterfall_bg.speed_scale = LevelData.time_factor
	_waterfall_particles.speed_scale = LevelData.time_factor

func _on_bucket_character_saved():
	_increment_points(
		LevelData.levels_rules[LevelData.current_level]["points_per_save"]
	)

func _on_bucket_hit_hazard():
	_increment_points(
		LevelData.levels_rules[LevelData.current_level]["hazard_hit_points"]
	)
	_camera.shake(_camera.ShakeLevel.med)
	
	# TODO: remove this, instead have hazards play their own sfx
	#       when destroyed, this allows for more freedom when hazards
	#       hit each other, or hit shield powerup etc..
	AudioManager.play_sound("bucket_hit_hazard", true)

func _on_bucket_powerup_picked():
	_camera.shake(_camera.ShakeLevel.low)

func _on_bucket_powerup_finished():
	_powerups_spawner.bucket_powerup_finished()

func _on_bucket_time_factor_changed(factor : float):
	LevelData.time_factor = factor

func _on_bucket_about_to_be_destroyed():
	_camera.shrink_to_target(_bucket)
	_ui.set_hud_visible(false)

func _on_bucket_destroyed():
	LevelData.game_won = false
	LevelData.increment_stat("time played", _get_seconds_played())
	SceneManager.change_scene("res://scenes/game/main_stats.tscn")

func _on_ui_pulsed():
	_characters_spawner.do_pulse()
	_hazards_spawner.destroy_all()
	_camera.shake(_camera.ShakeLevel.med)

func _on_ui_forced_unpause():
	_set_pause(false)

func _on_abyss_body_or_area_entered(object : Node):
	if object is Character:
		object.free_self(false)
		_increment_points(
			LevelData.levels_rules[LevelData.current_level]["points_per_miss"]
		)
		AudioManager.play_sound("splash", true)
	elif object is HazardFallingRock || object is Health || object is PowerUpStone:
		object.queue_free()

func _set_pause(should_pause : bool):
	_is_paused = should_pause
	_ui.set_pause(_is_paused)
	get_tree().paused = _is_paused
	
	if _is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _increment_points(value : float):
	var new_progress : float = clamp(_current_progress + value, 0, _points_to_win)
	if _current_progress == new_progress: return
	 
	_current_progress = new_progress
	var new_level : int = int(_current_progress) / _points_to_levelup
	if sign(value) == 1:
		_ui.increment_points(value, _bucket.global_position)
		# level up
		if new_level > LevelData.current_level:
			if new_level == (_points_to_win / _points_to_levelup):
				# we won!
				LevelData.game_won = true
				LevelData.increment_stat("time played", _get_seconds_played())
				_bucket.deactivate()
				
				var white_screen : ColorRect = ColorRect.new()
				white_screen.rect_size = LevelData.view_size
				add_child(white_screen)
				yield(get_tree(), "idle_frame")
				
				var tween : SceneTreeTween = get_tree().create_tween()
				tween.tween_property(white_screen, "modulate:a", 1.0, 2.0)\
					.from(0.0)
				yield(tween, "finished")
				
				SceneManager.change_scene("res://scenes/game/main_stats.tscn")
			else:
				LevelData.change_level(new_level)
				LevelData.increment_stat("level ups", 1)
				_ui.level_up(LevelData.current_level)
				AudioManager.play_sound("levelup", false)
				_update_music()
		
	elif sign(value) == -1:
		_ui.decrement_points(value)
		# level down
		if new_level < LevelData.current_level:
			LevelData.change_level(new_level)
			LevelData.increment_stat("level downs", 1)
			_ui.level_down(LevelData.current_level)
			AudioManager.play_sound("leveldown", false)
			_update_music()

func _update_music():
	var next_music_layer : int = LevelData.current_level + 1
	while _music_levels.has(str(next_music_layer)) == false && next_music_layer > 0:
		next_music_layer -= 1
	
	if _music_player.stream != _music_levels[str(next_music_layer)]:
			_music_player.stream = _music_levels[str(next_music_layer)]
			_music_player.play()

func _get_seconds_played() -> int:
	var _end_time : Dictionary = Time.get_datetime_dict_from_system()
	_start_time
	
	# this will break if you start playing right before the end
	# of a months and stoped after the start of the month
	# but that's unlikely
	var seconds : int =\
	(_end_time["day"] - _start_time["day"]) * 86400 +\
	(_end_time["hour"] - _start_time["hour"]) * 3600 +\
	(_end_time["minute"] - _start_time["minute"]) * 60 +\
	(_end_time["second"] - _start_time["second"])
	
	return seconds
