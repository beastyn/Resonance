extends CharacterBody2D
class_name Resonator

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

@export var velocity_component: VelocityComponent
@export var mediator_controller_component: MediatorControllerComponent
@export var animation_component: AnimationComponent
@export var damaged_component: DamagedComponent
@export var respawn_component: RespawnComponent
@export var audio_component: AudioComponent

@export var min_impact_v: float = 80.0        # minimum Y speed to consider a landing (px/s)
@export var max_impact_v: float = 800.0       # clamp for scaling

@export var mediator_center: Node2D
@export var mediator: Mediator

var _direction:float = 0.0
var _can_move: bool = true

var _was_on_floor: bool = false
var _prev_velocity: Vector2

var _is_disabled = false
var _is_invulnerable = false

var _should_fly = false
var _fly_strength: float 
var _fly_direction: Vector2
var _fly_ascent_curve: Curve
var _fly_descent_curve: Curve

var _is_attracted: float = false
var _attraction_strength: float
var _attraction_curve: Curve
var _attraction_direction: Vector2

func need_disable_inputs(is_disabled: bool) -> void:
	velocity_component.stop(self)
	animation_component.set_movement_direction(0.0)
	_is_disabled = is_disabled

func _ready() -> void:
			
	need_disable_inputs(true)
	animation_component.play_intro()
	animation_component.intro_finished.connect(_on_intro_finished)
	
	
	PlayerSignals.get_instant_harm.connect(_on_get_instant_harm)
	PlayerSignals.want_stop_moving.connect(_on_want_to_stop_moving)
	PlayerSignals.need_respawn.connect(_on_need_respawn)	

	if mediator: mediator.listen_action_component.listening_wave.connect(_on_listening_wave)
	if mediator: mediator.listen_action_component.stop_listening_wave.connect(_on_stop_listening_wave)		
	ResonanceSignals.start_fly_resonance.connect(_on_start_fly_resonance)
	ResonanceSignals.update_fly_resonance.connect(_on_update_fly_resonance)
	ResonanceSignals.stop_fly_resonace.connect(_on_stop_fly_resonance)
	
	ResonanceSignals.start_magnetic_resonance.connect(_on_start_magenetic_resonance)
	ResonanceSignals.update_magnetic_resonance.connect(_on_update_magnetic_resonance)
	ResonanceSignals.stop_magnetic_resonance.connect(_on_stop_magnetic_resonance)
	
	ResonanceSignals.start_pickup_resonance.connect(_on_start_pickup_resonance)
	ResonanceSignals.update_pickup_resonance.connect(_on_update_pickup_resonance)
	ResonanceSignals.stop_pickup_resonance.connect(_on_stop_pickup_resonance)

func  _process(delta: float) -> void:	
	if Input.is_action_just_pressed("quit", true):
		get_tree().quit()
	
	if _is_disabled: return
	
	#region MEDIATOR CONTROLLER
	if Input.is_action_just_pressed("listen", true) && !mediator.is_mediator_singing():
		mediator_controller_component.ask_to_listen(mediator_center if mediator_center else self as Node2D)
	if !_can_move: return
	if Input.is_action_just_pressed("activate_wave_1"):
		mediator_controller_component.ask_to_activate_wave(WaveStorage.get_wave("floor"))
	if Input.is_action_just_pressed("activate_wave_2"):
		mediator_controller_component.ask_to_activate_wave(WaveStorage.get_wave("wall"))
	if Input.is_action_just_pressed("activate_wave_3"):
		mediator_controller_component.ask_to_activate_wave(WaveStorage.get_wave("pickup"))
	if Input.is_action_just_pressed("activate_wave_4"):
		mediator_controller_component.ask_to_activate_wave(WaveStorage.get_wave("destroy"))
	if Input.is_action_just_pressed("activate_wave_5"):
		mediator_controller_component.ask_to_activate_wave(WaveStorage.get_wave("enemy"))
	if Input.is_action_pressed("fire_wave", true):
		mediator_controller_component.ask_to_sing(get_global_mouse_position())
	if Input.is_action_just_released("fire_wave", true):
		mediator_controller_component.ask_to_stop_sing();
	#endregion

func _physics_process(delta: float) -> void:	
	#region MOVEMENT
	if _can_move && !_is_disabled: 
		_solve_inputs(delta)
		_solve_fly_resonance(delta)	
		_solve_magnetic_resonance(delta)		
		_solve_animations()
	
	velocity_component.move(self)
	#endregion	
	  # AFTER movement you must call detection (if you use move_and_collide or move_and_slide, do check after it)
	_detect_landing()
	_was_on_floor = is_on_floor()
	_prev_velocity = velocity

func _solve_inputs(delta: float) -> void:	
	if _is_attracted: return
	
	# Add the gravity.
	if not is_on_floor():
		velocity_component.apply_gravity(get_gravity(), delta)

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity_component.apply_jump_veloctiy()
		audio_component.play_once(AudioManager.Sounds.JUMP_UP)

	# Get the input direction and handle the movement/deceleration.
	_direction = Input.get_axis("move_left", "move_right")
	velocity_component.apply_in_horizontal_direction(_direction, delta)
	if _direction != 0.0 && is_on_floor():
		audio_component.play_repeat_with_delay(AudioManager.Sounds.STEP, 0.8)

func _on_get_instant_harm() -> void:	
	damaged_component.start_damaged_sequence()
	animation_component.play_pain()

func _on_want_to_stop_moving() -> void:
	_is_disabled = true
	velocity_component.stop(self)
	mediator_controller_component.ask_to_stop_sing()
	mediator_controller_component.ask_to_stop_listen()

func _on_need_respawn() -> void:
	respawn_component._die_and_respawn(self, global_position)
	_is_disabled = false

func _on_listening_wave(wave_area: WaveArea, wave_data: WaveData, position: Vector2) -> void:
	velocity_component.stop(self)
	_can_move = false
	
func _on_stop_listening_wave(wave_area: WaveArea) -> void:
	_can_move = true;

func _solve_fly_resonance(delta: float) -> void:
	if !_should_fly: return
	velocity_component.apply_fly(delta, _fly_strength, _fly_direction, _fly_ascent_curve, _fly_descent_curve)
	
func _on_start_fly_resonance(strength: float, fly_direction: Vector2, ascent_curve: Curve, descent_curve: Curve) -> void:
	_fly_strength = strength
	_fly_direction = fly_direction
	_fly_ascent_curve = ascent_curve
	_fly_descent_curve = descent_curve
	_should_fly = true;

func _on_update_fly_resonance(fly_direction: Vector2) -> void:
	_fly_direction = fly_direction

func _on_stop_fly_resonance() -> void:
	_should_fly = false
	velocity_component.stop_fly()

func _solve_magnetic_resonance(delta: float) -> void:
	if !_is_attracted: return	
	velocity_component.apply_attraction(delta, _attraction_strength, _attraction_direction, _attraction_curve)
	# Get the input direction and handle the movement/deceleration.
	var v_direction = Input.get_axis("move_up", "move_down")
	velocity_component.apply_in_vertical_direction(v_direction, delta)

func _on_start_magenetic_resonance(strength: float, direction: Vector2, attraction_curve:Curve) -> void:
	_attraction_strength = strength
	_attraction_direction = direction
	_attraction_curve = attraction_curve
	_is_attracted = true
	animation_component.play_fly()

func _on_update_magnetic_resonance(direction: Vector2) -> void:
	_attraction_direction = direction

func _on_stop_magnetic_resonance() -> void:
	_is_attracted = false
	velocity_component.stop_attraction()
	if !is_on_floor(): velocity_component.apply_jump_veloctiy()
	animation_component.stop_fly()
	
func _on_start_pickup_resonance() -> void:
	PlayerSignals.emit_signal("mediator_position_update", mediator.global_position)

func _on_update_pickup_resonance() -> void:
	var force_direction = Input.get_axis("wave_force_down", "wave_force_up")
	PlayerSignals.emit_signal("pickup_force_changed", force_direction, mediator.global_position)
	
func _on_stop_pickup_resonance() -> void:
	pass	
func _solve_animations() -> void:
	animation_component.update_air(is_on_floor(), velocity.y)
	animation_component.set_movement_direction(_direction)

func _on_intro_finished() -> void:
	need_disable_inputs(false)

func _detect_landing():
	var now_on_floor = is_on_floor()
	if !_was_on_floor and now_on_floor:
		var impact_speed = abs(_prev_velocity.y)
		if impact_speed >= min_impact_v:			
			var t = clamp((impact_speed - min_impact_v) / max(0.001, (max_impact_v - min_impact_v)), 0.0, 1.0)
			#var vol_db = lerp(land_volume_db_min, land_volume_db_max, t)
			#var surface_sound_id = AudioManager.Sounds.EXPLOSION # replace with sensible default
			# Example mapping: you define LAND_DEFAULT, LAND_WOOD, LAND_STONE in your AudioManager.Sounds enum
			#surface_sound_id = AudioManager.Sounds.STEP  # default fallback; change mapping below
			# raycast check: make sure raycast length covers a little below feet
			#if ground_ray and ground_ray.is_colliding():
				#var collider = ground_ray.get_collider()
				## decide sound by group / metadata / type
				#if collider and collider.is_in_group("ground_wood"):
					#surface_sound_id = AudioManager.Sounds.JUMP  # e.g. LAND_WOOD collection
				#elif collider and collider.is_in_group("ground_stone"):
					#surface_sound_id = AudioManager.Sounds.EXPLOSION  # LAND_STONE
				#else:
					#surface_sound_id = AudioManager.Sounds.STEP   # LAND_DEFAULT
			audio_component.play_once(AudioManager.Sounds.LANDING)
			animation_component.play_landing()
