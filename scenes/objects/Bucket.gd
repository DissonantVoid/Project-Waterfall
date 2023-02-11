extends KinematicBody2D

signal character_saved

onready var _front_sprite : Sprite = $Front

const _shine_shader : ShaderMaterial = preload("res://resources/godot/shine_shader.tres")

const _front_spr_fade_time : float = 0.3
const _hold_time : float = 0.48 # a character is saved after staying in bucket for this time
const _max_rotation : float = 45.0
var _characters_in_bucket : Array = [] # [{character, timeLeftToScore},..]


func _process(delta : float):
	# check bodies in bucket
	for i in range(_characters_in_bucket.size()-1, -1, -1):
		var entry : Dictionary = _characters_in_bucket[i]
		var timer : float = entry["time_left"]
		timer -= delta
		entry["time_left"] = timer
		if timer <= 0:
			entry["character"].queue_free()
			_characters_in_bucket.erase(entry)
			
			_update_front_spr_visibility()
			emit_signal("character_saved")

func _physics_process(delta):
	# follow mouse
	global_position = lerp(global_position, get_global_mouse_position(), 0.2) # TODO: frame dependent lerp
	rotation_degrees = clamp(get_global_mouse_position().x-global_position.x, -_max_rotation, _max_rotation)

func _onbody_entered(body : Node):
	if body is Character:
		_characters_in_bucket.append({"character":body, "time_left":_hold_time})
		body.set_material(_shine_shader)
		
		_update_front_spr_visibility()

func _on_body_exited(body : Node):
	if body is Character:
		for entry in _characters_in_bucket:
			if entry["character"] == body:
				_characters_in_bucket.erase(entry)
				body.set_material(null)
				
				_update_front_spr_visibility()
				break

func _update_front_spr_visibility():
	var color : Color = Color.white if _characters_in_bucket.empty() else Color.transparent
	
	if _front_sprite.modulate != color:
		var tween : SceneTreeTween = get_tree().create_tween()
		tween.tween_property(_front_sprite, "modulate", color, _front_spr_fade_time)
