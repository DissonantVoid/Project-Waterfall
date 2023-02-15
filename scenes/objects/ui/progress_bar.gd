extends Range

# built in progress bar doesn't support tiling :(
# more manual work for me

# TODO: THIS IS UNFINISHED

export(Texture) var _off_texture : Texture
export(Texture) var _on_texture : Texture
export(int) var _tile_size : int setget _set_tile_size


func _set_tile_size(value : int):
	if value < 0: return
	
	_tile_size = value

func _ready():
	pass

func _draw():
	#draw_texture_rect(_off_texture,
	pass
