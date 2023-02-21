extends Control

onready var _results_label : RichTextLabel = $MarginContainer/VBoxContainer/VBoxContainer/Results


func _ready():
	# extract info from LevelData
	var result : String = "WON!" if LevelData.game_won else "LOST"
	var grade : String = "TODO"
	_results_label.bbcode_text = _results_label.bbcode_text.format([result, grade], "{var}")
	
	var stats : Dictionary = LevelData.get_stats()
	$MarginContainer/VBoxContainer/GridContainer/Saved.text      = str(stats["characters saved"])
	$MarginContainer/VBoxContainer/GridContainer/Lost.text       = str(stats["characters lost"])
	$MarginContainer/VBoxContainer/GridContainer/BirdFood.text   = str(stats["bird food"])
	$MarginContainer/VBoxContainer/GridContainer/Powerups.text   = str(stats["powerups collected"])
	$MarginContainer/VBoxContainer/GridContainer/Hazards.text    = str(stats["hazards hit"])
	$MarginContainer/VBoxContainer/GridContainer/Health.text     = str(stats["health taken"])
	$MarginContainer/VBoxContainer/GridContainer/Levelups.text   = str(stats["level ups"])
	$MarginContainer/VBoxContainer/GridContainer/Leveldowns.text = str(stats["level downs"])
	
	# TODO: grade based on stats

func _on_menu_pressed():
	SceneManager.change_scene("res://scenes/game/menu.tscn")

func _on_restart_pressed():
	SceneManager.change_scene("res://scenes/game/main.tscn")
