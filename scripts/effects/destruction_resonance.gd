extends ResonanceEffect

@export var resonance_time: float = 4.0
@export var parent_node: Node
@export var sprite: Sprite2D
@export var timer:Timer
@export var change_speed: float = 0.01
@export var update_delta:float = 0.1

var _mat: ShaderMaterial
var _original_speed: float
var _start_time: float = 0.0
var _current_elapsed: float = 0.0
var _is_running = false

func _ready() -> void:
	## Ensure a process material exists and duplicate it so each instance can be unique
	_mat = sprite.material as ShaderMaterial
	if _mat:
		_mat = _mat.duplicate() as ShaderMaterial
	sprite.material = _mat
	_original_speed= _mat.get_shader_parameter("pulse_speed")

func _process(delta: float) -> void:
	if !_is_running: return	
	var elapsed: float = resonance_time - timer.time_left
	if elapsed - _current_elapsed <= update_delta: return
	var new_speed: float = _mat.get_shader_parameter("pulse_speed")
	_mat.set_shader_parameter("pulse_speed", new_speed + change_speed/(resonance_time*60)) 	
	_current_elapsed = elapsed

func start_resonance(particle_mat: ShaderMaterial) -> void:
	ResonanceSignals.emit_signal("start_destructuion_resonance", resonance_time)
	timer.start(resonance_time)
	_is_running = true

func update_resonance(particle_mat: ShaderMaterial, delta: float) -> void:
	ResonanceSignals.emit_signal("update_destruction_resonance", resonance_time)	
	
func stop_resonance(particle_mat: ShaderMaterial) -> void:
	ResonanceSignals.emit_signal("stop_destruction_resonance")
	_stop_timer()

func _on_timer_timeout() -> void:
	_stop_timer()
	parent_node.queue_free()

func _stop_timer() -> void:
	timer.stop()
	_mat.set_shader_parameter("pulse_speed", _original_speed)
	_is_running = false
	_current_elapsed = 0.0
