extends "res://scenes/objects/powerups/powerup.gd"

const _healing_particles_scene : PackedScene = preload("res://scenes/objects/standalone_particles/healing.tscn")


func _ready():
	AudioManager.play_sound("powerups/powerup_heal", false)

# override
func powerup_start(request_callback : FuncRef):
	.powerup_start(request_callback)
	
	request_callback.call_func("heal_full")
	var particles_instance := _healing_particles_scene.instance()
	particles_instance.global_position = request_callback.call_func("global_position")
	particles_instance.emitting = true
	get_tree().current_scene.add_child(particles_instance)
	
	_cleanup()
	emit_signal("finished", self)
