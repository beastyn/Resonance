extends Node
class_name InstantDamage

@export var timer: Timer
@export var sec_until_respawn: float = 3.0

func start_instant_damage_sequnce() -> void:
	PlayerSignals.emit_signal("get_instant_harm")
	timer.start(sec_until_respawn)

func _on_timer_timeout() -> void:
	PlayerSignals.emit_signal("need_respawn")
	timer.stop()
