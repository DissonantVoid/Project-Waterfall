extends "res://scenes/objects/powerups/powerup.gd"

onready var _bridge : StaticBody2D = $Bridge
onready var _bridge_collider : CollisionShape2D = $Bridge/CollisionShape2D
onready var _bridge_color : ColorRect = $Bridge/ColorRect

const _tilt_angle : float = 30.0
const _bridge_height : float = 20.0
const _y_limits : Vector2 = Vector2(90.0, 180.0) # shouldn't spawn the bridge very close to top or bottom of screen
const _width_padding : float = 30.0 # additional width near edge of screen, so when we rotate bridge you can't see its end


func _ready():
	_bridge_collider.shape.extents.y = _bridge_height / 2
	_bridge_color.rect_size.y = _bridge_height
	_bridge_color.rect_position.x = -_bridge_color.rect_size.y / 2

# override
func powerup_start(request_callback : FuncRef):
	.powerup_start(request_callback)
	
	var pos : Vector2 = request_callback.call_func("global_position")
	prints(pos.y, clamp(pos.y, _y_limits[0], _y_limits[1]))
	pos.y = clamp(pos.y, _y_limits[0], _y_limits[1])
	_bridge.global_position.y = pos.y
	
	# extend bridge towards the opposite side (if we spawn in the right half extend to left..)
	var width : float = LevelData.view_size.x / 2
	if pos.x > LevelData.view_size.x / 2:
		_bridge.global_position.x = LevelData.view_size.x + _width_padding
		
		_bridge_collider.shape.extents.x = width / 2
		_bridge_collider.position.x = -_bridge_collider.shape.extents.x
		_bridge_color.rect_position.x = -width
		_bridge_color.rect_size.x = width
		
		_bridge.rotation_degrees = -_tilt_angle
	else:
		_bridge.global_position.x = -_width_padding
		
		_bridge_collider.shape.extents.x = width / 2
		_bridge_collider.position.x = _bridge_collider.shape.extents.x
		_bridge_color.rect_position.x = 0
		_bridge_color.rect_size.x = width
		
		_bridge.rotation_degrees = _tilt_angle

# override
func powerup_cleanup():
	queue_free()

func _on_life_timer_timeout():
	emit_signal("finished", self)
