extends Node
class_name LimitesCursorFollowerBehaviour

@export var max_distance: float = 160.0        # pixels from player
@export var min_distance: float = 0.0          # optional: don't go closer than this
@export var rotate_sprite: bool = true         # rotate the Sprite2D to face mouse
@export var follow_smoothness: float = 0.0     # 0 = instant, >0 smooth interpolation (seconds)

var _limit_center: Node2D

func set_limit_center(limit_center: Node2D) -> void:
	_limit_center = limit_center
	
func move_follower(follower: Node2D, deltaTime: float) -> void:
	if !_limit_center: return
	
	var target_position = _calc_target_position();	
	#reach our desination
	if follow_smoothness > 0.0:
		var t = clamp(deltaTime / follow_smoothness, 0.0, 1.0)
		follower.global_position = follower.global_position.lerp(target_position, t)
	else:
		follower.global_position = target_position
		
func _calc_target_position() -> Vector2: 
	#first, coun how far cursor from a center so we can position in min-max limits
	var center_global: Vector2 = _limit_center.global_position
	var mouse_global: Vector2 =  _limit_center.get_global_mouse_position()
	
	var center_to_cursor_distance = mouse_global - center_global #put us onthe the line between center and cursor
	var normal_center_to_cursor_distance =  center_to_cursor_distance.normalized() #this is just direction
	
	# decide on distanve where to put us
	var distance =  center_to_cursor_distance.length()
	distance = min_distance if center_to_cursor_distance .length() < min_distance else distance		 
	distance = max_distance if center_to_cursor_distance.length() > max_distance else distance	
		##TODO change rotation logic
	#if rotate_sprite and animated_sprite_2d:
		#animated_sprite_2d.rotation = normal_center_to_cursor_distance.angle()
	
	#and calculate where exactly on direction are we
	return normal_center_to_cursor_distance * distance + center_global
		
