extends Node2D
class_name Tentacle

signal attack_finished(tentacle:Tentacle)
signal retract_finished(tentacle:Tentacle)

@export var tentacle: Line2D
@export var segments_number: int = 5
@export var limit_max_length: float = 200.0
@export var max_length:float = 200.0
@export var width: float = 30

@export var move_iterations: int = 3
@export var areas_parent: Node

@export var wave_amplitude:float = 5
@export var wave_frequency:float = 2
@export var wave_speed: float = 10

@export var fire_sec := 0.22
@export var retract_sec:= 0.20
@export var hold_sec := 0.12

var HarmAreaScene := preload("res://scenes/harm_area.tscn")

var _segments_pos:Array[Vector2] = []
var _segments_length:Array[float] = []
var _rest_offsets:Array[Vector2] = []
var _tentacle_pos: Vector2
var _wave_time:float = 0.0
var _attack_elapse_time:float = 0.0
var _start_points: Array[Vector2] 
var _retract_elapsed_time:float = 0.0
var _is_fireing: bool = false
var _is_retracting: bool = false
var _areas: Array[HarmArea] = []

func _ready() -> void:
	set_process(false)

func init_tentacle() ->void:
	if !tentacle: return
	_tentacle_pos = tentacle.global_position
	tentacle.width = width	
	_init_segments()
	set_process(true)

func _process(delta: float) -> void:
	_apply_wave_motion(delta)
	_update_areas_positions()

func fire_at(target_global: Vector2, delta:float, attack_duration: float = -1) -> void:
	attack_duration = fire_sec if attack_duration == -1 else attack_duration
	_is_fireing = true
	
	var start_tip = _segments_pos[segments_number - 1]
	if _attack_elapse_time < attack_duration:
		var t = _attack_elapse_time / attack_duration    
		var interp_target = start_tip.lerp(target_global, t)
		_solve_movement(interp_target)
		_attack_elapse_time += delta
	else:
		_solve_movement(target_global)
		_is_fireing = false
		emit_signal("attack_finished", self)
		_attack_elapse_time = 0.0

# Retract: smoothly return chain to rest pose (world positions computed from rest_offsets)
func retract(delta:float, retract_duration:float = -1) -> void:
	retract_duration = retract_sec if retract_duration == -1 else retract_duration
	_is_retracting = true
	
	_start_points = _segments_pos.duplicate()
	if _retract_elapsed_time < retract_duration:
		var t = _retract_elapsed_time / retract_duration
		for i in range(segments_number+1):
			_segments_pos[i] = _start_points[i].lerp(_rest_offsets[i], t)		
		_retract_elapsed_time += delta
		_update_visuals()
	else:
		_retract_elapsed_time = 0.0
		_is_retracting = false		
		emit_signal("retract_finished", self)
		_finish_attack()

func get_fire_state() -> bool:
	return _is_fireing
func  get_retract_state() -> bool:
	return _is_retracting


func _solve_movement(target_pos: Vector2) -> void:
	_segments_pos[-1] = target_pos
	
	var _total_length:float = 0.0
	var current_lengths :float = 0.0

	for i in range(_segments_length.size()):
		_total_length += _segments_length[i]
	current_lengths = _total_length
	
	var dist_root_target = _segments_pos[0].distance_to(target_pos)
	if dist_root_target > _total_length && _total_length < max_length:

		var dir = (target_pos - _segments_pos[0]).normalized()

		for i in range(1, segments_number):
			var desired_dist = dist_root_target - current_lengths
			_segments_pos[i] = _segments_pos[i] + dir * desired_dist
			_segments_length[i] = _segments_length[i] + desired_dist
		_update_visuals()
		return

	for _iter_num in range(move_iterations):		
		for i in range(segments_number - 1, -1, -1):
			var s: Vector2 = _segments_pos[i] - _segments_pos[i + 1]
			var direction: Vector2 = s.normalized()
			_segments_pos[i] = _segments_pos[i + 1] + direction * _segments_length[i]
			
		_segments_pos[0] = _tentacle_pos
		for i in range(segments_number):
			var s: Vector2 = _segments_pos[i + 1] - _segments_pos[i]
			var direction: Vector2 = s.normalized()
			_segments_pos[i + 1] = _segments_pos[i] + direction * _segments_length[i]
	_update_visuals()
	
func _init_segments() -> void:
	if !tentacle: return
	_segments_pos.append(_tentacle_pos)
	_rest_offsets.append(_tentacle_pos)
	for i in range(segments_number):
		var length: float = limit_max_length / segments_number
		_segments_length.append(length)
		_segments_pos.append(_tentacle_pos + Vector2(length * (i + 1), 0))
		_rest_offsets.append(_tentacle_pos + Vector2(length * (i + 1), 0))
		_create_area(_segments_length[i])		
	_update_visuals()

func _apply_wave_motion(delta: float) -> void:
	if wave_amplitude <= 0.0:
		return

	_wave_time += delta * wave_speed

	var total_length: float = 0.0
	for length in _segments_length:
		total_length += length

	var accumulated_length: float = 0.0
	for i in range(1, segments_number):
		accumulated_length += _segments_length[i - 1]

		# Normalized position (0-1) along the arm determines wave phase offset
		var t: float = accumulated_length / total_length

		var vec: Vector2 = _segments_pos[i] - _segments_pos[i - 1]
		var direction: Vector2 = vec.normalized()
		var perpendicular: Vector2 = direction.orthogonal()

		# Phase combines time (animation) with position (traveling wave) ᶘ ◕ᴥ◕ᶅ
		var wave_phase: float = _wave_time + t * wave_frequency * TAU
		var wave_offset: float = sin(wave_phase) * wave_amplitude
		_segments_pos[i] += perpendicular * wave_offset	

func _create_area(segment_length:float) -> void:
	var area = HarmAreaScene.instantiate()
	var cs = CollisionShape2D.new()
	var cap = RectangleShape2D.new()

	cs.shape = cap
	cap.size.y = width  # thickness in pixels
	cap.size.x = segment_length
	area.add_child(cs)
	areas_parent.add_child(area)
	_areas.append(area)

func _update_areas_positions():
	for i in range(_areas.size()):
		var p0 = _segments_pos[i]
		var p1 = _segments_pos[i + 1]
		var mid = (p0 + p1) * 0.5
		var seg_vec = p1 - p0
		var seg_len = seg_vec.length()
		var angle = seg_vec.angle()

		var a = _areas[i]
		# place area at midpoint (global)
		a.global_position = mid
		a.global_rotation = angle

		# adjust capsule shape so its total length equals segment length
		var cs = a.get_child(1) as CollisionShape2D
		if cs and cs.shape is RectangleShape2D:
			var cap = cs.shape as RectangleShape2D
			# keep radius (thickness) but ensure height >= 0
			cap.size.x = _segments_length[i]/2
			## optional: if seg_len < 2*radius shrink radius
			#if seg_len < 2.0 * cap.radius:
				#cap.radius = seg_len * 0.5
				#cap.height = 0.0

func _update_visuals() -> void:
	tentacle.clear_points()
	for pos in _segments_pos:
		tentacle.add_point(tentacle.to_local(pos))	

func _finish_attack() -> void:
	for child in areas_parent.get_children():
		areas_parent.remove_child(child)
	set_process(false)
	_segments_pos.clear()
	_segments_length.clear()
	_rest_offsets.clear()
	_areas.clear()
