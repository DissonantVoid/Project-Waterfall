extends "res://scenes/objects/powerups/powerup.gd"


func _ready():
	AudioManager.play_sound("powerups/powerup_bad_vision", false)

# override
func powerup_start(request_callback : FuncRef):
	.powerup_start(request_callback)

func _on_life_timer_timeout():
	_cleanup()
	emit_signal("finished", self)
