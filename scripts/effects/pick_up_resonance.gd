extends ResonanceEffect

@export var start_force: float = 40.0
@export var force_change_step = 5.0
@export var pickup_rigidbody: RigidBody2D


@export var min_distance := 16.0
@export var max_distance := 600.0
# spring tuning
@export var spring_stiffness := 120.0   # higher = stronger pull (N per meter)
@export var spring_damping := 12.0      # >0 damping to avoid oscillation
@export var max_force := 4000.0         # clamp

var _target_distance := 160.0
var _current_force: float = 0.0
var _grabbed: RigidBody2D = null
var _origin = Vector2.INF
var _wave_direction: Vector2

func start_resonance(particle_mat: ShaderMaterial) -> void:
	_wave_direction = particle_mat.get_shader_parameter("direction")
	PlayerSignals.pickup_force_changed.connect(_on_pickup_force_change)
	PlayerSignals.mediator_position_update.connect(_on_mediator_position_update)
		
	ResonanceSignals.emit_signal("start_pickup_resonance")
	if _origin != Vector2.INF: _grab((pickup_rigidbody.global_position - _origin).length())
	
	_current_force = start_force

func update_resonance(particle_mat: ShaderMaterial, delta: float) -> void:
	_wave_direction =particle_mat.get_shader_parameter("direction")
	ResonanceSignals.emit_signal("update_pickup_resonance")
	_apply_force(delta)
	
func stop_resonance(particle_mat: ShaderMaterial) -> void:
	ResonanceSignals.emit_signal("stop_pickup_resonance")
	PlayerSignals.pickup_force_changed.disconnect(_on_pickup_force_change)
	PlayerSignals.mediator_position_update.disconnect(_on_mediator_position_update)
	release()	

func _on_pickup_force_change(change_direction: float, mediator_position: Vector2) -> void:
	_current_force += change_direction * force_change_step
	_adjust_distance(change_direction * force_change_step)
	_origin = mediator_position

func _on_mediator_position_update(position: Vector2) -> void:
	_origin = position

func _adjust_distance(delta: float):
	_target_distance = clamp(_target_distance + delta, min_distance, max_distance)

func _grab(start_distance: float = 160.0):
	_grabbed = pickup_rigidbody
	_target_distance = clamp(start_distance, min_distance, max_distance)	
	_grabbed.sleeping = false

func release():
	_grabbed = null
	_origin = Vector2.INF

func _apply_force(delta):
	if not _grabbed: _grab((pickup_rigidbody.global_position - _origin).length())
	if not _grabbed: return
	
	var target_pos =  _origin + _wave_direction * _target_distance
	# vector from body to target
	var to_target = target_pos - _grabbed.global_position
	var dist = to_target.length()
	if dist < 0.001:
		return

	var dir = to_target / dist
	# spring force (Hooke's law): F = -k * x  where x = distance from equilibrium
	# equilibrium here is target_pos (so extension = dist). We want pull toward target -> F = k * dist along dir
	var spring_force = spring_stiffness * dist
	# damping: approximate using relative velocity along direction
	var rel_vel = _grabbed.linear_velocity  # world velocity of the RigidBody2D
	var damping_force = spring_damping * rel_vel.dot(dir)

	var force = spring_force - damping_force
	force = clamp(force, -max_force, max_force)

	# apply force toward target (positive force pushes along dir)
	var applied = dir * force * _grabbed.mass  # multiply by mass if desired (or omit)
	_grabbed.apply_central_impulse(applied * delta)  # impulse = F * dt

	# optional: limit linear_velocity to avoid violent behavior
	var vmax = 1200.0
	if _grabbed.linear_velocity.length() > vmax:
		_grabbed.linear_velocity = _grabbed.linear_velocity.normalized() * vmax
