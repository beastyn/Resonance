extends HBoxContainer
class_name LearnesWavesUI

@export var waves_icons: WavesIcons
@export var images_dicrionary: Dictionary [String, TextureRect] = {}

var active_wave_texture: CanvasItem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WaveStorage.wave_learnt.connect(_on_wave_learnt)
	PlayerSignals.want_to_activate_wave.connect(_on_want_to_activate_wave)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_wave_learnt(wave_name: String) -> void:
	if images_dicrionary.has(wave_name):
		images_dicrionary[wave_name].texture = waves_icons.waves_name_to_icon[wave_name]

func _on_want_to_activate_wave(wave_data: WaveData) -> void:
	if !wave_data: 
		if active_wave_texture: active_wave_texture.visible = false
		return
	elif !images_dicrionary.has(wave_data.name): return	
	
	if active_wave_texture: active_wave_texture.visible = false	
	active_wave_texture = images_dicrionary[wave_data.name].get_child(0) as CanvasItem
	active_wave_texture.visible = true
	
