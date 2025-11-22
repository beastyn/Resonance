# SineGenerator.gd
extends Node

@export var mix_rate := 44100
@export var buffer_length := 0.1  # seconds
var gen: AudioStreamGenerator
var player: AudioStreamPlayer
var playback: AudioStreamGeneratorPlayback

# state for the tone
var frequency: float = 440.0
var amplitude: float = 0.5   # 0..1
var phase: float = 0.0

func _ready():
	gen = AudioStreamGenerator.new()
	gen.mix_rate = mix_rate
	gen.buffer_length = buffer_length
	player = AudioStreamPlayer.new()
	player.stream = gen
	add_child(player)
	player.play()
	playback = player.get_stream_playback()  # AudioStreamGeneratorPlayback

func _process(delta):
	# Call the function to fill the buffer
	fill_buffer()

func fill_buffer():
	# Calculate how much to increment the phase for each frame
	var increment = frequency / float(mix_rate)
	# Get the number of frames available to write to
	var frames_available = playback.get_frames_available()
	
	for i in range(frames_available):
		# Generate a sample using the sine wave formula
		# You can also use a combination of sin and cos
		var sample = sin(phase * TAU)
		# Push the frame to the audio output
		# Use Vector2.ONE for stereo or Vector1(sample) for mono
		playback.push_frame(Vector2.ONE * sample)
		
		# Update the phase for the next frame
		phase = fmod(phase + increment, 1.0)
