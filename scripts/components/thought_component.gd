extends Node
class_name ThoughtComponent

@export var thoughts: Dictionary[int, MultilineDescription]
@export var thought_ui: ThoughtsUI

var _had_thoughts: Array[int]

func _ready() -> void:
	PlayerSignals.want_to_think.connect(_on_want_to_think)
	PlayerSignals.mediator_is_listening.connect(_on_mediator_is_listening)
	WaveStorage.wave_learnt.connect(_on_wave_learnt)
	ResonanceSignals.start_resonance.connect(_on_start_resonance)
	
func  _on_want_to_think(thought_area: Area2D) -> void:
	if thought_area.is_in_group("thought1"): 
		_think_unrepeated(1)
		
func _on_mediator_is_listening() -> void:
	_think_unrepeated(2)	

func _on_wave_learnt(wave_name: String) -> void:
	_think_unrepeated(3)

func _on_start_resonance(area: Area2D, particle_mat: ShaderMaterial) -> void:
	_think_unrepeated(4)

func _think_unrepeated(thought_id:int) -> void:
	if _had_thoughts.has(thought_id): return
	thought_ui.open_panel(thoughts[thought_id].description)
	_had_thoughts.append(thought_id)
