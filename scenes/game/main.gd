extends Node2D

onready var _spawn_timer : Timer = $Timers/SpawnTimer
onready var _chars_container : Node2D = $Characters
onready var _bucket : KinematicBody2D = $Bucket
onready var _ui : CanvasLayer = $UI
onready var _clouds : Node2D = $Clouds

const _character_scene : PackedScene = preload("res://scenes/objects/character.tscn")

const _levelup_chars : int = 8
var _view_width : int = ProjectSettings.get_setting("display/window/size/width") * 2


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	_bucket.connect("CharScored",self,"_on_bucked_scored")
	_ui.set_levelup_chars(_levelup_chars)
	_ui.connect("LevelUp",self,"_on_levelup")
	
	_spawn_timer.start()

func _on_spawn_timeout() -> void:
	var instance := _character_scene.instance()
	_chars_container.add_child(instance)
	instance.global_position = Vector2(Utility.rng.randf_range(0, _view_width), -10)
	_ui.increment_jumpers()
	
	_spawn_timer.start()

func _on_bucked_scored():
	_ui.increment_saved(_bucket.global_position)

func _on_abyss_body_entered(body: Node) -> void:
	body.queue_free()

func _on_levelup() -> void:
	_spawn_timer.wait_time -= 0.2
