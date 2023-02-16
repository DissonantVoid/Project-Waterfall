extends "res://scenes/objects/powerups/powerup.gd"

const _magnet_offset : Vector2 = Vector2(0, -30)
var _bucket_sprite : Sprite
var _characters_in_range : Dictionary # dicts are more efficient here
const _pull_force : float = 200_000.0


func _process(delta):
	global_position = _bucket_sprite.global_position + _magnet_offset
	
	# pull characters
	for character in _characters_in_range.values():
		var direction : Vector2 = (character.global_position - global_position).normalized()
		character.apply_central_impulse(-direction * _pull_force * delta)
	
	update()

func _draw():
	for character in _characters_in_range.values():
		draw_line(to_local(global_position), to_local(character.global_position), Color.red, 4)

# override
func powerup_start(request_callback : FuncRef):
	.powerup_start(request_callback)
	
	_bucket_sprite = request_callback.call_func("bucket_sprite")

# override
func powerup_cleanup():
	queue_free()

func _on_body_entered(body):
	if body is Character:
		var id : int = body.get_instance_id()
		body.connect("body_exited", self, "_on_character_freed", [id])
		_characters_in_range[id] = body

func _on_body_exited(body):
	if body is Character:
		var id : int = body.get_instance_id()
		if _characters_in_range.has(id):
			body.disconnect("body_exited", self, "_on_character_freed")
			_characters_in_range.erase(id)

func _on_character_freed(id : int):
	_characters_in_range.erase(id)

func _on_life_timer_timeout():
	emit_signal("finished", self)
