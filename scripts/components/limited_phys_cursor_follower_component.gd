extends Node
class_name LimitedPhysCursorFollower

@export var speed:float = 200.0
@export var acceleration = 1200.0
@export var max_distance: float = 160.0        # pixels from player
@export var stop_distance = 3.0
@export var anticipate_center_factor := 1.0 
@export var target_smooth_speed := 10.0 

# idle oscillation params
@export var idle_enabled := true
@export var idle_amplitude := 12.0     # pixels
@export var idle_frequency := 2.5      # Hz (oscillations per second)
@export var idle_blend_speed := 6.0    # how fast oscillation fades in/out


var _limit_center: Node2D
var _last_center_position:= Vector2.INF
var _velocity: Vector2

var _last_local_mouse_pos := Vector2.INF
var _still_mouse_movement:float = 2.0

var last_distance: float = 0.0

const  EPSILON = 6 

var _sprite_direction:= Vector2.ZERO

func set_limit_center(limit_center: Node2D) -> void:
	_limit_center = limit_center	
	
func move(origin: Vector2, character: CharacterBody2D, deltaTime: float, sprite: AnimatedSprite2D) -> void:
	if !_limit_center: return
	var need_teleport =_calc_target_direction(origin, deltaTime)
	character.velocity = _velocity
	if need_teleport: character.global_position = _limit_center.global_position
	character.move_and_slide()	
	#sprite.rotation = _sprite_direction.angle()
	#sprite.flip_h = true if _velocity.x < 0.0 else false
		
func _calc_target_direction(origin: Vector2, delta: float) -> bool: 
	#first, coun how far cursor from a center so we can position in min-max limits
	var center_global: Vector2 = _limit_center.global_position
	var raw_target: Vector2 = _limit_center.get_global_mouse_position()	
	var raw_target_offset = raw_target - center_global
	var origin_offset = center_global - origin
	var target = raw_target	
	var raw_distance = raw_target_offset.length()
	_sprite_direction = raw_target_offset.normalized()
	
	if _last_center_position == Vector2.INF:
		_last_center_position = center_global
	var center_vel = (center_global - _last_center_position) / delta
	_last_center_position = center_global
	
	
	if (center_global - origin).length() > max_distance +100:
		_velocity = Vector2.ZERO
		return true
	
	if raw_distance > max_distance:
		target = center_global + raw_target_offset.normalized() * max_distance

	#var mouse_moved = true
#
	#if _last_mouse_pos != Vector2.INF:
		#mouse_moved = (_last_mouse_pos.distance_to(raw_target) > _still_mouse_movement)
	#_last_mouse_pos = raw_target 
	
	var local_mouse_move = true
	if _last_local_mouse_pos != Vector2.INF:
		local_mouse_move = _last_local_mouse_pos.distance_to(_limit_center.get_local_mouse_position()) > _still_mouse_movement
	_last_local_mouse_pos = _limit_center.get_local_mouse_position()
	
	var to_target = target - origin
	
	if(last_distance == 0.0):
		last_distance = to_target.length()
	
	var dist = to_target.length()
		
	if dist <= stop_distance:
		_velocity = Vector2.ZERO
		return false
	
	var target_velocity = to_target.normalized() * speed
	var velocity_delta = (_velocity - center_vel).length()
	var follow_center = false

	# desired velocity vector
	var desired_vel = Vector2.ZERO if (!local_mouse_move && (_velocity == Vector2.ZERO || abs(to_target.length() - last_distance) < 1)) || abs(to_target.length() - last_distance) < 0.1 else target_velocity
	if desired_vel == Vector2.ZERO: 
		follow_center = true

	desired_vel += center_vel * anticipate_center_factor
	last_distance = to_target.length()

	_velocity = lerp(_velocity, desired_vel, acceleration * delta)

	var is_idle = (not local_mouse_move) and dist <= stop_distance
	return false

	
