extends "res://scenes/objects/powerups/powerup.gd"


# TODO: sometimes an object will not be detected by the shield, and will be
#       instead detected by the bucket first, I'm not sure why, tried giving it
#       higher area priority, and using physics_process instead of process
#       which made an improvement but it still hapends at fast speed
#       I think it's something to do with _request_callback.call_func("global_position")
#       returning a delayed position?

onready var _sprite : Sprite = $Sprite

const _initial_expand_time : float = 0.6


func _ready():
	var tween : SceneTreeTween = get_tree().create_tween()
	tween.tween_property(_sprite, "scale", Vector2.ONE, _initial_expand_time)\
		.from(Vector2.ZERO)

func _physics_process(delta : float):
	global_position = _request_callback.call_func("global_position")

# override
func powerup_start(request_callback : FuncRef):
	.powerup_start(request_callback)

# override
func powerup_cleanup():
	queue_free()

func _on_body_or_area_entered(object):
	if object is HazardBird || object is HazardFallingRock:
		object.queue_free()
		emit_signal("finished", self)
