extends Control

onready var _progress : TextureRect = $Progress
onready var _chars_container : Control = $CharactersContainer

const _characters_sprite : StreamTexture = preload("res://resources/textures/characters.png")
const _char_sprite_size : int = 16
const _backflip_time : float = 0.6

var _min_value : float
var _max_value : float
var _value : float
const _start_color : Color = Color("fab43c")
const _end_color : Color = Color("d54d2d")


# TODO: the progress bar is brocken, we should win once the meter reaches the end
#       but it keeps going as if we had a level left

func _ready():
	_progress.material.set_shader_param("start_color", _start_color)
	_progress.material.set_shader_param("end_color", _end_color)
	
	# add characters, in a random order
	var characters_count : int = _characters_sprite.get_width() / _char_sprite_size
	var random_regions : Array
	for i in characters_count:
		random_regions.append(
			Rect2(i*_char_sprite_size, 0, _char_sprite_size, _char_sprite_size)
		)
	random_regions.shuffle()
	
	for i in characters_count:
		var texture_rect : TextureRect = TextureRect.new()
		var atlas : AtlasTexture = AtlasTexture.new()
		atlas.atlas = _characters_sprite
		atlas.region = random_regions[i]
		texture_rect.texture = atlas
		
		var half_char_size : float = _char_sprite_size/2
		texture_rect.rect_pivot_offset = Vector2.ONE * half_char_size
		# space enenly
		texture_rect.rect_position.x = range_lerp(
			i, 0, characters_count-1,
			half_char_size, _chars_container.rect_size.x - half_char_size # NOTE: TexRect pivot is at top-left, so we subtract half size
		)
		texture_rect.rect_position.y = -half_char_size
		texture_rect.rect_scale *= 0.65
		_chars_container.add_child(texture_rect)

func setup(min_value : float, max_value : float):
	_min_value = min_value
	_max_value = max_value

func increment_value(increment : float):
	var old_edge_pos : Vector2 = get_progress_edge_position()
	_set_value(_value + increment)
	
	# do character backflip animation if appropriate. we get the first character
	# after the progress edge then we increment the progress bar and see
	# if character is now behind the bar, if so do a flip
	for character in _chars_container.get_children():
		var center_position : Vector2 =\
			character.rect_global_position + (character.rect_size/2) * character.rect_scale
		if center_position.x > old_edge_pos.x && center_position.x <= get_progress_edge_position().x:
			var rotation_tween : SceneTreeTween = get_tree().create_tween()
			rotation_tween.tween_property(character, "rect_rotation", 360.0, _backflip_time)\
				.from(0.0)
			
			var move_tween : SceneTreeTween = get_tree().create_tween()
			var character_pos : Vector2 = character.rect_position
			move_tween.tween_property(character, "rect_position:y", character_pos.y - 8, _backflip_time/2)
			move_tween.tween_property(character, "rect_position:y", character_pos.y, _backflip_time/2)

func decrement_value(decrement : float):
	_set_value(_value + decrement)

func get_progress_edge_position() -> Vector2:
	return _progress.rect_global_position + Vector2(
		range_lerp(
			_value,
			_min_value,
			_max_value,
			0, rect_size.x
		),
		rect_position.y
	)

func _set_value(new_value : float):
	_value = clamp(new_value, _min_value, _max_value)
	var normalized_value : float = range_lerp(_value, _min_value, _max_value, 0, 1)
	_progress.material.set_shader_param("weight", normalized_value)
