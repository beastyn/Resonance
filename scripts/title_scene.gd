extends Control

func _on_start_game_pressed() -> void:
	TransitionManager.transite_to("res://scenes/game.tscn", 1.0)	

func _on_quit_game_pressed() -> void:
	get_tree().quit()
