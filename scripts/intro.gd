extends Control
class_name Intro

@export var timer: Timer
@export var phrases: Dictionary[TextureRect, float]
@export var text_still_time: float = 5.0
@export var text_delay_appear: float = 0.5
@export var next_scene_ref: String
@export var player: AudioStreamPlayer2D
var current_index: int = 0
var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for phrase in phrases:
		phrase.modulate.a = 0.0
			
	tween =create_tween()
	tween.tween_property(phrases.keys()[0], "modulate:a", 1.0, text_delay_appear)
	timer.start(phrases.values()[0])
	current_index = 0


func _on_timer_timeout() -> void:
	timer.stop()
	tween.kill()
	tween =create_tween()
	tween.tween_property(phrases.keys()[current_index], "modulate:a", 0.0, text_delay_appear).set_ease(Tween.EASE_IN)
	current_index += 1
	if current_index == phrases.keys().size():
		TransitionManager.transite_to(next_scene_ref, 2.0)	
		var tween = create_tween()    
		tween.tween_property(player, "volume_db", -30.0, 1.0)	
		return
	tween.finished.connect(_on_tween_finished)

func _on_tween_finished() -> void:
	tween.kill()
	tween =create_tween()
	tween.tween_property(phrases.keys()[current_index], "modulate:a", 1.0, text_delay_appear)
	timer.start(phrases.values()[current_index])
