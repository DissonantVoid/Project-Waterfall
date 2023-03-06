extends Control

# NOTE: don't touch the UI nodes in this scene if you value your sanity

onready var _results_label : RichTextLabel = $MarginContainer/VBoxContainer/VBoxContainer/Results
onready var _stats_container : HBoxContainer = $MarginContainer/VBoxContainer/Stats
onready var _buttons_container : HBoxContainer = $MarginContainer/VBoxContainer/VBoxContainer/Buttons
onready var _stats_image : TextureRect = $Planks/StatsImage
onready var _continue_button : TextureButton = $MarginContainer/VBoxContainer/VBoxContainer/Buttons/Continue

const _palette_good : String = "#18722e"
const _palette_bad : String = "#8e041d"
const _palette_grade : String = "#2b0a68"
const _transition_time_short : float = 0.2
const _transition_time_long : float = 0.8
const _text_reveal_time : float = 2.0
const _stat_reveal_y_offset : float = 20.0
const _time_between_stats_n_text : float = 1.2
const _planks_tween_offset : float = 140.0

# the threshold represents the min value for this Grade to be considered
# the Grade text is based on the stat that hits the threshold and has the highest priority
# TODO: improve texts, also check texts for breaking all threshold and breaking non
const _grade_weights : Dictionary = {
	"saved_characters":{"good_txt":"Super Bald","bad_txt":"Epic Fail",       "threshold":110, "priority":5},
	"lost_characters" :{"good_txt":"Rock Food", "bad_txt":"Hairy",           "threshold":140, "priority":5},
	"bird_food"       :{"good_txt":"Bird Lover","bad_txt":"Bird Food",       "threshold":22, "priority":2},
	"level_changes"   :{"good_txt":"Rollercoaster Rick", "bad_txt":"Git Gud","threshold":12, "priority":4},
	"hit_hazards"     :{"good_txt":"Phoenix ", "bad_txt":"Rest in Pieces",   "threshold":20, "priority":3},
	"used_powerups"   :{"good_txt":"Hacker",   "bad_txt":"Addicted",         "threshold":16, "priority":6},
	"time_played"     :{"good_txt":"Zombie",   "bad_txt":"No Life",          "threshold":15*60, "priority":1}
}


func _ready():
	# extract info from LevelData
	var stats : Dictionary = LevelData.get_stats()
	$MarginContainer/VBoxContainer/Stats/Left/HBoxContainer/Saved.text        =\
		str(stats["characters saved"])
	$MarginContainer/VBoxContainer/Stats/Left/HBoxContainer2/Lost.text        =\
		str(stats["characters lost"])
	$MarginContainer/VBoxContainer/Stats/Left/HBoxContainer3/BirdFood.text    =\
		str(stats["bird food"])
	$MarginContainer/VBoxContainer/Stats/Left/HBoxContainer4/Powerups.text    =\
		str(stats["powerups collected"])
	$MarginContainer/VBoxContainer/Stats/Right/HBoxContainer5/Hazards.text    =\
		str(stats["hazards hit"])
	$MarginContainer/VBoxContainer/Stats/Right/HBoxContainer6/Health.text     =\
		str(stats["health taken"])
	$MarginContainer/VBoxContainer/Stats/Right/HBoxContainer7/Levelups.text   =\
		str(stats["level ups"])
	$MarginContainer/VBoxContainer/Stats/Right/HBoxContainer8/Leveldowns.text =\
		str(stats["level downs"])
	$MarginContainer/VBoxContainer/Stats/Left/HBoxContainer5/TimePlayed.text  =\
		str(stats["time played"] / 60)
	
	# calculate the Grade
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
	if stats["time played"] > _grade_weights["time_played"]["threshold"]:
		threshold_passed.push_back("time_played")
	
	var grade_text : String
	if threshold_passed.empty():
		# didn't break any threshold
		grade_text = "Filthy Casual" if LevelData.game_won else\
					"As Boring As It Gets"
	elif threshold_passed.size() == _grade_weights.size():
		# brock all damn thresholds!
		grade_text = "Pixel Perfect" if LevelData.game_won else\
					"Jaggies"
	else:
		var highest_priority_thresh : String = threshold_passed[0]
		for threshold_key in threshold_passed:
			if _grade_weights[threshold_key]["priority"] < _grade_weights[highest_priority_thresh]["priority"]:
				highest_priority_thresh = threshold_key
		
		var text_key : String = "good_txt" if LevelData.game_won else "bad_txt"
		grade_text = _grade_weights[highest_priority_thresh][text_key]
	
	# results
	var result_text : String
	if LevelData.game_won:
		_stats_image.texture.region.position.y = 0
		result_text = "You've [color=" + _palette_good + "]saved[/color] everyone!"
	else:
		_stats_image.texture.region.position.y = 64
		result_text = "The bucket has been [color=" + _palette_bad + "]destroyed[/color]"
	
	_results_label.bbcode_text = "[center]" +\
								  result_text + '\n' +\
								 "[color=" + _palette_grade + "]Grade:[/color] " + grade_text +\
								 "[/center]"
	
	_continue_button.visible = LevelData.game_won
	
	# gradually show elements #
	yield(get_tree(), "idle_frame")
	var left_plank : TextureRect = $Planks/MarginContainer/HBoxContainer/LeftPlanks
	left_plank.rect_position.x -= _planks_tween_offset
	var right_plank : TextureRect = $Planks/MarginContainer/HBoxContainer/RightPlanks
	right_plank.rect_position.x += _planks_tween_offset
	_stats_image.rect_position.y -= _planks_tween_offset
	
	var tween : SceneTreeTween = get_tree().create_tween()
	tween.tween_interval(2.0)
	
	# side planks
	tween.tween_property(
		left_plank, "rect_position:x", left_plank.rect_position.x + _planks_tween_offset, _transition_time_long
	)
	tween.parallel()
	tween.tween_property(
		right_plank, "rect_position:x", right_plank.rect_position.x - _planks_tween_offset, _transition_time_long
	)
	
	# stats
	_fade_tween_labels_recursive(tween, _stats_container)
	tween.tween_interval(_time_between_stats_n_text)
	
	# text
	_results_label.percent_visible = 0
	tween.tween_property(_results_label, "percent_visible", 1.0, _text_reveal_time)
	tween.parallel()
	
	# center plank
	tween.tween_property(
		_stats_image, "rect_position:y", _stats_image.rect_position.y + _planks_tween_offset, _transition_time_long
	)
	
	# buttons
	_buttons_container.modulate.a = 0.0
	tween.tween_property(_buttons_container, "modulate:a", 1.0, _transition_time_long)

func _on_continue_pressed():
	SceneManager.change_scene("res://scenes/game/ending.tscn")

func _on_restart_pressed():
	SceneManager.change_scene("res://scenes/game/main.tscn")

func _fade_tween_labels_recursive(tween : SceneTreeTween, root : Control):
	for child in root.get_children():
		if child is Label:
			var y_pos : float = child.rect_position.y
			
			child.modulate.a = 0.0
			tween.tween_property(child, "modulate:a", 1.0, _transition_time_short)
			tween.parallel()
			tween.tween_property(child, "rect_position:y", child.rect_position.y, _transition_time_short)\
				.from(child.rect_position.y - _stat_reveal_y_offset)
		
		_fade_tween_labels_recursive(tween, child)

func _on_image_anim_timeout():
	_stats_image.texture.region.position.x =\
		64.0 if _stats_image.texture.region.position.x == 0.0 else 0.0
