extends Node

const _sfx_folder : String = "res://resources/sounds/"
var _directory : Directory = Directory.new()
var _active_loops : Dictionary


# TODO: add checks to make sure that we don't call play_sound with a
#       sound that loops, or play_sound_loop with a sound that doesn't loop
func play_sound(sound_name : String, random_pitch : bool):
	var full_path : String = _sfx_folder + sound_name + ".ogg"
	assert(_directory.file_exists(full_path), "audio file doesn't exist")
	
	var audio_player : AudioStreamPlayer =\
		_create_audio_player(full_path)
	
	if random_pitch:
		audio_player.pitch_scale = Utility.rng.randf_range(0.8, 1.2)

func play_sound_loop(sound_name : String):
	var full_path : String = _sfx_folder + sound_name + ".ogg"
	assert(_directory.file_exists(full_path), "audio file doesn't exist")
	if _active_loops.has(sound_name): return
	
	var audio_player : AudioStreamPlayer =\
		_create_audio_player(sound_name + ".ogg")
	
	_active_loops[sound_name] = audio_player

func stop_loop(sound_name : String):
	assert(_active_loops.has(sound_name), "attempting to stop a sound that doesn't exist")
	_active_loops[sound_name].queue_free()
	_active_loops.erase(sound_name)

func _create_audio_player(stream_path : String) -> AudioStreamPlayer:
	var audio_player : AudioStreamPlayer = AudioStreamPlayer.new()
	audio_player.stream = load(stream_path)
	audio_player.connect("finished", self, "_on_stream_finished", [audio_player])
	add_child(audio_player)
	audio_player.play()
	
	return audio_player

func _on_stream_finished(audio_player : AudioStreamPlayer):
	audio_player.queue_free()
