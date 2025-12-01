extends Control
class_name Hud

enum InstructionsNames{
	DEFAULT,
	LISTEN,
	SING_DEFUALT,
	FLOOR,
	WALL,
	PICKUP,
	DESTROY,
	ENEMY	
}
@export var instructions : Dictionary[InstructionsNames, RichTextLabel]

var _last_instruction: RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instructions[InstructionsNames.DEFAULT].visible = true
	_last_instruction = instructions[InstructionsNames.DEFAULT]
	
	PlayerSignals.mediator_is_listening.connect(_on_mediator_is_listening)
	PlayerSignals.mediator_stopped_listening.connect(_on_mediator_stopped_listening)
	PlayerSignals.sing_wave.connect(_on_sing_wave)
	PlayerSignals.want_to_stop_sing.connect(_on_want_to_stop_sing)

func _on_mediator_is_listening() -> void:
	_change_instruction_to(instructions[InstructionsNames.LISTEN])

func _on_mediator_stopped_listening() -> void:
	_change_instruction_to(instructions[InstructionsNames.DEFAULT])

func _on_sing_wave(wave_name: String) -> void:
	match wave_name:
		"default": _change_instruction_to(instructions[InstructionsNames.SING_DEFUALT])
		"floor": _change_instruction_to(instructions[InstructionsNames.FLOOR])
		"wall": _change_instruction_to(instructions[InstructionsNames.WALL])
		"pickup": _change_instruction_to(instructions[InstructionsNames.PICKUP])
		"destroy": _change_instruction_to(instructions[InstructionsNames.DESTROY])
		"enemy": _change_instruction_to(instructions[InstructionsNames.ENEMY])

func _on_want_to_stop_sing() -> void:
	_change_instruction_to(instructions[InstructionsNames.DEFAULT])

func _change_instruction_to(new_instruction: RichTextLabel) -> void:
	_last_instruction.visible = false
	new_instruction.visible = true
	_last_instruction = new_instruction
