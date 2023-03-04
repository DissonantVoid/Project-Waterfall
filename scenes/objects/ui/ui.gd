extends CanvasLayer

signal pulsed
signal forced_unpause

onready var _hud : MarginContainer = $Hud
onready var _progress_bar : Control = $Hud/Progress
onready var _pause_container : MarginContainer = $Pause
onready var _unpause_label : Label = $Pause/MarginContainer/UnpauseLabel
onready var _unpause_timer : Timer = $Pause/UnpauseTimer
onready var _message_label : Label = $Hud/MessageLabel
onready var _pulse_canvas : ColorRect = $PulseCanvas
onready var _pulse_cooldown_timer : Timer = $PulseCooldownTimer

const _character_silhouette_texture : StreamTexture = preload("res://resources/textures/character_silhouette.png")
const _point_tween_time : float = 0.7

const _message_tween_time : float = 1.0
const _message_show_time : float = 1.2
const _good_color : Color = Color("96ffa8")
const _bad_color : Color = Color("ad4545")
const _pulse_cooldown : float = 2.9 # don't spam pulses when player levels up then down then up very quick
var _message_active_tween : SceneTreeTween = null

const _time_to_unpause : int = 15
var _current_pause_time : int = 0
var _unpause_label_text : String


func _ready():
	_progress_bar.rect_pivot_offset = _progress_bar.rect_size / 2
	
	_pulse_cooldown_timer.wait_time = _pulse_cooldown
	_unpause_label_text = _unpause_label.text
	
	_show_message("Catch Your Falling Friends!", _good_color, 5)
	_message_label.show()

func setup(points_to_win : int):
	_progress_bar.setup(0 ,points_to_win)

func set_pause(should_pause : bool):
	_pause_container.visible = should_pause
	if should_pause:
		_current_pause_time = _time_to_unpause
		_unpause_label.text = _unpause_label_text % _current_pause_time
		_unpause_timer.start()
	else:
		_unpause_timer.stop()

func set_hud_visible(is_visible : bool):
	_hud.visible = is_visible

func increment_points(value : float, bucket_position : Vector2):
	# animate a score character moving from bucket to UI
	var sprite : TextureRect = TextureRect.new()
	sprite.rect_scale = Vector2.ONE * 0.8
	sprite.rect_position = bucket_position / 2
	sprite.texture = _character_silhouette_texture
	add_child(sprite)
	sprite.rect_pivot_offset = sprite.rect_size / 2
	
	var progress_bar_edge : Vector2 = _progress_bar.get_progress_edge_position()
	
	var tween : SceneTreeTween = get_tree().create_tween()\
		.set_parallel(true)
	tween.tween_property(sprite, "rect_position", progress_bar_edge, _point_tween_time)
	tween.tween_property(sprite, "rect_scale", Vector2.ONE * 0.2, _point_tween_time)
	tween.tween_property(sprite, "rect_rotation", 360.0, _point_tween_time)
	tween.connect("finished", self, "_on_point_added", [sprite, value])

func decrement_points(value : float):
	# ...
	_progress_bar.decrement_value(value)

func level_up(current_level : int):
	var level_up_text : String =\
		"Level Up!" if _pulse_cooldown_timer.time_left == 0 else "Sike!"
	_show_message(level_up_text + '\n' + str(current_level), _good_color)
	
	# pulse
	if _pulse_cooldown_timer.time_left == 0.0:
		var tween : SceneTreeTween = get_tree().create_tween()
		tween.tween_property(_pulse_canvas.material, "shader_param/start_radius", 1.0, _message_tween_time)\
			.from(0.0)
		tween.parallel()
		tween.tween_property(_pulse_canvas.material, "shader_param/end_radius", 1.2, _message_tween_time)\
			.from(0.2)
		
		emit_signal("pulsed")
	_pulse_cooldown_timer.start()

func level_down(current_level : int):
	var level_down_text : String =\
		"Level Down" if _pulse_cooldown_timer.time_left == 0 else "Sike!"
	_show_message(level_down_text + '\n' + str(current_level), _bad_color)

func _on_back_to_menu_pressed():
	SceneManager.change_scene("res://scenes/game/menu.tscn")

func _on_point_added(sprite : TextureRect, value : float):
	sprite.queue_free()
	_progress_bar.increment_value(value)

func _on_unpause_timer_timeout():
	_current_pause_time -= 1
	_unpause_label.text = _unpause_label_text % _current_pause_time
	
	if _current_pause_time <= 5:
		AudioManager.play_sound("clock_tick", false)
	
	if _current_pause_time == 0:
		emit_signal("forced_unpause")
	else:
		_unpause_timer.start()

func _show_message(text : String, color : Color, show_time : float = _message_show_time):
	var tween : SceneTreeTween = get_tree().create_tween()
	
	_message_label.text = text
	_message_label.add_color_override("font_color", color)
	
	if _message_active_tween != null && _message_active_tween.is_valid():
		# shouldn't have +1 tweens running at same time
		_message_active_tween.kill()
		_message_label.rect_scale = Vector2.ONE
		_message_label.rect_rotation = 0
		_pulse_canvas.material.set_shader_param("start_radius", 0.0)
		_pulse_canvas.material.set_shader_param("end_radius", 0.0)
	
	# popup
	tween.tween_property(_message_label, "rect_scale", Vector2.ONE, _message_tween_time)\
		.from(Vector2.ZERO).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	tween.tween_interval(show_time)
	
	# pop.. down?.. disappear
	tween.tween_property(_message_label, "rect_scale", Vector2.ZERO, _message_tween_time)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.parallel()
	tween.tween_property(_message_label, "rect_rotation", 360.0*2, _message_tween_time)\
		.from(0.0)
	
	_message_active_tween = tween
