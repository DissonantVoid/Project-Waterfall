extends Node

var _is_slow : bool = false
var _slowing_factor : float = 0.25
var _is_fast : bool = false
var _accelerating_factor : float = 2.0

func _set_slowing(speed : bool):
	_is_slow = speed
	
func _set_accelerating(speed : bool):
	_is_fast = speed
