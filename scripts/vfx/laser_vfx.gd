extends Node3D

var dir: Vector3
var spawnPos: Vector3

@export var length_curve: Curve
@export var max_length: float = 2.
@export var duration: float = 0.8

@onready var beam: MeshInstance3D = $beam
@onready var inner_beam: MeshInstance3D = $inner_beam
@onready var head: CPUParticles3D = $head
@onready var particles: CPUParticles3D = $particles

var time := 0.0

func _ready():
	global_position = spawnPos
	dir = dir.normalized()

	look_at(global_position + dir, Vector3.UP)
	
	particles.emitting = true

func _process(delta):
	time += delta

	var t: float = clamp(time / duration, 0.0, 1.0)

	# curve controls beam growth
	var curve_value := length_curve.sample(t)
	var length := curve_value * max_length

	_apply_inner_beam(length)
	_apply_beam(length)

	if t >= 1.0:
		queue_free()
		
func _apply_beam(length: float) -> void:
	beam.position = Vector3(0, 0, length * 0.05)
	beam.scale = Vector3(0.8, 0.8, length)	
	
func _apply_inner_beam(length: float) -> void:
	inner_beam.position = Vector3(0, 0, length * 0.05)
	inner_beam.scale = Vector3(0.4, 0.4, length)
