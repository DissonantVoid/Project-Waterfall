extends Camera2D

enum ShakeLevel {low, med, high}

onready var _shake_timer : Timer = $ShakeTimer

const _shake_data : Dictionary = {
	ShakeLevel.low: {"offsets_count":5, "shake_strength":15},
	ShakeLevel.med: {"offsets_count":8, "shake_strength":30},
	ShakeLevel.high: {"offsets_count":10, "shake_strength":80}
}
var _noise : OpenSimplexNoise = OpenSimplexNoise.new()
var _curr_shake_level : int
var _curr_noise_input : float = 0
var _offsets_left : int
var _is_shaking : bool = false


func _ready():
	_noise.seed = Utility.rng.randi()
	_noise.octaves = 4
	_noise.period = 20.0
	_noise.persistence = 0.8

func shake(level : int):
	if _is_shaking:
		_stop_shaking()
	
	_is_shaking = true
	_curr_shake_level = level
	_offsets_left = _shake_data[_curr_shake_level]["offsets_count"]
	
	_shake_timer.start()

func _on_shake_timeout():
	var strength : float = _shake_data[_curr_shake_level]["shake_strength"]
	offset.x = _noise.get_noise_1d(_curr_noise_input) * strength
	offset.y = _noise.get_noise_1d(_curr_noise_input + 1000) * strength
	_curr_noise_input += 1.0
	
	_offsets_left -= 1
	if _offsets_left == 0:
		_stop_shaking()
	else:
		_shake_timer.start()

func _stop_shaking():
	offset = Vector2.ZERO
	_is_shaking = false
