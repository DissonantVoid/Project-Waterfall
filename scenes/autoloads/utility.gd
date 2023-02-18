extends Node

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var _is_slow : bool = false
var _slowing_factor : float = 0.25
var _is_fast : bool = false

func _set_slowing(speed : bool):
	_is_slow = speed
	
func _set_accelerating(speed : bool):
	_is_fast = speed

func _init():
	randomize()
	rng.randomize()
