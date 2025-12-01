extends ResonanceEffect

@export var resonance_time: float = 4.0
@export var parent_node: Node2D
@export var animated_sprite: AnimatedSprite2D
@export var static_sprite: Sprite2D
@export var timer:Timer
@export var change_speed: float = 0.01
@export var update_delta:float = 0.1
@export var destroy_particles: CPUParticles2D

var _mat: ShaderMaterial
var _original_speed: float
var _start_time: float = 0.0
var _current_elapsed: float = 0.0
var _is_running = false
var _sprite

func _ready() -> void:
	_sprite = animated_sprite if animated_sprite else static_sprite
	if !_sprite: return
	## Ensure a process material exists and duplicate it so each instance can be unique
	_mat = _sprite.material as ShaderMaterial
	if _mat:
		_mat = _mat.duplicate() as ShaderMaterial
	_sprite.material = _mat
	_original_speed= _mat.get_shader_parameter("pulse_speed")

func _process(delta: float) -> void:
	if !_is_running: return	
	var elapsed: float = resonance_time - timer.time_left
	if elapsed - _current_elapsed <= update_delta: return
	var new_speed: float = _mat.get_shader_parameter("pulse_speed")
	_mat.set_shader_parameter("pulse_speed", new_speed + change_speed/(resonance_time*60)) 	
	_current_elapsed = elapsed

func start_resonance(particle_mat: ShaderMaterial) -> void:
	destroy_particles.color = particle_mat.get_shader_parameter("color")
	ResonanceSignals.emit_signal("start_destructuion_resonance", resonance_time)
	timer.start(resonance_time)
	_is_running = true

func update_resonance(particle_mat: ShaderMaterial, delta: float) -> void:
	ResonanceSignals.emit_signal("update_destruction_resonance", resonance_time - _current_elapsed)	
	
func stop_resonance(particle_mat: ShaderMaterial) -> void:
	ResonanceSignals.emit_signal("stop_destruction_resonance")
	_stop_timer()

func _on_timer_timeout() -> void:
	_stop_timer()
	destroy_particles.emitting = true
	destroy_particles.finished.connect(_on_destroy_particles_finished)
	_sprite.visible = false

func _on_destroy_particles_finished() -> void:
	parent_node.queue_free()
	ResonanceSignals.emit_signal("destroyed_by_resonance", get_groups())

func _stop_timer() -> void:
	timer.stop()
	_mat.set_shader_parameter("pulse_speed", _original_speed)
	_is_running = false
	_current_elapsed = 0.0
