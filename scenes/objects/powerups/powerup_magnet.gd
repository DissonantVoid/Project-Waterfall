extends "res://scenes/objects/powerups/powerup.gd"

onready var _sprite : Sprite = $Sprite
onready var _collider : CollisionPolygon2D = $CharactersDetection/CollisionPolygon2D

const _magnet_offset : Vector2 = Vector2(0, -30)
var _bucket_sprite : Sprite
var _characters_in_range : Dictionary # dicts are more efficient here
const _pull_force : float = 100_000.0
var _furthest_collider_point_distance : float


func _ready():
	# find the furthest point in the collider, we relly on that to iplement
	# the slow down where the closest an object is, the lower the pull force
	# would be
	for point in _collider.polygon:
		var distance_to_point : float = global_position.distance_to(point)
		if distance_to_point > _furthest_collider_point_distance:
			_furthest_collider_point_distance = distance_to_point

func _process(delta):
	global_position = _bucket_sprite.global_position + _magnet_offset
	var average_characters_position : Vector2 = Vector2.ZERO
	
	# pull characters
	for character in _characters_in_range.values():
		var direction : Vector2 = (character.global_position - global_position).normalized()
		average_characters_position += to_local(character.global_position)
		var force : float = range_lerp(
			global_position.distance_to(character.global_position),
			0, _furthest_collider_point_distance,
			0, _pull_force
		)
		character.apply_central_impulse(-direction * force * delta)
	
	# rotate magnet to face average position
	if _characters_in_range.empty() == false:
		average_characters_position /= _characters_in_range.size()
		_sprite.rotation = average_characters_position.angle() + PI/2
	else:
		_sprite.rotation = 0
	
	update()

func _draw():
	for character in _characters_in_range.values():
		draw_line(to_local(global_position), to_local(character.global_position), Color.red, 2)

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
