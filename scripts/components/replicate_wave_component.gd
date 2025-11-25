extends Node
class_name  ReplicateWaveComponent

signal need_replica_wave(wave_area: WaveArea, wave_data: WaveData, pos: Vector2i)
signal remove_replica_wave(wave_area: WaveArea)
signal save_replica_wave(wave_data: WaveData)
signal amlitude_adjusted(direction: float)
signal frequency_adjusted(direction: float)

@export var area_to_spawn_replica: WaveArea
@export var amplitude_change_step: float = 1
@export var frequency_change_step: float = 1


var _replica_wave_data: WaveData
var _target_wave_data: WaveData
var _wave_mat: ShaderMaterial
var _particles: WaveEffectParticles
var _default_amplitude: float
var _default_frequency: float
var _new_amplitude: float
var _new_frequency: float

func _ready() -> void:
	_replica_wave_data = area_to_spawn_replica.get_wave_data()
	_default_amplitude = _replica_wave_data.amplitude
	_default_frequency = _replica_wave_data.frequency

func set_target_wave_data(wave_data: WaveData) -> void:
	_target_wave_data = wave_data	
	_new_amplitude = _default_amplitude
	_new_frequency = _default_frequency
	area_to_spawn_replica.set_default_wave_travel_distance(_target_wave_data.travel_distane)
	emit_signal("need_replica_wave", area_to_spawn_replica, _replica_wave_data, Vector2(0.5, 0.5))
	_particles = area_to_spawn_replica.active_wave_effect
	_wave_mat = _particles.particles.process_material as ShaderMaterial
	
	area_to_spawn_replica.set_audio_from_data(_replica_wave_data)
	area_to_spawn_replica.start_wave_audio()
	
func stop_replica_wave() -> void:
	remove_replica_wave.emit(area_to_spawn_replica)
	area_to_spawn_replica.stop_wave_audio()

	
func adjust_replica_amplitude(direction: float) -> void:	
	if not _wave_mat: return
	_new_amplitude += amplitude_change_step * direction
	_wave_mat.set_shader_parameter("amplitude", _new_amplitude)
	_check_resonance()
	emit_signal("amlitude_adjusted", direction)
	area_to_spawn_replica.change_volume(direction)
	
func adjust_replica_frequency(direction: float) ->void:
	if not _wave_mat: return
	_new_frequency += frequency_change_step * direction
	_wave_mat.set_shader_parameter("frequency", _new_frequency)
	_check_resonance()
	emit_signal("frequency_adjusted", direction)
	area_to_spawn_replica.change_pitch(direction)
	
	
func _check_resonance() -> void:
	if _particles.check_wave_resonance_by_data(_target_wave_data):
		emit_signal("save_replica_wave", _target_wave_data, area_to_spawn_replica.default_travel_distance)
		
	
