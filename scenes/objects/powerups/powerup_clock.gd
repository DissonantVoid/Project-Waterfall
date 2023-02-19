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


func _process(delta):
	global_position = _request_callback.call_func("global_position") + _clock_offset

# override
func powerup_start(request_callback : FuncRef):
	.powerup_start(request_callback)
	
	request_callback.call_func("modify_time", {"factor":0.2})
	_timer.start()

# override
func powerup_cleanup():
	_request_callback.call_func("modify_time", {"factor":1.0})
	queue_free()

func _on_life_timer_timeout():
	emit_signal("finished", self)
