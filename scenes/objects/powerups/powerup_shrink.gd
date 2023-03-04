extends "res://scenes/objects/powerups/powerup.gd"

onready var _timer : Timer = $ShrinkTimer


func _ready():
	AudioManager.play_sound("powerups/powerup_shrink", false)

# override
func powerup_start(request_callback : FuncRef):
	.powerup_start(request_callback)
	
	request_callback.call_func("shrink", {"factor":0.8})
	_timer.start()

func _on_shrink_timer_timeout():
	_request_callback.call_func("unshrink")
	_cleanup()
	
	emit_signal("finished", self)
