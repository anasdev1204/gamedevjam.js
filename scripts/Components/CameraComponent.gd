class_name CameraComponent
extends Node

@export var target: Node3D
@export var pivot: Node3D
@export var camera: Camera3D
@export var camera_size: float
@export var camera_size_lerp_speed := 8.0

@export var bounds_area: Area3D

@export var follow_speed := 8.0
@export var use_smoothing := true

var target_camera_size: float
var min_bound := Vector3.ZERO
var max_bound := Vector3.ZERO

func _ready():
	camera.size = camera_size 

func update(delta: float) -> void:
	if target == null:
		return

	var desired := target.global_position
	desired.x = clamp(desired.x, min_bound.x, max_bound.x)
	desired.z = clamp(desired.z, min_bound.z, max_bound.z)

	var final_pos := Vector3(
		desired.x,
		pivot.global_position.y,
		desired.z
	)

	if use_smoothing:
		pivot.global_position = pivot.global_position.lerp(
			final_pos,
			follow_speed * delta
		)
	else:
		pivot.global_position = final_pos
	
	if target_camera_size and camera.size != target_camera_size:
		camera.size = lerp(camera.size, target_camera_size, camera_size_lerp_speed * delta)

func update_bounds() -> void:
	if bounds_area == null:
		return

	var shape_node: CollisionShape3D = bounds_area.get_node("CollisionShape3D")
	if shape_node == null:
		return

	var shape: BoxShape3D = shape_node.shape
	
	if shape is BoxShape3D:
		var extents: Vector3 = shape.size * 0.5
		var center := shape_node.global_position

		min_bound = center - extents
		max_bound = center + extents

func set_camera_size(new_size := camera_size):
	target_camera_size = new_size
