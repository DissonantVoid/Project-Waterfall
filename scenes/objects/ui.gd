extends CanvasLayer

onready var _progress_bar : ProgressBar = $MarginContainer/Progress

const _point_tween_time : float = 0.8
var _point_label_font : DynamicFont


func _ready():
	_progress_bar.rect_pivot_offset = _progress_bar.rect_size / 2
	
	_point_label_font = DynamicFont.new()
	_point_label_font.size = 18
	_point_label_font.font_data = preload("res://resources/fonts/m5x7.ttf")

func setup(points_to_win : int):
	_progress_bar.max_value = points_to_win

func increment_point(value : float, bucket_position : Vector2):
	# animate a score point moving from bucket to UI
	var label : Label = Label.new()
	label.add_font_override("font", _point_label_font)
	label.add_color_override("font_color", Color.black)
	label.text = "+" + str(value)
	# /2 because view is twice the screen size (camera is zoomed out), this feels hacky
	label.rect_position = bucket_position / 2
	add_child(label)
	label.rect_pivot_offset = label.rect_size / 2
	
	var progress_bar_edge : Vector2 = _progress_bar.rect_position + Vector2(
		range_lerp(_progress_bar.value, _progress_bar.min_value, _progress_bar.max_value, 0, _progress_bar.rect_size.x),
		0
	)
	var tween : SceneTreeTween = get_tree().create_tween()\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
	tween.tween_property(label, "rect_position", progress_bar_edge, _point_tween_time)
	tween.tween_property(label, "rect_scale", Vector2.ONE * 0.8, _point_tween_time)
	tween.connect("finished", self, "_on_point_added", [label, value])

func decrement_points(value : float):
	# ...
	
	_progress_bar.value += value

func level_up():
	#var tween : SceneTreeTween = get_tree().create_tween().set_parallel(true)
	# do a shake or something
	pass

func level_down():
	#var tween : SceneTreeTween = get_tree().create_tween().set_parallel(true)
	pass

func _on_point_added(label : Label, value : float):
	label.queue_free()
	
	_progress_bar.value += value
