extends ResonanceEffect

@export var strength: float = 400.0
@export var attraction_curve: Curve = Curve.new()

func start_resonance(particle_mat: ShaderMaterial) -> void:
	var _direction = -particle_mat.get_shader_parameter("direction")
	ResonanceSignals.emit_signal("start_magnetic_resonance", strength, _direction, attraction_curve)

func update_resonance(particle_mat: ShaderMaterial, delta: float) -> void:
	var _direction =-particle_mat.get_shader_parameter("direction")
	ResonanceSignals.emit_signal("update_magnetic_resonance", _direction)
	
func stop_resonance(particle_mat: ShaderMaterial) -> void:
	ResonanceSignals.emit_signal("stop_magnetic_resonance")
