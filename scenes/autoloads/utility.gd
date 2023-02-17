extends Node

var rng : RandomNumberGenerator = RandomNumberGenerator.new()


func _init():
	randomize()
	rng.randomize()
