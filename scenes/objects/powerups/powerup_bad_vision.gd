extends "res://scenes/objects/powerups/powerup.gd"


# override
func powerup_start(request_callback : FuncRef):
	.powerup_start(request_callback)

func powerup_cleanup():
	queue_free()

func _on_life_timer_timeout():
	emit_signal("finished", self)
