extends Node2D
class_name WaveEffectParticles

@export var particles: GPUParticles2D
@export var area: Area2D
@export var collider: CollisionShape2D
@export var lighter: PointLight2D

var _mat: ShaderMaterial
var  _wave_name: String = "default"
var _elapsed := 0.0
var _lifetime := 1.0
var _pool_owner: Node = null

var _is_resonance_active: bool = false 
var _entered_area: Area2D = null

var _light_tween:Tween

func _ready():
	#ensure we have particles
	if not particles:
		push_error("WaveEffectParticles2D: missing Particles node")
		return
		
	## Ensure a process material exists and duplicate it so each instance can be unique
	_mat = particles.process_material as ShaderMaterial
	if _mat:
		_mat = _mat.duplicate() as ShaderMaterial
	else:
		_mat = ShaderMaterial.new()
	particles.process_material = _mat
	
	collider.disabled = true
	set_process(false)

func _physics_process(delta: float) -> void:
	if _is_resonance_active: ResonanceSignals.emit_signal("update_resonance", _entered_area, _mat, delta)
		

# Ensure a process material exists and duplicate it so each instance can be unique
func setup_from_wave(wave: WaveData, origin: Vector2, direction: Vector2 = Vector2.ZERO, needCollision: bool = false) -> void:
	var calc_direction = wave.direction if direction == Vector2.ZERO else direction
	_mat.set_shader_parameter("direction", calc_direction)	
	_mat.set_shader_parameter("amplitude", wave.amplitude)
	_mat.set_shader_parameter("frequency", wave.frequency)
	_mat.set_shader_parameter("travel_distance", wave.travel_distane)
	_mat.set_shader_parameter("speed", wave.speed)
	_mat.set_shader_parameter("scale_factor", wave.scale_factor)
	_wave_name = wave.name
	global_position = origin	
	particles.emitting = true
	start_lightup()
	if needCollision: _setup_collision_area(wave.travel_distane, particles.texture.get_size().x, global_position, calc_direction, needCollision)
	
	
func init_from_pool(wave_area: Node2D, wave_data:WaveData, pos: Vector2, direction: Vector2, needCollision: bool = false )-> void:
	_set_pool_owner(wave_area)
	setup_from_wave(wave_data, pos, direction, needCollision)
	set_process(true)

	
func update_visuals(pos: Vector2, direction: Vector2) -> void:
	if(!particles.emitting): return
	_mat.set_shader_parameter("direction", direction)
	area.rotation = direction.angle()
	
func hide_wave() -> void:
	stop_lightup()
	
func reset_effect() -> void:
	# stop emitting and hide; called by pool.release()
	if particles:
		particles.restart()
		particles.emitting = false
	visible = false
	
func check_wave_resonance_by_mat(other_wave_material: ShaderMaterial) -> bool:
	var amplitude_check = _mat.get_shader_parameter("amplitude") && other_wave_material.get_shader_parameter("amplitude")
	var frequency_check = _mat.get_shader_parameter("frequency") && other_wave_material.get_shader_parameter("frequency")
	return amplitude_check && frequency_check
	
func check_wave_resonance_by_data(other_wave_data: WaveData) -> bool:
	var amplitude_check = _mat.get_shader_parameter("amplitude") == other_wave_data.amplitude
	var frequency_check = _mat.get_shader_parameter("frequency") == other_wave_data.frequency
	return amplitude_check && frequency_check

func start_lightup() -> void:
	if _light_tween: _light_tween.kill()
	_light_tween = create_tween()
	_light_tween.tween_property(lighter, "energy", 1.0, 0.5)
	
func stop_lightup() -> void:
	if !_light_tween.is_valid(): _light_tween.kill()
	_light_tween = create_tween()	
	_light_tween.tween_property(lighter, "energy", 0.0, 0.5)
	_light_tween.finished.connect(_on_light_end_finished)
	_light_tween.kill()
	WavePool.release(self, _pool_owner)
	collider.disabled = true
	set_process(false)
	
func _on_light_end_finished() ->void:
	_light_tween.finished.disconnect(_on_light_end_finished)
	_light_tween.kill()

	
func _set_pool_owner(pool_owner: Node2D) -> void:
	_pool_owner = pool_owner

func _setup_collision_area(length: float, width: float, origin: Vector2, dir: Vector2, needCollision: bool) -> void:
	area.name = "WaveProbe"
	area.monitoring = true
	area.monitorable = true
	var shape = RectangleShape2D.new()
	shape.size = Vector2(length, width)   # length = along X, width = along Y
	collider.shape = shape
	
	# Place and rotate
	area.global_position = origin
	area.rotation = dir.angle()   # rotates the shape along the direction

	# Optional: offset shape to start at origin and extend forward
	collider.position.x = length / 2.0
	collider.disabled = !needCollision
	if(area.area_entered.is_connected(_on_area_enter)): return
	area.area_entered.connect(_on_area_enter)
	area.area_exited.connect(_on_area_exit)
	
func _on_area_enter(entered_area:Area2D) -> void:	
	if entered_area.is_in_group("wave_areas"):
		var is_resonance: bool = _wave_name == (entered_area as WaveArea).get_wave_data().name
		if !is_resonance: return		
		_entered_area = entered_area
		ResonanceSignals.emit_signal("start_resonance",entered_area, _mat)
		_is_resonance_active = true
		print("Resonance: ", _entered_area.name)

func _on_area_exit(exit_area: Area2D) -> void:
	if(exit_area.is_in_group("wave_areas")):
		var is_resonance: bool = _wave_name == (exit_area as WaveArea).get_wave_data().name
		if !is_resonance: return				
		ResonanceSignals.emit_signal("stop_resonance", exit_area, _mat)		
		_is_resonance_active = false
		_entered_area = null
		print("End Resonance: ", exit_area.name)
