class_name Bucket
extends Node2D

signal character_saved
signal hit_hazard
signal powerup_picked
signal powerup_finished

onready var _front_sprite : Sprite = $Front

const _front_spr_fade_time : float = 0.3
const _hold_time : float = 0.48 # a character is saved after staying in bucket for this time
const _max_rotation : float = 45.0
var _prev_position : Vector2
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

func _physics_process(delta : float):
	# follow mouse
	var velocity : Vector2 = global_position - _prev_position
	var lerp_value : Vector2 = lerp(global_position, get_global_mouse_position(), 0.25) # TODO: frame dependent lerp
	global_position = lerp_value
	
	rotation_degrees = clamp(get_global_mouse_position().x-global_position.x, -_max_rotation, _max_rotation)
	
	_prev_position = global_position

func _on_body_entered_inside_area(body : Node):
	if body is Character:
		_characters_in_bucket.append({"character":body, "time_left":_hold_time})
		body.bucket_interacted(true)
		
		_update_front_spr_visibility()

func _on_body_exited_inside_area(body : Node):
	if body is Character:
		for entry in _characters_in_bucket:
			if entry["character"] == body:
				_characters_in_bucket.erase(entry)
				body.bucket_interacted(false)
				
				_update_front_spr_visibility()
				break

func _update_front_spr_visibility():
	var color : Color = Color.white if _characters_in_bucket.empty() else Color.transparent
	
	if _front_sprite.modulate != color:
		var tween : SceneTreeTween = get_tree().create_tween()
		tween.tween_property(_front_sprite, "modulate", color, _front_spr_fade_time)

func _on_detection_body_or_area_entered(object):
	if object is HazardFallingRock || object is HazardBird:
		object.queue_free()
		emit_signal("hit_hazard")
	elif object is PowerUpStone:
		var powerup_scene : String = object.pickup()
		var powerup_instance = load(powerup_scene).instance()
		powerup_instance.connect("finished", self, "_on_powerup_finished")
		
		yield(get_tree(), "idle_frame") # removing this causes issues with physics, godot moment
		get_tree().current_scene.add_child(powerup_instance)
		powerup_instance.powerup_start(funcref(self, "_powerup_request"))
		emit_signal("powerup_picked")

func _on_powerup_finished(powerup : Node2D):
	powerup.powerup_cleanup()
	emit_signal("powerup_finished")

func _powerup_request(request_string : String):
	# for when a powerup can't do something on its own, and
	# needs the bucket class to do it, like double its size etc..
	match request_string:
		"bucket_sprite":
			return _front_sprite
		"shrink":
			# is this gonna cause issues in the future?
			# looks very fragile
			var tween : SceneTreeTween = get_tree().create_tween()
			tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.4)
		"unshrink":
			scale = Vector2.ONE
