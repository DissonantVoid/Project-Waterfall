extends "res://scenes/objects/powerups/powerup.gd"

onready var _timer : Timer = $ShrinkTimer


# override
func powerup_start(request_callback : FuncRef):
	.powerup_start(request_callback)
	
	request_callback.call_func("shrink", {"factor":0.8})
	_timer.start()

# override
func powerup_cleanup():
	_request_callback.call_func("unshrink")
	queue_free()

func _on_shrink_timer_timeout():
	emit_signal("finished", self)
