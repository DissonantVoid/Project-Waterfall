class_name Character
extends RigidBody2D

onready var _sprite : Sprite = $Sprite

const _char_count : int = 15 # how many characters are in the sprite sheet
const _char_sprite_size : int = 16


func _ready():
	var char_index : int = Utility.rng.randi_range(0, _char_count-1) * _char_sprite_size
	_sprite.region_rect.position.x = char_index
	
	apply_central_impulse(Vector2(Utility.rng.randf_range(-100, 100), 0))

func set_material(material : Material):
	_sprite.material = material
