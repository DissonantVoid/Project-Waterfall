extends Node

signal time_factor_changed

# NOTE: can be used in other things like stats
# for the sake of consistency only main.gd have access in main.tscn
# but any scene can use its signals

var view_size : Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/width"),
	ProjectSettings.get_setting("display/window/size/height")
) * 2

var time_factor : float = 1.0 setget _set_time_factor
var game_won : bool = false


func _set_time_factor(value : float):
	time_factor = value
	emit_signal("time_factor_changed")

func reset():
	time_factor = 1.0
	game_won = false
