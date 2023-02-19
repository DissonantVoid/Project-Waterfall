extends Node

signal time_factor_changed

# NOTE: can be used in other things like stats
# for the sake of consistency only main.gd have access in main.tscn
# but any scene can use its signals

var time_factor : float = 1.0 setget _set_time_factor


func _set_time_factor(value : float):
	time_factor = value
	emit_signal("time_factor_changed")

func reset():
	time_factor = 1.0
