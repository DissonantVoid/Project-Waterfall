extends CanvasLayer

onready var _transitino_container : Control = $Transition
onready var _characters_container : Control = $Transition/Characters
onready var _background : ColorRect = $Transition/Background
onready var _mouse_blocker : Control = $MouseBlocker

const _character_in_time : float = 0.03
const _character_out_time : float = 0.024
var _master_bus_idx : int = AudioServer.get_bus_index("Master")
const _low_volume_value : int = -40

var _is_changing : bool


func _ready():
	_transitino_container.show()
	
	for character in _characters_container.get_children():
		character.modulate.a = 0.0
	_background.modulate.a = 0.0

func change_scene(scene_name : String):
	if _is_changing:
		return
	
	_is_changing = true
	_mouse_blocker.show()
	
	var volume_before_fade : int = AudioServer.get_bus_volume_db(_master_bus_idx)
	var all_characters_in_time : float = _characters_container.get_child_count() * _character_in_time
	var all_characters_out_time : float = _characters_container.get_child_count() * _character_out_time
	
	# tween characters in
	var tween : SceneTreeTween = create_tween().set_parallel(true)
	tween.tween_property(_background, "modulate:a", 1.0, all_characters_in_time)
	tween.tween_method(self, "_set_master_volume", volume_before_fade, _low_volume_value, all_characters_in_time)
	
	var char_tween : SceneTreeTween = create_tween()
	for i in range(_characters_container.get_child_count()-1, -1, -1):
		var character := _characters_container.get_child(i)
		char_tween.tween_property(character, "modulate:a", 1.0, _character_in_time)
		char_tween.parallel()
		char_tween.tween_property(character, "rect_scale", character.rect_scale, _character_in_time)\
			.from(Vector2.ZERO)
		
	char_tween.tween_interval(1.0) # delay so transition isn't too fast
	
	# change scene
	yield(char_tween,"finished")
	get_tree().change_scene(scene_name)
	
	# remove characters and reset volume
	tween = create_tween().set_parallel(true)
	tween.tween_property(_background, "modulate:a", 0.0, all_characters_out_time)
	tween.tween_method(self, "_set_master_volume", _low_volume_value, volume_before_fade, all_characters_out_time)
	
	char_tween = create_tween() # tween becomes invalid after finishing
	char_tween.parallel()
	
	for character in _characters_container.get_children():
		char_tween.tween_property(character, "modulate:a", 0.0, _character_out_time)
	yield(char_tween,"finished")
	
	_is_changing = false
	_mouse_blocker.hide()

func restart_scene():
	change_scene(get_tree().current_scene.filename)

func _set_master_volume(volume : float):
	AudioServer.set_bus_volume_db(_master_bus_idx,volume)
