tool
extends TextureButton

export(String) var text : String setget _set_text

onready var _label : Label = $Label

const _normal_font_color : Color = Color.black
const _hover_font_color : Color = Color.white

# TODO: any change to this class will cause all instances to reset their export data
#       see https://github.com/godotengine/godot-proposals/issues/1012
#       for now a solution is to close all scenes that use this before
#       making a change, then go to scene->reload saved scenes

func _set_text(value : String):
	if is_inside_tree() == false:
		yield(self, "ready")
	
	text = value
	_label.text = value

func _ready():
	_label.add_color_override("font_color", _normal_font_color)

func _on_mouse_entered():
	_label.add_color_override("font_color", _hover_font_color)
	AudioManager.play_sound("button_hover", false)

func _on_mouse_exited():
	_label.add_color_override("font_color", _normal_font_color)

func _on_button_pressed():
	AudioManager.play_sound("button_press", false)
