extends KinematicBody2D

signal CharScored

onready var _front_sprite : Sprite = $Front

const _shine_shader : ShaderMaterial = preload("res://resources/godot/shine_shader.tres")

const _front_spr_fade_time : float = 0.3
const _score_time : float = 0.5 # a score is added when character stays in bucket for that time
const _max_rotation : float = 45.0
var _bodies_in_bucket : Array = [] # [{character,timeLeftToScore},..]


func _process(delta: float) -> void:
	# follow mouse
	global_position = lerp(global_position, get_global_mouse_position(), 0.2) # TODO: frame dependent lerp
	rotation_degrees = clamp(get_global_mouse_position().x-global_position.x, -_max_rotation, _max_rotation)
	
	# check bodies in bucket
	for entry in _bodies_in_bucket:
		var timer : float = entry["time_left"]
		timer -= delta
		entry["time_left"] = timer
		if timer <= 0:
			entry["character"].queue_free()
			_bodies_in_bucket.erase(entry)
			emit_signal("CharScored")
			
			# wait for character to get freed
			yield(get_tree(),"idle_frame")
			_update_front_spr_visibility()

func _onbody_entered(body: Node) -> void:
	if body is Character:
		_bodies_in_bucket.append({"character":body, "time_left":_score_time})
		body.set_material(_shine_shader)
		
		_update_front_spr_visibility()

func _on_body_exited(body: Node) -> void:
	if body is Character:
		for entry in _bodies_in_bucket:
			if entry["character"] == body:
				_bodies_in_bucket.erase(entry)
				body.set_material(null)
				
				_update_front_spr_visibility()
				break

func _update_front_spr_visibility():
	var color : Color = Color.white if _bodies_in_bucket.empty() else Color.transparent
	var tween : SceneTreeTween = get_tree().create_tween()
	tween.tween_property(_front_sprite, "modulate", color, _front_spr_fade_time)
