extends Node
class_name DamagedComponent

@export var respawn_timer: Timer
@export var invulnarability_timer:Timer
@export var respawn_time: float = 2.0
@export var invulnarability_time = 5.0 

@export var sprite_to_blink: AnimatedSprite2D

var _is_invulnarable: bool = false
var _blink_tween: Tween

func start_damaged_sequence() ->void:
	if _is_invulnarable: return
		
	_is_invulnarable = true
	PlayerSignals.emit_signal("want_stop_moving")
	respawn_timer.start(respawn_time)	
	invulnarability_timer.start(invulnarability_time)
	_blink_on()

func _on_respawn_timer_timeout() -> void:
	PlayerSignals.emit_signal("need_respawn")
	respawn_timer.stop()

func _on_invularability_timer_timeout() -> void:
	_is_invulnarable = false
	_blink_off()
	invulnarability_timer.stop()

func _blink_on():
	_blink_tween = create_tween()
	_blink_tween.set_loops()  # infinite loops
	_blink_tween.tween_property(sprite_to_blink, "modulate:a", 0.2, 0.15)
	_blink_tween.tween_property(sprite_to_blink, "modulate:a", 1.0, 0.15)

func _blink_off():
	if _blink_tween and _blink_tween.is_valid():
		_blink_tween.kill()		
	sprite_to_blink.modulate.a = 1.0
