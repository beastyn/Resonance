extends Node
class_name  SingActionComponent

@export var area_to_sing_from: WaveArea

var is_singing: bool = false;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerSignals.want_to_activate_wave.connect(_on_want_to_activate_wave)
	PlayerSignals.want_to_sing.connect(_on_want_to_sing)
	PlayerSignals.want_to_stop_sing.connect(_on_want_to_stop_sing)

func _on_want_to_activate_wave(wave_data: WaveData) -> void:
	area_to_sing_from.set_active_wave_data(wave_data)

func _on_want_to_sing(mouse_position: Vector2) -> void:
	if !is_singing:
		area_to_sing_from.reset_activated_wave_travel_distance()
		area_to_sing_from.emit_wave_at_point(area_to_sing_from.global_position, true, (mouse_position - area_to_sing_from.global_position).normalized(), true)	
		is_singing=true
		area_to_sing_from.set_audio_from_data(area_to_sing_from.activated_wave)
		area_to_sing_from.start_wave_audio()
	if is_singing:
		area_to_sing_from.update_active_wave(area_to_sing_from.global_position, (mouse_position - area_to_sing_from.global_position).normalized())

func _on_want_to_stop_sing() -> void:
	if !is_singing: return
	area_to_sing_from.stop_emitting_wave()
	area_to_sing_from.stop_wave_audio()
	is_singing=false
