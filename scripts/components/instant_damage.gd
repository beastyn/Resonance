extends Node
class_name InstantDamage

func get_instant_harm() -> void:
	PlayerSignals.emit_signal("get_instant_harm")
