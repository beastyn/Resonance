extends Node

@export var enemy: Enemy
@export var main_target: Node2D
@export var spawn_pos: Array[Node2D]
@export var timer: Timer
@export var spawn_delta: float = 2.0
@export var cutscene_spawn_pos: Node2D
@export var cutscene_target: Node2D


var _wait_spawn: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_custscene()
	
func _process(delta: float) -> void:
	if !enemy: return		
	if _wait_spawn && !enemy.visible:
		timer.start(spawn_delta)
		_wait_spawn = false

func _on_timer_timeout() -> void:	
	if !enemy:
		_wait_spawn = true
		timer.stop()
		return
		
	var random_index = randi_range(0, spawn_pos.size() - 1)
	enemy.appear_and_attack(spawn_pos[random_index])
	_wait_spawn = true
	timer.stop()

func start_custscene() -> void:
	enemy.set_target(cutscene_target)
	enemy.appear_and_attack(cutscene_spawn_pos)
	
