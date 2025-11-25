extends Area2D
class_name HarmArea

@export var instant_damage_component: InstantDamage

var _inflict_damage:bool = false

func _physics_process(delta: float) -> void:
	if !_inflict_damage: return
	instant_damage_component.get_instant_harm()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_inflict_damage = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_inflict_damage = false
