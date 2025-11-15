extends Node
class_name AnimationComponent

@export var animation_tree: AnimationTree

var _last_facing = 1.0

func _ready() -> void:
	animation_tree.active = true
	
func set_movement_direction(direction: float) -> void:
	var blend_position = -2.0 if direction == -1.0 else (-1.0 if _last_facing == -1.0 else (2.0 if direction == 1.0 else 1.0))
	_last_facing = -1.0 if direction == -1.0 else 1.0 if direction == 1.0 else _last_facing
	animation_tree.set("parameters/walk/blend_position", blend_position)
