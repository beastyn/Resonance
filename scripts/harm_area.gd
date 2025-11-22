extends Area2D
class_name HarmArea

@export var instant_damage_component: InstantDamage

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		instant_damage_component.start_instant_damage_sequnce()
