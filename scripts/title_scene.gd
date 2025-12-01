extends Control

@export var bg_player: AudioStreamPlayer2D
@export var button_player: AudioStreamPlayer2D

func _on_start_game_pressed() -> void:
	button_player.play()
	TransitionManager.transite_to("res://scenes/intro.tscn", 2.0)
	var tween = create_tween()    
	tween.tween_property(bg_player, "volume_db", -30.0, 1.0)	

func _on_quit_game_pressed() -> void:
	get_tree().quit()
	button_player.play()
