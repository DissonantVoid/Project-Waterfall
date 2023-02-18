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

# TODO: slowing down the entire game has some issues, like characters taking
#       longer inside the bucket to count as a score, and pause button
#       getting affected as well

func _process(delta):
	global_position = _request_callback.call_func("global_position") + _clock_offset

# override
func powerup_start(request_callback : FuncRef):
	.powerup_start(request_callback)
	
	#Engine.time_scale = 0.1
	Utility._set_slowing(true)
	_timer.start()

# override
func powerup_cleanup():
	#Engine.time_scale = 1.0
	Utility._set_slowing(false)
	queue_free()

func _on_life_timer_timeout():
	emit_signal("finished", self)
