extends Control

onready var _results_label : RichTextLabel = $MarginContainer/VBoxContainer/VBoxContainer/Results
onready var _stats_grid : GridContainer = $MarginContainer/VBoxContainer/GridContainer
onready var _text : RichTextLabel = $MarginContainer/VBoxContainer/VBoxContainer/Results
onready var _buttons_container : HBoxContainer = $MarginContainer/VBoxContainer/VBoxContainer/Buttons

const _fade_time : float = 0.1
const _text_reveal_time : float = 2.5
const _time_between_stats_n_text : float = 1.2


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
	
	# gradually show elements
	for child in _stats_grid.get_children():
		child.modulate.a = 0.0
	_text.percent_visible = 0
	_buttons_container.modulate.a = 0.0
	
	var tween : SceneTreeTween = get_tree().create_tween()
	for child in _stats_grid.get_children():
		tween.tween_property(child, "modulate:a", 1.0, _fade_time)
	
	tween.tween_interval(_time_between_stats_n_text)
	
	tween.tween_property(_text, "percent_visible", 1.0, _text_reveal_time)
	tween.tween_property(_buttons_container, "modulate:a", 1.0, _fade_time)

func _on_menu_pressed():
	SceneManager.change_scene("res://scenes/game/menu.tscn")

func _on_restart_pressed():
	SceneManager.change_scene("res://scenes/game/main.tscn")

#func _trans_children_recursive(node : Node):
#	for child in node.get_children():
#		if child is CanvasItem:
#			child.modulate.a = 0.0
#			_trans_children_recursive(node)
