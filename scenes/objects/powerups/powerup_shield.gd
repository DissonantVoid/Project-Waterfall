extends "res://scenes/objects/powerups/powerup.gd"

onready var _inner_sprite : Sprite = $ShieldInner
onready var _outer_sprite : Sprite = $ShieldOuter
onready var _life_timer : Timer = $LifeTimer

const _initial_expand_time : float = 0.4


func _ready():
	AudioManager.play_sound("powerups/powerup_shield", false)
	
	var tween : SceneTreeTween = get_tree().create_tween()
	tween.tween_property(_inner_sprite, "scale", Vector2.ONE, _initial_expand_time)\
		.from(Vector2.ZERO)
	tween.parallel()
	tween.tween_property(_outer_sprite, "scale", Vector2.ONE, _initial_expand_time)\
		.from(Vector2.ZERO)

func _physics_process(delta : float):
	global_position = _request_callback.call_func("global_position")

# override
func powerup_start(request_callback : FuncRef):
	.powerup_start(request_callback)

func _on_body_or_area_entered(object):
	if object is HazardBird || object is HazardFallingRock:
		object.destroy()
		_life_timer.stop()
		
		_cleanup()
		emit_signal("finished", self)

func _on_life_timer_timeout():
	_cleanup()
	emit_signal("finished", self)
