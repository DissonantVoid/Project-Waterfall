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
var _slow_pitch_effect : AudioEffectPitchShift = AudioEffectPitchShift.new()


func _ready():
	_slow_pitch_effect.pitch_scale = 0.6
	_slow_pitch_effect.oversampling = 8

func _process(delta : float):
	global_position = _request_callback.call_func("global_position") + _clock_offset

# override
func powerup_start(request_callback : FuncRef):
	.powerup_start(request_callback)
	
	request_callback.call_func("modify_time", {"factor":0.2})
	AudioServer.add_bus_effect(0, _slow_pitch_effect, 0)
	_timer.start()

# override
func powerup_cleanup():
	_request_callback.call_func("modify_time", {"factor":1.0})
	AudioServer.remove_bus_effect(0, 0)
	queue_free()

func _on_life_timer_timeout():
	emit_signal("finished", self)

func _exit_tree():
	AudioServer.remove_bus_effect(0, 0)
