extends Node2D
class_name AudioComponent

@export var audio_player: AudioStreamPlayer2D

var _last_play_time:float = 0.0
var _default_pitch: float
var _defauly_valume: float

func _ready() -> void:
	_last_play_time = Time.get_ticks_msec()	
	_default_pitch = audio_player.pitch_scale
	_defauly_valume = audio_player.volume_db

func play_repeat_with_delay(sound_name: AudioManager.Sounds, delay: float) -> void:
	if (Time.get_ticks_msec() - _last_play_time) / 1000.0 < delay: return
	AudioManager.play(sound_name, audio_player)
	_last_play_time = Time.get_ticks_msec()
	
func play_once(sound_name: AudioManager.Sounds) -> void:
	AudioManager.play(sound_name, audio_player)

func stop() -> void:
	audio_player.pitch_scale = _default_pitch
	audio_player.volume_db = _defauly_valume
	AudioManager.stop(audio_player)
