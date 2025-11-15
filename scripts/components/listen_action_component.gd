extends Node
class_name ListenActionComponent

signal listening_wave(wave_area: WaveArea, wave_data: WaveData, position: Vector2)
signal stop_listening_wave(wave_area: WaveArea)

@export var mediator_listen_data: MediatorListenData 

var beam_width: float = 4.0
var beam_color: Color = Color(0.2,0.7,1.0,0.9)
var max_Listen_Distance: float = 50.0

var mediator: Node2D
var beam_line: Line2D

var _is_listening: bool = false;
var _listen_to_wave: Node2D

func _ready() -> void:
	mediator = get_parent()
	beam_line = Line2D.new()
	WavePool.add_child(beam_line)
	beam_line.width = mediator_listen_data.beam_width
	beam_line.default_color = mediator_listen_data.beam_color
	beam_line.z_index = 1000
	beam_line.visible = false	
	max_Listen_Distance = mediator_listen_data.max_listen_distance
		
	PlayerSignals.want_to_listen.connect(_on_want_to_listen)
	
func _on_want_to_listen(player_position: Vector2) -> void:
	_listen_at_point(player_position)
	
func _listen_at_point(player_origin: Vector2):
	if(_is_listening):
		emit_signal("stop_listening_wave", _listen_to_wave as WaveArea)
		_is_listening = false
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
		
		# compute ray end for a given max_range
func _get_ray_end(player_global: Vector2) -> Vector2:
	return max_Listen_Distance * _get_beam_dir(player_global) + _get_beam_origin() 

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
