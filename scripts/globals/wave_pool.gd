extends Node2D

@export var wave_scene: PackedScene = preload("res://scenes/wave_effect.tscn")
@export var initial_size: int = 4

var _pool: Array[Node2D] = []

func _ready():
	for i in range(initial_size):
		_createPooledObject()

func obtain(parent: Node2D) -> Node2D:
	if _pool.is_empty():
		_createPooledObject()
	var wave = _pool.pop_back()
	wave.visible = true
	remove_child(wave)
	parent.add_child(wave)
	return wave

func release(wave: Node2D, parent: Node2D) -> void:
	# default cleanup
	wave.visible = false
	if wave.has_method("reset_effect"): wave.reset_effect()
	_pool.append(wave)
	parent.remove_child(wave)
	add_child(wave)
	
func _createPooledObject() -> void:
	var wave = wave_scene.instantiate() as Node2D
	wave.visible = false
	add_child.call_deferred(wave)
	if wave.has_method("set_pool_owner"): wave.set_pool_owner(self)
	_pool.append(wave)
