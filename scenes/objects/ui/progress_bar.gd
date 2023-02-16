tool
extends Control

# built in progress bar doesn't support tiling :(
# more manual work for me

# NOTE: the texture must contain 6 tiles, layed in a similar order to res:/textures/progress_bar.png
# NOTE: textures can use AnimatedTexture

export(float) var min_value : float setget _set_min_value
export(float) var max_value : float setget _set_max_value
export(float) var value : float setget _set_value

export(Texture) var _on_texture : Texture setget _set_on_texture
export(Texture) var _off_texture : Texture setget _set_off_texture

# top left tile is to the left of margin_left and top of margin_center
# bottom left is left of margin_left, bottom of margin_center
# top center is between margin_left and margin_right, top of margin_center
# bottom center is between margin_left and margin_right, bottom of margin_center
# top right is right of margin_right, top of margin_center
# bottom right is right of margin_right, bottom of margin_center
export(float) var _margin_right : float setget _set_margin_right # offset from right
export(float) var _margin_left : float setget _set_margin_left # offset from left
export(float) var _margin_center : float setget _set_margin_center # offset from the top

func _set_on_texture(value : Texture):
	_on_texture = value
	update()

func _set_off_texture(value : Texture):
	_off_texture = value
	update()

func _set_margin_right(value : float):
	_margin_right = max(value, 0)
	update()

func _set_margin_left(value : float):
	_margin_left = max(value, 0)
	update()

func _set_margin_center(value : float):
	_margin_center = max(value, 0)
	update()

func _set_min_value(value : float):
	min_value = clamp(value, 0, max_value)
	update()

func _set_max_value(value : float):
	if value >= min_value && value >= 0:
		max_value = value
		update()

func _set_value(new_value : float):
	value = clamp(new_value, min_value, max_value)
	update()

func _ready():
	pass

func _draw():
	# ignore update() calls before all export variables are ready
	if is_inside_tree() == false:
		return
	
	var tex_size : Vector2 = _off_texture.get_size()
	var start_tile_width : float = _margin_left
	var mid_tile_width : float = tex_size.x - _margin_right - _margin_left
	var end_tile_width : float = _margin_right
	
	# first corners
	draw_texture_rect_region(
		_off_texture,
		Rect2(Vector2.ZERO, Vector2(_margin_left, _margin_center)),
		Rect2(Vector2.ZERO, Vector2(_margin_left, _margin_center))
	)
	draw_texture_rect_region(
		_off_texture,
		Rect2(Vector2(0, _margin_center), Vector2(_margin_left, tex_size.y - _margin_center)),
		Rect2(Vector2(0, _margin_center), Vector2(_margin_left, tex_size.y - _margin_center))
	)
	
	# middle
	for i in range(start_tile_width, _get_minimum_size().x - end_tile_width, mid_tile_width):
		# TODO: there is an overlape between the last middle tile and the last corner tile
		draw_texture_rect_region(
			_off_texture,
			Rect2(Vector2(i, 0), Vector2(mid_tile_width, _margin_center)),
			Rect2(Vector2(_margin_left, 0), Vector2(mid_tile_width, _margin_center))
		)
		draw_texture_rect_region(
			_off_texture,
			Rect2(Vector2(i, _margin_center), Vector2(mid_tile_width, tex_size.y - _margin_center)),
			Rect2(Vector2(_margin_left, _margin_center), Vector2(mid_tile_width, tex_size.y - _margin_center))
		)
	
	# last corners
	draw_texture_rect_region(
		_off_texture,
		Rect2(Vector2(_get_minimum_size().x - end_tile_width, 0), Vector2(tex_size.x - _margin_right, _margin_center)),
		Rect2(Vector2(tex_size.x - _margin_right, 0), Vector2(tex_size.x - _margin_right, _margin_center))
	)
	draw_texture_rect_region(
		_off_texture,
		Rect2(Vector2(_get_minimum_size().x - end_tile_width, _margin_center), Vector2(tex_size.x - _margin_right, tex_size.y - _margin_center)),
		Rect2(Vector2(tex_size.x - _margin_right, 0), Vector2(tex_size.x - _margin_right, tex_size.y - _margin_center))
	)

func _get_minimum_size() -> Vector2:
	return rect_size
