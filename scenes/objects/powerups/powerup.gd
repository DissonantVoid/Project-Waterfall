extends Node2D

# base class for all powerups
# call me a crazy perfectionist, but this is a great way
# to protect from spaghetti code, while insuring a great
# level of customization.. customizability? customato? you get the idea

signal finished(powerup)

var _request_callback : FuncRef


func powerup_start(request_callback : FuncRef):
	_request_callback = request_callback

func _cleanup():
	# helper function
	AudioManager.play_sound("powerups/powerup_over", false)
	queue_free()
