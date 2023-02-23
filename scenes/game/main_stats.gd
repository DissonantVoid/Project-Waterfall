extends Control

onready var _results_label : RichTextLabel = $MarginContainer/VBoxContainer/VBoxContainer/Results
onready var _stats_grid : GridContainer = $MarginContainer/VBoxContainer/GridContainer
onready var _text : RichTextLabel = $MarginContainer/VBoxContainer/VBoxContainer/Results
onready var _buttons_container : HBoxContainer = $MarginContainer/VBoxContainer/VBoxContainer/Buttons

const _fade_time : float = 0.1
const _text_reveal_time : float = 2.0
const _time_between_stats_n_text : float = 1.2

# the threshold represents the min value for this Grade to be considered
# the Grade text is based on the stat that hits the threshold and has the highest priority
const _grade_weights : Dictionary = {
	"saved_characters":{"good_txt":"Super Bald", "bad_txt":"Epic Fail", "threshold":100, "priority":1},
	"lost_characters" : {"good_txt":"Rock Food", "bad_txt":"Hairy",     "threshold":150, "priority":1},
	"bird_food":       {"good_txt":"Bird Lover", "bad_txt":"Bird Food", "threshold":22, "priority":2},
	"level_changes"   :{"good_txt":"Rollercoaster Rick", "bad_txt":"Git Gud", "threshold":12, "priority":3},
	"hit_hazards"     :{"good_txt":"Phoenix ", "bad_txt":"Rest in Pieces",    "threshold":20, "priority":4},
	"used_powerups"   :{"good_txt":"Hacker", "bad_txt":"Addicted",      "threshold":16, "priority":5}
}

func _ready():
	# extract info from LevelData
	var result_text : String =\
		"You've [color=green]saved[/color] everyone!" if LevelData.game_won else\
		"The bucket has been [color=red]destroyed[/color]"
	
	var stats : Dictionary = LevelData.get_stats()
	$MarginContainer/VBoxContainer/GridContainer/Saved.text      = str(stats["characters saved"])
	$MarginContainer/VBoxContainer/GridContainer/Lost.text       = str(stats["characters lost"])
	$MarginContainer/VBoxContainer/GridContainer/BirdFood.text   = str(stats["bird food"])
	$MarginContainer/VBoxContainer/GridContainer/Powerups.text   = str(stats["powerups collected"])
	$MarginContainer/VBoxContainer/GridContainer/Hazards.text    = str(stats["hazards hit"])
	$MarginContainer/VBoxContainer/GridContainer/Health.text     = str(stats["health taken"])
	$MarginContainer/VBoxContainer/GridContainer/Levelups.text   = str(stats["level ups"])
	$MarginContainer/VBoxContainer/GridContainer/Leveldowns.text = str(stats["level downs"])
	
	# calculate the Grade
	# TODO: cleanup this mess
	var threshold_passed : Array
	if stats["characters saved"] - stats["characters lost"] > _grade_weights["saved_characters"]["threshold"]:
		threshold_passed.push_back("saved_characters")
	elif stats["characters saved"] - stats["characters lost"] < -_grade_weights["lost_characters"]["threshold"]:
		threshold_passed.push_back("lost_characters")
	
	if stats["bird food"] > _grade_weights["bird_food"]["threshold"]:
		threshold_passed.push_back("bird_food")
	if stats["powerups collected"] > _grade_weights["used_powerups"]["threshold"]:
		threshold_passed.push_back("used_powerups")
	if stats["hazards hit"] > _grade_weights["hit_hazards"]["threshold"]:
		threshold_passed.push_back("hit_hazards")
	if stats["level ups"] + stats["level downs"] > _grade_weights["level_changes"]["threshold"]:
		threshold_passed.push_back("level_changes")
	
	var grade_text : String
	if threshold_passed.empty():
		# didn't break any threshold
		if LevelData.game_won:
			grade_text = "Filthy Casual"
		else:
			grade_text = "As Boring As It Gets"
	elif threshold_passed.size() == _grade_weights.size():
		# brock all damn thresholds!
		if LevelData.game_won:
			grade_text = "Pixel Perfect"
		else:
			grade_text = "Jaggies"
	else:
		var priority_threshold : String = threshold_passed[0]
		for threshold_key in threshold_passed:
			if _grade_weights[threshold_key]["priority"] > _grade_weights[priority_threshold]["priority"]:
				priority_threshold = threshold_key
		
		if LevelData.game_won:
			grade_text = _grade_weights[priority_threshold]["good_txt"]
		else:
			grade_text = _grade_weights[priority_threshold]["bad_txt"]
	
	
	_results_label.bbcode_text = "[center]" + result_text
	_results_label.bbcode_text += '\n'
	_results_label.bbcode_text += "[color=yellow]Grade[/color]: " + grade_text + "[/center]"
	
	# gradually show elements
	for child in _stats_grid.get_children():
		child.modulate.a = 0.0
	_text.percent_visible = 0
	_buttons_container.modulate.a = 0.0
	
	var tween : SceneTreeTween = get_tree().create_tween()
	tween.tween_interval(1.0)
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
