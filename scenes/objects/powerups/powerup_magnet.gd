extends "res://scenes/objects/powerups/powerup.gd"

onready var _sprite : Sprite = $Sprite
onready var _collider : CollisionPolygon2D = $CharactersDetection/CollisionPolygon2D
onready var _life_timer : Timer = $LifeTimer

const _magnet_offset : Vector2 = Vector2(0, -20)
var _characters_in_range : Dictionary # dicts are more efficient here
const _min_pull_force : float = 120.0
const _max_pull_force : float = 700.0
var _furthest_collider_point_distance : float


func _ready():
	AudioManager.play_sound("powerups/magnet", false)
	
	# find the furthest point in the collider, we relly on that to iplement
	# the slow down where the closest an object is, the lower the pull force
	# would be
	for point in _collider.polygon:
		var distance_to_point : float = global_position.distance_to(point)
		if distance_to_point > _furthest_collider_point_distance:
			_furthest_collider_point_distance = distance_to_point

func _process(delta : float):
	global_position = _request_callback.call_func("global_position") + _magnet_offset
	var average_characters_position : Vector2 = Vector2.ZERO
	
	# pull characters
	for character in _characters_in_range.values():
		var direction : Vector2 =\
			(character["body"].global_position - global_position).normalized()
		average_characters_position += to_local(character["body"].global_position)
		var force : float = range_lerp(
			global_position.distance_to(character["body"].global_position),
			0, _furthest_collider_point_distance,
			_min_pull_force, _max_pull_force
		)
		
		# pull towards bucket, use velocity to predict next bucket position
		# we manually move the character instead of using physics forces, bacuse...
		# well you try to do that
		character["last_pos"] = character["body"].global_position
		character["body"].global_position += -direction * force * delta
	
	# rotate magnet to face average position
	var new_rotation : float
	if _characters_in_range.empty() == false:
		average_characters_position /= _characters_in_range.size()
		new_rotation = average_characters_position.angle() + PI/2
	else:
		new_rotation = 0
	
	_sprite.rotation = lerp(_sprite.rotation, new_rotation, 0.2)
	
	update()

func _draw():
	for character in _characters_in_range.values():
		draw_line(to_local(global_position), to_local(character["body"].global_position), Color.red, 2)

# override
func powerup_start(request_callback : FuncRef):
	.powerup_start(request_callback)

func _on_body_entered(body):
	if body is Character:
		var id : int = body.get_instance_id()
		body.connect("body_exited", self, "_on_character_freed", [id])
		_characters_in_range[id] = {"body":body, "last_pos":Vector2.ZERO}
		
		# stop character velocity, helps with calculations
		body.linear_velocity = Vector2.ZERO

func _on_body_exited(body):
	if body is Character:
		var id : int = body.get_instance_id()
		if _characters_in_range.has(id):
			body.disconnect("body_exited", self, "_on_character_freed")
			
			# keep momentum
			var character : Dictionary = _characters_in_range[id]
			character["body"].linear_velocity =\
				(character["body"].global_position - character["last_pos"]) * 10
			
			_characters_in_range.erase(id)

func _on_character_freed(body : PhysicsBody2D, id : int):
	_characters_in_range.erase(id)

func _on_life_timer_timeout():
	_cleanup()
	emit_signal("finished", self)
