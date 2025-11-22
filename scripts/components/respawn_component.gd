extends Node
class_name RespawnComponent

@export var invul_duration: float = 1.2
@export var respawn_sample_radius: float = 128.0
@export var respawn_sample_attempts: int = 20
@export var death_fade_time: float = 0.25
@export var respawn_points_group: String = "respawn_point"

func _die_and_respawn(character: CharacterBody2D, harm_position: Vector2) -> void:  
	var respawn_pos = _find_nearest_respawn_point(harm_position)	   
	if respawn_pos == null:
		var first = _get_any_respawn_point()
		respawn_pos = first if first != Vector2.INF else Vector2.ZERO

	character.global_position = respawn_pos
	character.velocity = Vector2.ZERO


func _get_any_respawn_point() -> Vector2:
	var nodes = get_tree().get_nodes_in_group(respawn_points_group)
	if nodes.size() > 0:
		return nodes[0].global_position
	return Vector2.INF

func _find_nearest_respawn_point(center: Vector2, max_distance := 99999.0) -> Vector2:
	var best_pos: Vector2 = Vector2.INF
	var best_dist = max_distance
	for p in get_tree().get_nodes_in_group(respawn_points_group):
		var d = center.distance_to(p.global_position)
		if d < best_dist:
			best_dist = d
			best_pos = p.global_position
	return best_pos
