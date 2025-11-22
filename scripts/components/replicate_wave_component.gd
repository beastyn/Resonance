extends Node
class_name  ReplicateWaveComponent

signal need_replica_wave(wave_area: WaveArea, wave_data: WaveData, pos: Vector2i)
signal remove_replica_wave(wave_area: WaveArea)
signal save_replica_wave(wave_data: WaveData)

@export var area_to_spawn_replica: WaveArea
@export var amplitude_change_step: float = 1
@export var frequncy_change_step: float = 1

var _replica_wave_data: WaveData
var _target_wave_data: WaveData
var _wave_mat: ShaderMaterial
var _particles: WaveEffectParticles
var _new_amplitude: float
var _new_frequency: float

func _ready() -> void:
	_replica_wave_data = area_to_spawn_replica.get_wave_data()
	_new_amplitude = _replica_wave_data.amplitude
	_new_frequency = _replica_wave_data.frequency

func set_target_wave_data(wave_data: WaveData) -> void:
	_target_wave_data = wave_data	
	_new_amplitude = 0.0
	_new_frequency = 0.0
	area_to_spawn_replica.set_default_wave_travel_distance(_target_wave_data.travel_distane)
	emit_signal("need_replica_wave", area_to_spawn_replica, _replica_wave_data, Vector2(0.5, 0.5))
	_particles = area_to_spawn_replica.active_wave_effect
	_wave_mat = _particles.particles.process_material as ShaderMaterial
	
func stop_replica_wave() -> void:
	remove_replica_wave.emit(area_to_spawn_replica)
	
func adjust_replica_amplitude(direction: float) -> void:	
	if not _wave_mat: return
	_new_amplitude += amplitude_change_step * direction
	_wave_mat.set_shader_parameter("amplitude", _new_amplitude)
	_check_resonance()
	
func adjust_replica_frequcy(direction: float) ->void:
	if not _wave_mat: return
	_new_frequency += frequncy_change_step * direction
	_wave_mat.set_shader_parameter("frequency", _new_frequency)
	_check_resonance()
	
func _check_resonance() -> void:
	if _particles.check_wave_resonance_by_data(_target_wave_data):
		emit_signal("save_replica_wave", _target_wave_data, area_to_spawn_replica.default_travel_distance)
		
	
