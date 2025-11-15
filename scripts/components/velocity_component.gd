extends Node
class_name VelocityComponent

@export var speed: float = 200.0
@export var jump_strength:float = 380;
@export var decelerationSpeed: float = 10 
@export var acceleration_curve: Curve = Curve.new()
@export var deceleration_curve: Curve = Curve.new()
@export var fall_curve_default: Curve = Curve.new()

var _fall_time_default: float = 0.0
var _acceleration_time: float = 0.0

var _fall_time_flying: float = 0.0
var _is_flying = false;
var _ascent_fly_time: float = 0.0
var _fly_descent_curve: Curve = Curve.new()

var _attraction_time: float = 0.0
var _is_attracted: bool = false
var _attraction_curve: Curve = Curve.new()


var _velocity : Vector2 = Vector2.ZERO

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

func apply_gravity(gravity: Vector2, delta: float) -> void:
	_fall_time_default += delta
	_fall_time_flying += delta	
	if !_is_flying && !_is_attracted:
		_apply_gravity_deceleration(gravity, fall_curve_default, _fall_time_default, delta)
		if _velocity.y >=0: _fall_time_default = 0.0	
	else:
		_apply_gravity_deceleration(gravity, _fly_descent_curve, _fall_time_flying, delta)

func apply_jump_veloctiy() -> void:
	_velocity.y = -jump_strength 
		
func apply_in_direction(direction: float, delta: float) -> void:
	_acceleration_time += delta
	if direction: 
		_apply_horizontal_acceleration(direction, speed, acceleration_curve, _acceleration_time, delta)		
	elif _velocity.x != 0.0:
		_velocity.x = lerpf(_velocity.x, 0.0, decelerationSpeed * delta)
		print("DECCEL")
	
	if !direction: 
		_acceleration_time = 0.0
		
func apply_fly(delta: float, strength: float, direction: Vector2, ascent_curve: Curve, descent_curve: Curve) -> void:
	_ascent_fly_time += delta
	_apply_fly_acceleration_in_direction(direction, strength, ascent_curve, _ascent_fly_time, delta)
	_fly_descent_curve = descent_curve
	_is_flying = true
	_fall_time_flying = 0.0
	
func stop_fly() -> void:
	_is_flying = false
	_fall_time_flying = 0.0
	_ascent_fly_time = 0.0
	
func apply_attraction(delta: float, strength: float, direction: Vector2, attraction_curve: Curve) -> void:
	_attraction_time+= delta
	_apply_fly_acceleration_in_direction(-direction, strength, attraction_curve, _attraction_time, delta)
	_is_attracted = true
	
func stop_attraction() -> void:
	_is_attracted = false
	_attraction_time = 0.0	
	
func move(character: CharacterBody2D) -> void:
	character.velocity = _velocity
	character.move_and_slide()

func stop(character: CharacterBody2D) -> void:
	_velocity = Vector2.ZERO
	character.velocity = _velocity	
	
func _apply_gravity_deceleration(gravity: Vector2, fall_curve: Curve, fall_time: float, delta: float) ->void:
	_apply_parameter_deceleration(gravity, fall_curve, fall_time, delta)
	
func _apply_parameter_deceleration(parameter: Vector2, change_curve: Curve, decrease_time: float, delta:float) -> void:
	var multiplyer := change_curve.sample(clamp(decrease_time, 0.0, 1.0))
	_velocity += parameter * multiplyer * delta 

func _apply_horizontal_acceleration(direction: float, max_speed:float, increase_curve: Curve, increase_time: float, delta:float) -> void:
	var multiplyer := increase_curve.sample(clamp(increase_time, 0.0, 1.0))
	_velocity.x = direction * multiplyer * max_speed

func _apply_fly_acceleration_in_direction(direction: Vector2, max_speed:float, increase_curve: Curve, increase_time: float, delta:float) -> void:
	var multiplyer := increase_curve.sample(clamp(increase_time, 0.0, 1.0))
	_velocity = direction * multiplyer * max_speed

	
	
	


	
	
	
	
	
