extends ResonanceEffect

@export var strength: float = 400.0
@export var ascent_curve: Curve = Curve.new()
@export var descent_curve: Curve = Curve.new()
@export var direction: Vector2 = Vector2.UP  # <── new!  normalized direction

func start_resonance(particle_mat: ShaderMaterial) -> void:
	var _direction = -particle_mat.get_shader_parameter("direction")
	ResonanceSignals.emit_signal("start_fly_resonance", strength, _direction, ascent_curve, descent_curve)

func update_resonance(particle_mat: ShaderMaterial, delta:float) -> void:
	var _direction =-particle_mat.get_shader_parameter("direction")
	ResonanceSignals.emit_signal("update_fly_resonance", _direction)
	
func stop_resonance(particle_mat: ShaderMaterial) -> void:
	ResonanceSignals.emit_signal("stop_fly_resonace")
	
