extends Control

onready var _temp_label : Label = $Label


func _ready():
	# extract info from LevelData
	_temp_label.text = "YOU WON!" if LevelData.game_won else "YOU LOST"

func _on_menu_pressed():
	SceneManager.change_scene("res://scenes/game/menu.tscn")
