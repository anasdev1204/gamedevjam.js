extends Node3D

@export var speed := 20.0
var dir: Vector3
var spawnPos: Vector3

func _ready():
	global_position = spawnPos
	look_at(global_position + dir, Vector3.DOWN)

func _physics_process(delta: float) -> void:
	global_position += -global_transform.basis.x * speed * delta
