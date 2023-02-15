tool
extends TextureButton

export(String) var _text : String setget _set_text

onready var _label : Label = $Label

const _normal_font_color : Color = Color.black
const _hover_font_color : Color = Color("65fec1")


func _set_text(value : String):
	if is_inside_tree() == false:
		yield(self, "ready")
	
	_text = value
	_label.text = value

func _ready():
	_label.add_color_override("font_color", _normal_font_color)

func _on_mouse_entered():
	_label.add_color_override("font_color", _hover_font_color)

func _on_mouse_exited():
	_label.add_color_override("font_color", _normal_font_color)
