extends Node

signal start_resonance(wave_area: Area2D, particle_mat: ShaderMaterial)
signal update_resonance(wave_area: Area2D, particle_mat: ShaderMaterial)
signal stop_resonance(wave_area: Area2D, particle_mat: ShaderMaterial)


signal start_fly_resonance(strength: float, direction: Vector2, ascenet_curve: Curve, descent_curve: Curve)
signal update_fly_resonance(direction: Vector2)
signal stop_fly_resonace()	

signal start_magnetic_resonance(strength: float, direction: Vector2, attraction_curve: Curve)
signal update_magnetic_resonance(direction: Vector2)
signal stop_magnetic_resonance()
