# res://WaveData.gd
extends Resource
class_name WaveData

@export var name: String = "Default"
@export var direction: Vector2 = Vector2(0,1)
@export var scale_factor = 1.0;
@export var amplitude: float = 0.6    # visual intensity / ring thickness
@export var frequency: float = 1.0    # rings per unit (higher -> more rings visible)\
@export var travel_distane: float = 100.0
@export var speed: float = 50.0        # how fast rings expand (units/sec)
@export var amount: int = 10
@export var lifetime: float = 5.0     # how long effect lives
@export var color: Color = Color.GREEN
