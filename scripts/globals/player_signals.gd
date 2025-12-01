extends Node

signal want_to_listen(player_position: Vector2)
signal want_to_stop_listen()
signal mediator_is_listening()
signal mediator_stopped_listening()
signal want_to_activate_wave(wave_data: WaveData)
signal want_to_sing(moouse_position: Vector2)
signal want_to_stop_sing()
signal sing_wave(name: String)
signal get_instant_harm()
signal want_stop_moving()
signal need_respawn()
signal pickup_force_changed(chsnge_direction: float, mediator_posirion: Vector2)
signal mediator_position_update(global_position: Vector2)

signal want_to_think(thought_trigger: Area2D)	
