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

func _process(delta):
	global_position = Vector2(100, 100) #TODO place it correctly

# override
func powerup_start(request_callback : FuncRef):
	.powerup_start(request_callback)
	
	Engine.time_scale = 0.1
	_timer.start()

# override
func powerup_cleanup():
	Engine.time_scale = 1.0
	queue_free()

func _on_LifeTimer_timeout():
	emit_signal("finished", self)
