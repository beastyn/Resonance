extends Node2D
class_name Enemy

@export var tentacles: Array[Tentacle]
@export var target: Node2D
@export var timer:Timer

@export var attack_lag: float = 1.0
@export var attack_time: = 2.0
@export var retract_time = 1.0

var _fireing:Array[bool] = []
var _retracting:Array[bool] = []
var _target_pos: = Vector2.INF

var _check_tentacle:Tentacle

func _ready():
	visible = false
	set_process(false)
	_fireing.resize(tentacles.size())
	_retracting.resize(tentacles.size())
	for i in  range(tentacles.size()):		
		tentacles[i].attack_finished.connect(_on_attack_finished)
		tentacles[i].retract_finished.connect(_on_retract_finished)		
	
func _process(delta: float) -> void:
	for i in range(tentacles.size()):		
		if _fireing[i]:
			_target_pos = target.global_position if _target_pos == Vector2.INF else _target_pos
			tentacles[i].fire_at(_target_pos, delta)
	for i in range(tentacles.size()):
		if _retracting[i]:
			tentacles[i].retract(delta)

func set_target(new_target: Node2D) -> void:
	target = new_target


func appear_and_attack(spawn_pos: Node2D) -> void:
	if !target: return
	global_position = spawn_pos.global_position
	rotation = spawn_pos.rotation
	visible = true
	timer.start(attack_lag)

func _on_attack_finished(tentacle: Tentacle) -> void:
	for i in range(tentacles.size()):
		if tentacles[i] ==  tentacle:
			_fireing[i] = false
			_retracting[i] = true		
	
func _on_retract_finished(tentacle: Tentacle) -> void:
	visible = false
	for i in range(tentacles.size()):
		if tentacles[i] ==  tentacle:
			_fireing[i] = false
			_retracting[i] = false		
	_target_pos = Vector2.INF
	set_process(false)

func _on_timer_timeout() -> void:
	for i in range(tentacles.size()):
		tentacles[i].init_tentacle()
		_fireing[i] = true
		
	set_process(true)
	timer.stop()
