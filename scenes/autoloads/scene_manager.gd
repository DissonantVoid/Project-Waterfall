extends CanvasLayer

onready var _screen_capture : TextureRect = $ScreenCapture
var _curr_screen_texture : ImageTexture = ImageTexture.new()

const _tween_time : float = 0.9
const _audio_tween_time : float = 0.95
var _master_bus_idx : int = AudioServer.get_bus_index("Master")
const _low_volume_value : int = -24

var _is_changing : bool

func change_scene(scene_name : String):
	if _is_changing:
		return
	
	_is_changing = true
	
	# screen texture
	var viewport_image : Image = get_tree().root.get_texture().get_data()
	viewport_image.flip_y()
	_curr_screen_texture.create_from_image(viewport_image)
	_screen_capture.texture = _curr_screen_texture
	_screen_capture.show()
	
	# change scene and move screen texture out of view
	get_tree().change_scene(scene_name)
	yield(get_tree(),"idle_frame")
	
	var tween : SceneTreeTween = get_tree().create_tween()
	tween.tween_method(self, "_set_master_volume", 0, _low_volume_value, _audio_tween_time)
	tween.parallel()
	tween.tween_property(_screen_capture.material, "shader_param/offset", 0.5, _tween_time)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	yield(tween,"finished")
	_screen_capture.texture = null
	_screen_capture.hide()
	
	#reset
	_screen_capture.material.set_shader_param("offset", 0.0) # NOTE: this has to be 0.0 and not 0, as 0 will make tween treat offset as int and hence give error on next tween "missmatch between int and float"
	tween = get_tree().create_tween() # tween becomes invalid after finishing, creating new one
	tween.tween_method(self,"_set_master_volume", _low_volume_value, 0, _audio_tween_time)
	yield(tween,"finished")
	_is_changing = false

func restart_scene():
	change_scene(get_tree().current_scene.filename)

func _set_master_volume(volume : float):
	AudioServer.set_bus_volume_db(_master_bus_idx,volume)
