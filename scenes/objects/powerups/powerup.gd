extends Node2D

# base class for all powerups
# call me a crazy perfectionist, but this is a great way
# to protect from spaghetti code, while insuring a great
# level of customization.. customizability? customato? you get the idea

signal finished(powerup)

var _request_callback : FuncRef

# TODO: consider removing powerup_cleanup and allow powerups
#       to cleanup on they're own before emmiting 

func powerup_start(request_callback : FuncRef):
	_request_callback = request_callback

func powerup_cleanup():
	# don't forget to free this node yourself
	queue_free()
