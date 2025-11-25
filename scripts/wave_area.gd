extends Area2D
class_name WaveArea

# You can either assign a WaveData resource in the editor, or override fields.
@export var default_wave_resource: Resource
@export var default_travel_distance: float = 200.0
@export var resonance_effect: ResonanceEffect

@export var audio_player: AudioStreamPlayer2D
@export var listen_volume: float = 0.0
@export var volume_delta: float = 0.2
@export var pitch_delta: float = 0.05

var _default_volume

var activated_wave: WaveData = null

var active_wave_effect: WaveEffectParticles = null

func  _ready() -> void:
	if audio_player: 
		_default_volume = audio_player.volume_db
	
	var wave_data = default_wave_resource as WaveData
	audio_player.pitch_scale = 1.0 + (wave_data.frequency - 1) * pitch_delta
	listen_volume = wave_data.amplitude*volume_delta/5.0
	if wave_data.name!="Default": start_wave_audio()
	
	ResonanceSignals.start_resonance.connect(_on_start_resonance)
	ResonanceSignals.update_resonance.connect(_on_update_resonance)
	ResonanceSignals.stop_resonance.connect(_on_stop_resonance)

# Return a fresh WaveData instance representing this area's parameters
func get_wave_data() -> WaveData:
	if default_wave_resource is WaveData:
		return (default_wave_resource.duplicate() as WaveData)		
	return null

func get_activated_wave_data() -> WaveData:
	if activated_wave:
		return activated_wave
	return null

func set_active_wave_data(wave_data: WaveData) -> void:
	activated_wave = wave_data;

func stop_wave_audio() -> void:
	audio_player.stop()
	
func start_wave_audio() -> void:
	audio_player.play()

func set_audio_from_data(wave_data: WaveData) -> void:
	if wave_data == null: wave_data = get_wave_data()
	audio_player.pitch_scale = 1.0 + (wave_data.frequency - 1) * pitch_delta
	audio_player.volume_db = wave_data.amplitude*volume_delta/5.0 	

func change_pitch(direction: float) -> void:
	audio_player.pitch_scale += direction*pitch_delta

func change_volume(direction: float) -> void:
	audio_player.volume_db += direction*volume_delta
		
func set_default_wave_travel_distance(travel_distance:float) -> void:	
	(default_wave_resource as WaveData).travel_distane = travel_distance

func reset_activated_wave_travel_distance() -> void:
	if not activated_wave: return
	activated_wave.travel_distane = default_travel_distance

func get_wave_particles() -> WaveEffectParticles:
	return active_wave_effect 
	
func emit_wave_at_point(pos: Vector2, needActivatedData:bool = false, direction: Vector2 = Vector2.ZERO, needCollision: bool = false) -> void:
	var activated_wave = get_activated_wave_data()
	var wave_data = activated_wave if needActivatedData && activated_wave else get_wave_data()
	active_wave_effect =  WavePool.obtain(self as Node2D) as Node2D
	if !needActivatedData: default_wave_resource.direction = direction
	active_wave_effect.init_from_pool(self as Node2D, wave_data, pos, direction, needCollision)
	if audio_player: audio_player.volume_db = listen_volume	

func update_active_wave(pos: Vector2, direction: Vector2) -> void:
	active_wave_effect.update_visuals(pos, direction)

func stop_emitting_wave() -> void:
	active_wave_effect.hide_wave()
	active_wave_effect = null
	if audio_player: audio_player.volume_db = _default_volume

func _on_start_resonance(area: Area2D, particle_mat: ShaderMaterial) -> void:
	if (area == self && resonance_effect):
		resonance_effect.start_resonance(particle_mat)
		
func _on_update_resonance(area: Area2D, particle_mat: ShaderMaterial, delta:float) -> void:
	if (area == self && resonance_effect):
		resonance_effect.update_resonance(particle_mat, delta)

func _on_stop_resonance(area: Area2D, particle_mat: ShaderMaterial) -> void:
	if (area == self && resonance_effect):
		resonance_effect.stop_resonance(particle_mat)
		
	
