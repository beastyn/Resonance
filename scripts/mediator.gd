extends CharacterBody2D
class_name Mediator

#@export var limited_follower_component: LimitesCursorFollowerBehaviour
@export var limited_phys_follower_component: LimitedPhysCursorFollower
@export var listen_action_component: ListenActionComponent
@export var replicate_wave_component: ReplicateWaveComponent
@export var audio_component: AudioComponent
@export var sprite: AnimatedSprite2D

@export var limit_center: Node2D

var _can_move: bool = true

func _ready() -> void:
	#limited_follower_component.set_limit_center(limit_center)
	global_position = limit_center.global_position
	limited_phys_follower_component.set_limit_center(limit_center)
	listen_action_component.listening_wave.connect(_on_listening_wave)
	listen_action_component.stop_listening_wave.connect(_on_stop_listening_wave)
	replicate_wave_component.need_replica_wave.connect(_on_need_replica_wave)
	replicate_wave_component.remove_replica_wave.connect(_on_remove_replica_wave)
	replicate_wave_component.save_replica_wave.connect(_on_save_replica_wave)

func _process(delta: float) -> void:
	#if can_move: limited_follower_component.move_follower(self, delta)
	if _can_move: return
	if Input.is_action_just_released("increase_wave_amplitude") ||  Input.is_action_just_released("decrease_wave_amplitude"):
		var amplitude_direction := 1.0 if Input.is_action_just_released("increase_wave_amplitude") else  -1.0 if Input.is_action_just_released("decrease_wave_amplitude") else 0.0
		replicate_wave_component.adjust_replica_amplitude(amplitude_direction)
	if Input.is_action_just_released("increase_wave_frequency") ||  Input.is_action_just_released("decrease_wave_frequency"):	
		var frequncy_direction := 1.0 if Input.is_action_just_released("increase_wave_frequency") else -1.0 if Input.is_action_just_released("decrease_wave_frequency") else 0.0
		replicate_wave_component.adjust_replica_frequency(frequncy_direction)			

func  _physics_process(delta: float) -> void:
	if _can_move: 			
		limited_phys_follower_component.move(self.global_position, self, delta, sprite)
		_rotate_sprite()
	if !_can_move:
		listen_action_component.apply_listening_position()
		listen_action_component.apply_listening_rotation(delta)
		sprite.rotation = 0.0		
	
func _on_listening_wave(wave_area : WaveArea, wave_data: WaveData, pos: Vector2) -> void:	
	wave_area.emit_wave_at_point(pos, false, (global_position-pos).normalized())
	replicate_wave_component.set_target_wave_data(wave_data, (global_position-pos).normalized())
	_can_move = false
	
func _on_stop_listening_wave(wave_area: WaveArea) -> void:
	wave_area.stop_emitting_wave()	
	replicate_wave_component.stop_replica_wave()
	_can_move = true
	
func _on_need_replica_wave(wave_area: WaveArea, wave_data: WaveData, pos: Vector2, direction: Vector2) -> void:	
	wave_area.emit_wave_at_point(wave_area.global_position, false, direction)
	
func _on_remove_replica_wave(wave_area: WaveArea) -> void:
	wave_area.stop_emitting_wave()
	
func _on_save_replica_wave(wave_data: WaveData, default_travel_distance: float) -> void:
	wave_data.travel_distane = default_travel_distance
	WaveStorage.save_wave(wave_data.name, wave_data)

func _rotate_sprite()-> void:
	var mouse_pos = get_global_mouse_position()
	var dir = mouse_pos - global_position
	if dir.length_squared() < 0.0001:
		return

	var angle = dir.angle()
	 # if pointing left (> 90° or < -90°)
	if abs(rad_to_deg(angle)) > 90:
		sprite.flip_h = true
		sprite.rotation = angle + PI  # mirror rotation
	else:
		sprite.flip_h = false
		sprite.rotation = angle
