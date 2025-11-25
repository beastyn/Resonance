extends Node
class_name GameManager

@onready var enemy_manager: Node = $"../EnemyManager"
@export var exception_nodes: Array[Node]

@export var mediator: Mediator
@export var canvas_modulate: CanvasModulate
@export var listening_canvas_color: Color

var _old_canvas_color: Color
var _canvas_color_change_tween: Tween

var _saved_nodes: Array[Node] = []

func _ready() -> void:
	mediator.listen_action_component.is_listening.connect(_on_is_listening)
	mediator.listen_action_component.stop_listening_wave.connect(_on_stop_listening_wave)
	_old_canvas_color = canvas_modulate.color

func enable_freeze() -> void:
	_saved_nodes = exception_nodes.duplicate()
	for n in _saved_nodes:
		if n:
			n.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().set_deferred("paused", true)
	
func disable_freeze() -> void:
	get_tree().set_deferred("paused", false)
	for n in _saved_nodes:
		if n:
			n.process_mode = Node.PROCESS_MODE_INHERIT
	_saved_nodes.clear()

func _on_is_listening() -> void:
	if _canvas_color_change_tween: _canvas_color_change_tween.kill()
		
	_canvas_color_change_tween = create_tween()
	_canvas_color_change_tween.tween_property(canvas_modulate, "color", listening_canvas_color, 0.5)	

func _on_stop_listening_wave(wave_area: WaveArea) -> void:
	if !_canvas_color_change_tween.is_valid(): 
		_canvas_color_change_tween.kill()
		_canvas_color_change_tween = create_tween()
	_canvas_color_change_tween.tween_property(canvas_modulate, "color", _old_canvas_color, 0.5)
	_canvas_color_change_tween.finished.connect(_on_canvas_tween_finished)

func _on_canvas_tween_finished() -> void:
	_canvas_color_change_tween.kill()
