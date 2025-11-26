extends Node

signal transition_finished

@onready var transition_scene := preload("res://scenes/Transition.tscn")
var instance : Node = null
var fade_rect : ColorRect = null

var _fade_tween: Tween
var _scene_path:String
var _duration: float

func _ready():
	# instantiate UI overlay once and keep
	instance = transition_scene.instantiate()
	add_child(instance)
	fade_rect = instance.get_node("FadeRect")
	instance.visible = true
	fade_rect.modulate.a = 0.0

# simple fade coroutine helpers using Tween (Godot 4 create_tween)
func transite_to(scene_path: String, duration: float) ->void:
	_scene_path = scene_path
	_duration = duration
	_fade_tween = create_tween()
	_fade_tween.tween_property(fade_rect, "modulate:a", 1.0, duration)
	_fade_tween.finished.connect(_on_fade_out_finished)

# fade out, change scene, fade in
func _on_fade_out_finished() -> void:
	_fade_tween.finished.disconnect(_on_fade_out_finished)
	_fade_tween.kill()
	get_tree().change_scene_to_file(_scene_path)
	await get_tree().process_frame
	_fade_in(_duration)

func _fade_in(duration: float) -> void:
	_fade_tween = create_tween()
	_fade_tween.tween_property(fade_rect, "modulate:a", 0.0, duration)
	_fade_tween.finished.connect(_on_fade_in_finished)

func _on_fade_in_finished() -> void:
	_fade_tween.finished.disconnect(_on_fade_in_finished)
	_fade_tween.kill()
	emit_signal("transition_finished")
