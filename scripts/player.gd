extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

@export var velocity_component: VelocityComponent
@export var mediator_controller_component: MediatorControllerComponent
@export var animation_component: AnimationComponent
@export var respawn_component: RespawnComponent

@export var grab_raycast: RayCast2D
@export var grab_check_raycast: RayCast2D

@export var mediator_center: Node2D
@export var mediator: Mediator

var _direction:float = 0.0
var _can_move: bool = true
var _is_harmed = false

var _should_fly = false
var _fly_strength: float 
var _fly_direction: Vector2
var _fly_ascent_curve: Curve
var _fly_descent_curve: Curve

var _is_attracted: float = false
var _attraction_strength: float
var _attraction_curve: Curve
var _attraction_direction: Vector2


func _ready() -> void:
	PlayerSignals.get_instant_harm.connect(_on_get_instant_harm)
	PlayerSignals.need_respawn.connect(_on_need_respawn)
	
	if mediator: mediator.listen_action_component.listening_wave.connect(_on_listening_wave)
	if mediator: mediator.listen_action_component.stop_listening_wave.connect(_on_stop_listening_wave)		
	ResonanceSignals.start_fly_resonance.connect(_on_start_fly_resonance)
	ResonanceSignals.update_fly_resonance.connect(_on_update_fly_resonance)
	ResonanceSignals.stop_fly_resonace.connect(_on_stop_fly_resonance)
	
	ResonanceSignals.start_magnetic_resonance.connect(_on_start_magenetic_resonance)
	ResonanceSignals.update_magnetic_resonance.connect(_on_update_magnetic_resonance)
	ResonanceSignals.stop_magnetic_resonance.connect(_on_stop_magnetic_resonance)

func  _process(delta: float) -> void:	
	if _is_harmed: return
	
	#region MEDIATOR CONTROLLER
	if Input.is_action_just_pressed("listen", true):
		mediator_controller_component.ask_to_listen(mediator_center if mediator_center else self as Node2D)
	if !_can_move: return
	if Input.is_action_just_pressed("activate_wave_1"):
		mediator_controller_component.ask_to_activate_wave(WaveStorage.get_wave("floor"))
	if Input.is_action_just_pressed("activate_wave_2"):
		mediator_controller_component.ask_to_activate_wave(WaveStorage.get_wave("wall"))
	if Input.is_action_just_pressed("activate_wave_3"):
		mediator_controller_component.ask_to_activate_wave(WaveStorage.get_wave("enemy"))
	if Input.is_action_pressed("fire_wave", true):
		mediator_controller_component.ask_to_sing(get_global_mouse_position(), WaveStorage.get_wave("floor"))
	if Input.is_action_just_released("fire_wave", true):
		mediator_controller_component.ask_to_stop_sing();
	#endregion

func _physics_process(delta: float) -> void:	
	#region MOVEMENT
	if _can_move && !_is_harmed: 
		_solve_inputs(delta)
		_solve_fly_resonance(delta)	
		_solve_magnetic_resonance(delta)		
		_solve_animations()
	
	velocity_component.move(self)
	#endregion	

func _solve_inputs(delta: float) -> void:	
	if _is_attracted: return
	
	# Add the gravity.
	if not is_on_floor():
		velocity_component.apply_gravity(get_gravity(), delta)

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity_component.apply_jump_veloctiy()

	# Get the input direction and handle the movement/deceleration.
	_direction = Input.get_axis("move_left", "move_right")
	velocity_component.apply_in_horizontal_direction(_direction, delta)

func _on_get_instant_harm() -> void:
	_is_harmed = true
	velocity_component.stop(self)
	mediator_controller_component.ask_to_stop_sing()
	mediator_controller_component.ask_to_stop_listen()

func _on_need_respawn() -> void:
	respawn_component._die_and_respawn(self, global_position)
	_is_harmed = false

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

func _on_update_magnetic_resonance(direction: Vector2) -> void:
	_attraction_direction = direction

func _on_stop_magnetic_resonance() -> void:
	_is_attracted = false
	velocity_component.stop_attraction()
	if !is_on_floor(): velocity_component.apply_jump_veloctiy()
	
func _solve_animations() -> void:
	animation_component.update_air(is_on_floor(), velocity.y)
	animation_component.set_movement_direction(_direction)
	
