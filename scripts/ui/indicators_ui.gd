extends Control
class_name IndicatorsUI

@export var waves_icons: WavesIcons
@export var active_wave:TextureRect
@export var destruction_timer_container: TextureRect
@export var timer_label: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerSignals.want_to_activate_wave.connect(_on_want_to_activate_wave)
	ResonanceSignals.start_destructuion_resonance.connect(_on_start_destruction_resonance)
	ResonanceSignals.update_destruction_resonance.connect(_on_update_destruction_resonance)
	ResonanceSignals.stop_destruction_resonance.connect(_on_stop_destruction_resonance)
func _on_want_to_activate_wave(wave_data: WaveData) -> void:
	if !wave_data:
		active_wave.visible = false 
		destruction_timer_container.visible = false
		return
	
	active_wave.visible = true
	active_wave.texture = waves_icons. waves_name_to_icon[wave_data.name]
	if wave_data.name == "destroy" || wave_data.name == "enemy":
		timer_label.text = "?"
		destruction_timer_container.visible = true		
	else:
		destruction_timer_container.visible = false
	
func _on_start_destruction_resonance(resonance_time: float) -> void:
	timer_label.text = str(int(resonance_time))
	
func _on_update_destruction_resonance(resonance_time:float) -> void:
	timer_label.text = str(int(resonance_time))
func _on_stop_destruction_resonance() -> void:
	timer_label.text = "?"
