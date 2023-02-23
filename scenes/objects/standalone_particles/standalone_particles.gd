extends Particles2D

# for all particles that run independently and delete themselves once done
# like death particles where parent no longer exists for example


func _ready():
	# credits: https://github.com/godotengine/godot-proposals/issues/649
	var time : float = lifetime * (2 - explosiveness) / speed_scale
	get_tree().create_timer(time).connect("timeout", self, "queue_free")
