class_name InputComponent extends Node

@export var body: Player

signal primary_fired
signal active_dash_fired
signal move_dir_change(dir: Vector3)

var move_dir := Vector3.ZERO
var movement_state := false
var disabled := true

func _unhandled_input(event):
	if disabled:
		return

	var mouse_dir = get_mouse_world_direction()

	if event.is_action_pressed("primary_attack"):
		if can_attack():
			primary_fired.emit()

	if event.is_action_pressed("active_dash"):
		if can_attack():
			active_dash_fired.emit()
	
	var input_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var input_z = Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")

	var right = mouse_dir.cross(Vector3.UP).normalized()
	var forward = mouse_dir.normalized()

	move_dir = (right * input_x) + (forward * input_z)

	if move_dir.length_squared() > 0.001:
		move_dir = move_dir.normalized()

	if movement_state != is_movement_ongoing():
		movement_state = is_movement_ongoing()
		move_dir_change.emit(move_dir)
	
func can_attack():
	var value = true
	
	# Add conditions for verifying if attack is possible
	
	return value

func get_mouse_world_direction() -> Vector3:
	var cam = get_viewport().get_camera_3d()

	var mouse_pos = get_viewport().get_mouse_position()
	var origin = cam.project_ray_origin(mouse_pos)
	var normal = cam.project_ray_normal(mouse_pos)

	var plane = Plane(Vector3.UP, body.global_position.y)
	var hit = plane.intersects_ray(origin, normal)

	if hit == null:
		return Vector3.ZERO

	var dir = (hit - body.global_position).normalized()
	dir.y = 0.0
	return dir

func is_movement_ongoing() -> bool:
	return abs(move_dir.x) > 0 or abs(move_dir.z) > 0
	
