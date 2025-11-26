extends Node
class_name AnimationComponent

signal intro_finished()

@export var animation_tree: AnimationTree
@export var sprite: AnimatedSprite2D

var animation_state: AnimationNodeStateMachinePlayback

enum State {Walk, Jump, Fall}

var current_State: State = State.Walk

func _ready() -> void:
	animation_tree.active = true
	animation_state = animation_tree.get("parameters/playback")
	animation_tree.set("parameters/state_machine/jumping", false)
	
func set_movement_direction(direction: float) -> void:
	var blend_position = 2.0 if direction !=0 else 1.0
	#_last_facing = -1.0 if direction == -1.0 else 1.0 if direction == 1.0 else _last_facing
	animation_tree.set("parameters/walk/blend_position", blend_position)
	
	if direction > 0:
		sprite.flip_h = false
	if direction <0:
		sprite.flip_h = true

func update_air(on_ground: bool, up_direction : float) -> void:
	if on_ground && current_State != State.Walk:
		animation_state.travel("walk")
		current_State = State.Walk
	if !on_ground && up_direction <= 0 && current_State != State.Jump:
		animation_state.travel("to_air")
		current_State = State.Jump
	if !on_ground && up_direction > 0  && current_State != State.Fall:
			animation_state.travel("fall")
			current_State = State.Fall

func play_intro() -> void:
	animation_state.travel("wakeup")

func notify_intro_finished() -> void:
	emit_signal("intro_finished")

	
