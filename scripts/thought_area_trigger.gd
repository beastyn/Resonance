extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		PlayerSignals.emit_signal("want_to_think", self)
	queue_free()
