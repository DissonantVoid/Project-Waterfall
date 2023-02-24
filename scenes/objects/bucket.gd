class_name Bucket
extends Node2D

signal character_saved
signal hit_hazard
signal powerup_picked
signal powerup_finished
signal time_factor_changed(factor)
signal about_to_be_destroyed
signal destroyed

onready var _full_sprite : Sprite = $Full # used mainly for animation
onready var _full_sprite_animator : AnimationPlayer = $Full/AnimationPlayer
onready var _front_sprite : Sprite = $Front
onready var _back_sprite : Sprite = $Back
onready var _health_bar : Sprite = $HealthBar
onready var _detection_collider : CollisionShape2D = $DetectionArea/CollisionShape2D
onready var _inside_collider : CollisionShape2D = $InsideArea/CollisionShape2D

const _front_spr_fade_time : float = 0.3
const _hold_time : float = 0.48 # a character is saved after staying in bucket for this time
const _max_rotation : float = 45.0
var _prev_position : Vector2
var _characters_in_bucket : Array = [] # [{character, timeLeftToScore},..]

const _max_health : int = 3
var _current_health : int = _max_health


func _process(delta : float):
	# check bodies in bucket
	for i in range(_characters_in_bucket.size()-1, -1, -1):
		var entry : Dictionary = _characters_in_bucket[i]
		var timer : float = entry["time_left"]
		timer -= delta
		entry["time_left"] = timer
		if timer <= 0:
			entry["character"].free_self(true)
			_characters_in_bucket.erase(entry)
			
			_update_front_spr_visibility()
			emit_signal("character_saved")

func _physics_process(delta : float):
	# follow mouse
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

func _change_health(by_value : int):
	var clamped_value : int = clamp(_current_health + by_value, 0, _max_health)
	if clamped_value == _current_health:
		return
	
	_current_health = clamped_value
	
	_health_bar.region_rect.position.x = _current_health * _health_bar.region_rect.size.x - _health_bar.region_rect.size.x
	_front_sprite.region_rect.position.x = _current_health * _front_sprite.region_rect.size.x - _front_sprite.region_rect.size.x
	_back_sprite.region_rect.position.x = _current_health * _back_sprite.region_rect.size.x - _back_sprite.region_rect.size.x

func _on_detection_body_or_area_entered(object):
	if object is HazardFallingRock || object is HazardBird:
		object.destroy()
		_change_health(-1)
		LevelData.increment_stat("hazards hit", 1)
		
		if _current_health == 0:
			_front_sprite.visible = false
			_back_sprite.visible = false
			_full_sprite.visible = true
			_health_bar.visible = false
			_detection_collider.set_deferred("disabled", true)
			_inside_collider.set_deferred("disabled", true)
			_full_sprite.region_rect.position.x = 32
			_full_sprite_animator.play("explode")
			emit_signal("about_to_be_destroyed")
		else:
			emit_signal("hit_hazard")
		
	elif object is PowerUpStone:
		var powerup_scene : String = object.pickup()
		var powerup_instance = load(powerup_scene).instance()
		powerup_instance.connect("finished", self, "_on_powerup_finished")
		
		yield(get_tree(), "idle_frame") # removing this causes issues with physics, godot moment
		get_tree().current_scene.add_child(powerup_instance)
		powerup_instance.powerup_start(funcref(self, "_powerup_request"))
		LevelData.increment_stat("powerups collected", 1)
		emit_signal("powerup_picked")
	
	elif object is Health:
		object.queue_free()
		_change_health(+1)
		LevelData.increment_stat("health taken", 1)

func _on_powerup_finished(powerup : Node2D):
	powerup.powerup_cleanup()
	emit_signal("powerup_finished")

func _on_back_sprite_animation_finished(anim_name : String):
	if anim_name == "explode":
		emit_signal("destroyed")

func _powerup_request(request_string : String, args : Dictionary = {}):
	# for when a powerup can't do something on its own, and
	# needs the bucket class to do it, like double its size etc..
	match request_string:
		"global_position":
			return global_position
		"shrink":
			# is this gonna cause issues in the future?
			# looks very fragile
			var tween : SceneTreeTween = get_tree().create_tween()
			tween.tween_property(self, "scale", Vector2.ONE * args["factor"], 0.4)
		"unshrink":
			scale = Vector2.ONE
		"modify_time":
			emit_signal("time_factor_changed", args["factor"])
		"heal_full":
			_change_health(_max_health)
		_:
			assert(false, "request string doesn't exist")
