extends CanvasLayer

onready var _progress_bar : Control = $Hud/Progress
onready var _pause_container : MarginContainer = $Pause
onready var _levelup_label : Label = $Hud/LevelLabel

const _point_tween_time : float = 0.8
var _point_label_font : DynamicFont

const _levelup_tween_time : float = 1.0
const _levelup_show_time : float = 2.0
const _levelup_color : Color = Color("96ffa8")
const _leveldown_color : Color = Color("ad4545")
var _levelup_active_tween : SceneTreeTween = null


func _ready():
	_progress_bar.rect_pivot_offset = _progress_bar.rect_size / 2
	
	_point_label_font = DynamicFont.new()
	_point_label_font.size = 18
	_point_label_font.font_data = preload("res://resources/fonts/m5x7.ttf")

func setup(points_to_win : int):
	_progress_bar.setup(0 ,points_to_win)

func set_pause(should_pause : bool):
	_pause_container.visible = should_pause

func increment_points(value : float, bucket_position : Vector2):
	# animate a score point moving from bucket to UI
	var label : Label = Label.new()
	label.add_font_override("font", _point_label_font)
	label.add_color_override("font_color", Color.black)
	label.text = "+" + str(value)
	# /2 because view is twice the screen size (camera is zoomed out), this feels hacky
	label.rect_position = bucket_position / 2
	add_child(label)
	label.rect_pivot_offset = label.rect_size / 2
	
	var progress_bar_edge : Vector2 = _progress_bar.get_progress_edge_position()
	
	var tween : SceneTreeTween = get_tree().create_tween()\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
	tween.tween_property(label, "rect_position", progress_bar_edge, _point_tween_time)
	tween.tween_property(label, "rect_scale", Vector2.ONE * 0.8, _point_tween_time)
	tween.connect("finished", self, "_on_point_added", [label, value])

func decrement_points(value : float):
	# ...
	
	_progress_bar.decrement_value(value)

func level_up(current_level : int):
	_levelup_label.text = "Level Up!\n" + str(current_level)
	_levelup_label.add_color_override("font_color", _levelup_color)
	_levelup_label.show()
	
	if _levelup_active_tween != null && _levelup_active_tween.is_valid():
		_levelup_active_tween.kill()
	
	_levelup_active_tween = _make_levelup_tween()

func level_down(current_level : int):
	_levelup_label.text = "Level Down\n" + str(current_level)
	_levelup_label.add_color_override("font_color", _leveldown_color)
	_levelup_label.show()
	
	if _levelup_active_tween != null && _levelup_active_tween.is_valid():
		_levelup_active_tween.kill()
	
	_levelup_active_tween = _make_levelup_tween()

func _on_back_to_menu_pressed():
	SceneManager.change_scene("res://scenes/game/menu.tscn")

func _on_point_added(label : Label, value : float):
	label.queue_free()
	
	_progress_bar.increment_value(value)

func _make_levelup_tween() -> SceneTreeTween:
	var tween : SceneTreeTween = get_tree().create_tween()
	# popup
	tween.tween_property(_levelup_label, "rect_scale", Vector2.ONE, _levelup_tween_time)\
		.from(Vector2.ZERO).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_interval(_levelup_show_time)
	# pop.. down?.. disappear
	tween.tween_property(_levelup_label, "rect_scale", Vector2.ZERO, _levelup_tween_time)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.parallel()
	tween.tween_property(_levelup_label, "rect_rotation", 360.0, _levelup_tween_time)\
		.from(0.0)
	
	return tween
