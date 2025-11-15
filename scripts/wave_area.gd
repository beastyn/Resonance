extends Area2D
class_name WaveArea

# You can either assign a WaveData resource in the editor, or override fields.
@export var default_wave_resource: Resource
@export var default_travel_distance: float = 200.0
@export var resonance_effect: ResonanceEffect


var activated_wave: WaveData = null

var active_wave_effect: WaveEffectParticles = null

func  _ready() -> void:
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

func set_wave_data(wave_data: WaveData) -> void:
	activated_wave = wave_data;	
	
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
	active_wave_effect.init_from_pool(self as Node2D, wave_data, pos, direction, needCollision)	

func update_active_wave(pos: Vector2, direction: Vector2) -> void:
	active_wave_effect.update_visuals(pos, direction)

func stop_emitting_wave() -> void:
	active_wave_effect.hide_wave()
	active_wave_effect = null

func _on_start_resonance(area: Area2D, particle_mat: ShaderMaterial) -> void:
	if (area == self && resonance_effect):
		resonance_effect.start_resonance(particle_mat)
		
func _on_update_resonance(area: Area2D, particle_mat: ShaderMaterial) -> void:
	if (area == self && resonance_effect):
		resonance_effect.update_resonance(particle_mat)

func _on_stop_resonance(area: Area2D, particle_mat: ShaderMaterial) -> void:
	if (area == self && resonance_effect):
		resonance_effect.stop_resonance(particle_mat)
		
	
