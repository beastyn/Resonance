extends Node
class_name ListenActionComponent

signal listening_wave(wave_area: WaveArea, wave_data: WaveData, position: Vector2)
signal stop_listening_wave(wave_area: WaveArea)

@export var mediator_listen_data: MediatorListenData 

var beam_width: float = 4.0
var beam_color: Color = Color(0.2,0.7,1.0,0.9)
var max_listen_distance: float = 50.0

var mediator: CharacterBody2D
var beam_line: Line2D

var _is_listening: bool = false;
var _listen_to_wave: Node2D

var _listening_wave_position: Vector2
var _listen_velocity := Vector2.ZERO
var _listen_rotation := 0.0
var _previous_rotation: float = INF

func _ready() -> void:
	mediator = get_parent()
	beam_line = Line2D.new()
	WavePool.add_child(beam_line)
	beam_line.width = mediator_listen_data.beam_width
	beam_line.default_color = mediator_listen_data.beam_color
	beam_line.z_index = 1000
	beam_line.visible = false	
	max_listen_distance = mediator_listen_data.max_listen_distance
		
	PlayerSignals.want_to_listen.connect(_on_want_to_listen)
	PlayerSignals.want_to_stop_listen.connect(_on_want_to_stop_listen)

func apply_listening_position() -> void:	
	var wave = (_listen_to_wave as WaveArea).get_wave_data()
	var position = _listening_wave_position + wave.direction * (wave.travel_distane + mediator_listen_data.listen_position_delta)
	var direction = position - mediator.global_position	

	if direction.length() < 10.0:  # Small threshold to stop
		_listen_velocity = Vector2.ZERO
		return	
	_listen_velocity = direction.normalized() * mediator_listen_data.positionong_speed
	mediator.velocity = _listen_velocity
	mediator.move_and_slide()

func apply_listening_rotation(delta:float) -> void:
	if _previous_rotation == INF: _previous_rotation = mediator.rotation
	var wave = (_listen_to_wave as WaveArea).get_wave_data()
	var rotation = wave.direction.angle()	
	mediator.rotation = lerp_angle(mediator.rotation, rotation, delta * mediator_listen_data.positioning_rotation_speed)

func reset_position_and_rotatopn(delta:float) -> void:
	mediator.rotation = lerp_angle(mediator.rotation, _previous_rotation, delta * mediator_listen_data.positioning_rotation_speed)
	_previous_rotation = INF	
	
func _on_want_to_listen(player_position: Vector2) -> void:
	_listen_at_point(player_position)

func _on_want_to_stop_listen() -> void:
	if(_is_listening):
		_stop_listen()	
	
func _listen_at_point(player_origin: Vector2):
	if(_is_listening):
		_stop_listen()
		return
				
	# Do physics raycast that can hit Areas (set collide_with_areas = true)
	var origin = _get_beam_origin()
	var ray_end := _get_ray_end(player_origin)
	var space := mediator.get_world_2d().direct_space_state
	var properties = PhysicsRayQueryParameters2D.create(origin, ray_end,1 << 3 - 1, [self, ])
	properties.collide_with_areas = true
	var ray_res = space.intersect_ray(properties)
	if ray_res: 
		print(ray_res.collider)
	var hit_pos: Vector2 = ray_res.position if ray_res else ray_end
	var hit_collider = ray_res.collider if ray_res else null

	# visualize beam briefly from origin to hit_pos
	_show_beam(origin, hit_pos)

	# If the collider is an Area2D and is a wave area or has get_wave_data, trigger it:
	if hit_collider and hit_collider is Area2D and hit_collider.has_method("get_wave_data"):
		_is_listening = true;
		_request_wave_emit(hit_collider, hit_pos)		
		_listening_wave_position = hit_pos
		
		# compute ray end for a given max_range
func _get_ray_end(player_global: Vector2) -> Vector2:
	return _get_beam_origin() + (mediator.get_global_mouse_position() -_get_beam_origin()).normalized() * max_listen_distance

func _get_beam_origin() -> Vector2:
	return mediator.global_position
	
func _get_beam_dir(player_global: Vector2) -> Vector2:
	return (_get_beam_origin() - player_global).normalized()

func _show_beam(a: Vector2, b: Vector2):
	beam_line.clear_points()
	beam_line.add_point(a)
	beam_line.add_point(b)
	beam_line.visible = true
	
func _request_wave_emit(area: Area2D, pos: Vector2) -> void: 
	var wave_data: WaveData = null
	wave_data = area.get_wave_data()
	_listen_to_wave = area as Node2D
	emit_signal( "listening_wave", area as WaveArea, wave_data, pos)

func _stop_listen() -> void:
	emit_signal("stop_listening_wave", _listen_to_wave as WaveArea)
	_is_listening = false
	mediator.rotation = _previous_rotation
	_previous_rotation = INF
