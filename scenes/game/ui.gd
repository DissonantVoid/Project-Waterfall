extends CanvasLayer

signal LevelUp

onready var _jumpers_label : Label = $MarginContainer/HBoxContainer/Jumpers
onready var _saved_label : Label = $MarginContainer/HBoxContainer/Saved

var _jumpers : int = 0
var _saved : int = 0

var _levelup_chars : int

func set_levelup_chars(levelup_chars : int):
	_levelup_chars = levelup_chars

func increment_jumpers():
	_jumpers += 1
	_jumpers_label.text = "Jumpers: " + str(_jumpers)

func increment_saved():
	_saved += 1
	_saved_label.text = "Saved: " + str(_saved)
	if _saved % _levelup_chars == 0:
		emit_signal("LevelUp")
