extends Node

@onready var scene_manager: SceneManager = %SceneManager

@export var resonator: Resonator
@export var timer: Timer
@export var finish_fireballs_in:float = 1.0

@export var cutscene_camera: Camera2D
@export var original_camera_position: Vector2
@export var cutscene_camera_position: Node2D
@export var camera_transition_speed: float

@export var enemy_manager: EnemyManager
@export var mage_sprite: AnimatedSprite2D
@export var fireballs: CPUParticles2D
@export var explosion: CPUParticles2D

@export var text1: RichTextLabel
@export var text2: RichTextLabel

var _camera_tween: Tween
var _was_played: bool = false

func _ready() -> void:
	scene_manager.need_start_cutscene.connect(_on_need_cutscene)
	original_camera_position = cutscene_camera.global_position
	text2.modulate.a = 0.0

func _on_need_cutscene() -> void:
	if _was_played: return
	#animate camera
	_was_played = true
	resonator.need_disable_inputs(true)
	_camera_tween = create_tween()
	_camera_tween.tween_property(cutscene_camera, "global_position", cutscene_camera_position.global_position, camera_transition_speed).set_ease(Tween.EASE_IN)	
	mage_sprite.play("scared")
	fireballs.emitting = true
	mage_sprite.animation_finished.connect(_on_animation_finished)
	enemy_manager.start_custscene()
	timer.start(finish_fireballs_in)

	#destroy mage
	#finish cutscene

func _on_animation_finished() ->void:
	_camera_tween.kill()
	_camera_tween = create_tween()
	_camera_tween.tween_property(cutscene_camera, "position", Vector2.ZERO, camera_transition_speed).set_ease(Tween.EASE_IN)
	_camera_tween.finished.connect(_on_camera_tween_finished)
	explosion.emitting = true
	mage_sprite.visible = false
	text2.visible = false

func _on_timer_timeout() -> void:
	fireballs.emitting = false
	var text_tween = create_tween()
	text_tween.tween_property(text1,"modulate:a", 0.0, 0.2)
	text_tween.finished.connect(_on_text_tween_finished)
	

func _on_camera_tween_finished() -> void:
	_camera_tween.kill()
	resonator.need_disable_inputs(false)

func _on_text_tween_finished() -> void:
	var tween = create_tween()
	tween.tween_property(text2,"modulate:a", 1.0, 0.2)
