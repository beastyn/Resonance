extends Node

# dictionary to store clones keyed by name
var presets: Dictionary = {}

# Save a wave clone with a custom name
func save_wave(name: String, wave: WaveData) -> void:
	if not wave:
		push_error("Cannot save null wave!")
		return    
	# duplicate the wave so we don't modify original
	var clone := wave.duplicate(true)
	# optionally override color
	#if color_override:
		#clone.color = color_override
	presets[name] = clone
	print("Wave saved:", name)

# Retrieve a stored wave (returns clone to avoid external modifications)
func get_wave(name: String) -> WaveData:
	if not presets.has(name):
		return null
	return presets[name].duplicate(true)

# Check if a wave exists
func has_wave(name: String) -> bool:
	return presets.has(name)

# Remove a single wave from storage
func remove_wave(name: String) -> void:
	if presets.has(name):
		presets.erase(name)
		print("Removed wave:", name)

# Clear all stored waves
func clear_all() -> void:
	presets.clear()
	print("Cleared all waves")

# Return all stored wave names
func list_waves() -> Array:
	return presets.keys()
