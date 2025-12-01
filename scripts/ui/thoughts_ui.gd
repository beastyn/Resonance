extends Control
class_name ThoughtsUI

@export var panel: Panel
@export var thought_text: RichTextLabel
@export var timer: Timer
@export var animation_duration: float = 0.5
@export var text_duration: float = 5.0

var panel_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	panel.scale = Vector2.ZERO	

func open_panel(text: String) -> void:
	if panel.scale != Vector2.ZERO: panel.scale = Vector2.ZERO
	thought_text.text = text
	if panel_tween: panel_tween.kill()
	panel_tween = create_tween()
	panel_tween.tween_property(panel, "scale", Vector2(1.0, 1.0), animation_duration).set_ease(Tween.EASE_IN)
	timer.start(text_duration)
	
func close_panel() -> void:
	panel_tween.kill()
	panel_tween = create_tween()
	panel_tween.tween_property(panel, "scale", Vector2(0.0, 0.0), animation_duration).set_ease(Tween.EASE_OUT)

func _on_timer_timeout() -> void:
	timer.stop()
	close_panel()
