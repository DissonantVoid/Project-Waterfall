extends AnimatedSprite

const _audio_path : String = "res://resources/sounds/secret_message.ogg"


func _ready():
	global_position = Vector2(LevelData.view_size.x, LevelData.view_size.y / 2)
	var audio_file : AudioStreamOGGVorbis = load(_audio_path)
	
	# movement
	var tween : SceneTreeTween = get_tree().create_tween()
	tween.tween_property(self, "global_position:x", 0.0, audio_file.get_length())
	
	var audio_name : String = _audio_path.get_file().get_basename()
	AudioManager.play_sound(audio_name, false, 4.0)
	
	yield(tween, "finished")
	queue_free()
