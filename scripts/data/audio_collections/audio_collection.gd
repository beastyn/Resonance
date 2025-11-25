extends Resource
class_name AudioCollection

# an array of AudioStream resources (drag Audio files into the array in inspector)
@export var streams: Array[AudioStream] = []

# default volume offset for the whole collection (db)
@export var volume_db: float = 0.0

# random pitch multiplier range (e.g. 0.95..1.05) - set both equal to disable variation
@export var pitch_min: float = 1.0
@export var pitch_max: float = 1.0

# optional name for clarity (not required)
@export var display_name: String = ""
