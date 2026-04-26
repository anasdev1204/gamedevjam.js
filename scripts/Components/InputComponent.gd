class_name InputComponent extends Node

@export var body: Player
@export var switch_area: SwitchArea

signal primary_fired
signal active_dash_fired
signal switch_fired(Player)
signal move_dir_change(dir: Vector3)

var move_dir := Vector3.ZERO
var attack_dir := Vector3.ZERO
var movement_state := false
var disabled := true

func _unhandled_input(event):
	if disabled:
		return

	attack_dir = get_mouse_world_direction()

	if event.is_action_pressed("primary_attack"):
		if can_attack():
			primary_fired.emit()

	if event.is_action_pressed("active_dash"):
		if can_attack():
			active_dash_fired.emit()
			
	if event.is_action_pressed("switch"):
		if can_switch():
			var switch_to: Player = switch_area.get_closest_exploding_in_range(attack_dir)
			switch_fired.emit(switch_to)
	
	move_dir.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	move_dir.z = Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	
	if movement_state != is_movement_ongoing():
		movement_state = is_movement_ongoing()
		move_dir_change.emit(move_dir)
	
func can_attack():
	var value = true
	
	return value
	
func can_switch():
	return switch_area.is_exploding_in_range()

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
	
