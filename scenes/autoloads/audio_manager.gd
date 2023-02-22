extends Node

const _sfx_folder : String = "res://resources/sounds/"
var _directory : Directory = Directory.new()
var _active_loops : Dictionary


func play_sound(sound_name : String, random_pitch : bool, volume : float = 0.0):
	var full_path : String = _sfx_folder + sound_name + ".ogg"
	assert(_directory.file_exists(full_path), "audio file doesn't exist")
	
	var audio_player : AudioStreamPlayer =\
		_create_audio_player(full_path, volume, false)
	
	if random_pitch:
		audio_player.pitch_scale = Utility.rng.randf_range(0.8, 1.2)

func play_sound_loop(sound_name : String, volume : float = 0.0):
	var full_path : String = _sfx_folder + sound_name + ".ogg"
	assert(_directory.file_exists(full_path), "audio file doesn't exist")
	if _active_loops.has(sound_name): return
	
	var audio_player : AudioStreamPlayer =\
		_create_audio_player(full_path, volume, true)
	
	_active_loops[sound_name] = audio_player

func stop_loop(sound_name : String):
	assert(_active_loops.has(sound_name), "attempting to stop a sound that doesn't exist")
	_active_loops[sound_name].queue_free()
	_active_loops.erase(sound_name)

func _create_audio_player(stream_path : String, volume : float, is_loop : bool) -> AudioStreamPlayer:
	var audio_player : AudioStreamPlayer = AudioStreamPlayer.new()
	var stream : AudioStreamOGGVorbis = load(stream_path)
	assert(stream.loop == is_loop, "audio stream loop setting doesn't match the desired loop choice")
	
	audio_player.stream = stream
	audio_player.connect("finished", self, "_on_stream_finished", [audio_player])
	add_child(audio_player)
	audio_player.play()
	
	return audio_player

func _on_stream_finished(audio_player : AudioStreamPlayer):
	audio_player.queue_free()
