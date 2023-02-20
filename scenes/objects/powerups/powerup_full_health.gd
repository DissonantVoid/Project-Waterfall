extends "res://scenes/objects/powerups/powerup.gd"


# override
func powerup_start(request_callback : FuncRef):
	.powerup_start(request_callback)
	
	request_callback.call_func("heal_full")
	# TODO: do some animation or particles or something
	emit_signal("finished", self)

# override
func powerup_cleanup():
	queue_free()
