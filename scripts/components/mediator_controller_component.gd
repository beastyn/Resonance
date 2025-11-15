extends Node
class_name MediatorControllerComponent

func ask_to_listen(center: Node2D) -> void:
	PlayerSignals.emit_signal("want_to_listen", center.global_position)

func ask_to_activate_wave(wave_data: WaveData) -> void:
	PlayerSignals.emit_signal("want_to_activate_wave", wave_data)

func ask_to_sing(mouse_position: Vector2, wave_data: WaveData) -> void:
	PlayerSignals.emit_signal("want_to_sing", mouse_position, wave_data)

func ask_to_stop_sing() -> void:
	PlayerSignals.emit_signal("want_to_stop_sing")
