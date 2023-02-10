extends CanvasLayer

signal leveled_up
signal all_chars_collected

onready var _jumpers_label : Label = $MarginContainer/HBoxContainer/Jumpers/Label
onready var _saved_label : Label = $MarginContainer/HBoxContainer/Saved/Label
onready var _progress : ProgressBar = $MarginContainer/Progress
onready var _saved_ui_position : Vector2 = _saved_label.rect_global_position

const _point_tween_time : float = 0.8
var _point_label_font : DynamicFont
var _jumpers : int = 0
var _saved : int = 0

var _levelup_chars : int


func _ready():
	_point_label_font = DynamicFont.new()
	_point_label_font.size = 18
	_point_label_font.font_data = preload("res://resources/fonts/m5x7.ttf")

func setup(levelup_chars : int, chars_to_win : int):
	_progress.max_value = chars_to_win
	_levelup_chars = levelup_chars

func increment_jumpers():
	_jumpers += 1
	_jumpers_label.text = str(_jumpers)

func increment_saved(bucket_position : Vector2):
	# animate a +1 point moving from bucket to UI
	var label : Label = Label.new()
	label.add_font_override("font", _point_label_font)
	label.add_color_override("font_color", Color.black)
	label.text = "+1"
	# /2 because view is twice the screen size (camera is zoomed out), this feels hacky
	label.rect_position = bucket_position / 2
	add_child(label)
	
	var tween : SceneTreeTween = get_tree().create_tween()\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(label, "rect_position", _saved_ui_position, _point_tween_time)
	tween.connect("finished", self, "_on_saved_point_added", [label])

func _on_saved_point_added(label : Label):
	label.queue_free()
	
	_progress.value += 1
	_saved += 1
	_saved_label.text = str(_saved)
	
	if _progress.value == _progress.max_value:
		emit_signal("all_chars_collected")
	elif _saved % _levelup_chars == 0:
		emit_signal("leveled_up")
