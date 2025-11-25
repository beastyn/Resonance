extends Node

enum Sounds {
	STEP,
	JUMP_UP,
	LANDING,
	LISTEN,
	SING,
	WAVE,
	UI_CLICK,
}
enum Notes{
	C4,
	D4,
	E4,
	F4
}

@export var collections: Dictionary[AudioManager.Sounds, AudioCollection] = {}

func _ready() -> void:
	pass

func get_collection(sounds_type: Sounds) -> AudioCollection:
	return collections.get(sounds_type)

# play random variant from collection (non-positional)
func play(sounds_type:Sounds, player: AudioStreamPlayer2D) -> void:
	if player.playing: player.stop()
	var collection: AudioCollection = get_collection(sounds_type)
	var random_index = randi() % collection.streams.size()
	var stream: AudioStream = collection.streams[random_index]
	if stream == null:
		return		
	player.stream = stream			
	player.play()

func stop(player: AudioStreamPlayer2D) -> void:
	player.stop()
