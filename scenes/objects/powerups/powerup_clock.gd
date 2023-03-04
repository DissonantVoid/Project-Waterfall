#############################################
#                                           #
#  Power-up: Clock                          #
#                                           #
#  Description: When the player catch it    #
#               the time of the gameplay    #
#               will slow down.             #
#                                           #
#############################################
extends "res://scenes/objects/powerups/powerup.gd"

onready var _sprite : Sprite = $Sprite
onready var _timer : Timer = $LifeTimer

const _clock_offset : Vector2 = Vector2(0, +30)
const _master_bus_idx : int = 0
var _slow_pitch_effect : AudioEffectPitchShift = AudioEffectPitchShift.new()


func _ready():
	AudioManager.play_sound("powerups/powerup_time_slowdown", false)
	
	_slow_pitch_effect.pitch_scale = 0.6
	_slow_pitch_effect.oversampling = 8

func _process(delta : float):
	global_position = _request_callback.call_func("global_position") + _clock_offset

# override
func powerup_start(request_callback : FuncRef):
	.powerup_start(request_callback)
	
	request_callback.call_func("modify_time", {"factor":0.2})
	AudioServer.add_bus_effect(_master_bus_idx, _slow_pitch_effect)
	_timer.start()

func _on_life_timer_timeout():
	_request_callback.call_func("modify_time", {"factor":1.0})
	_remove_pitch_effect()
	_cleanup()
	emit_signal("finished", self)

func _exit_tree():
	# in case we leave the scene
	if _slow_pitch_effect != null:
		_remove_pitch_effect()

func _remove_pitch_effect():
	for i in AudioServer.get_bus_effect_count(_master_bus_idx):
		if AudioServer.get_bus_effect(_master_bus_idx, i) == _slow_pitch_effect:
			AudioServer.remove_bus_effect(_master_bus_idx, i)
			_slow_pitch_effect = null
			return
	
	push_error("pitch scale effect was not removed")
