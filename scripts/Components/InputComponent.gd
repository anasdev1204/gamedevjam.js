class_name InputComponent extends Node

signal primary_fired
signal active_dash_fired
signal move_dir_change(move_dir: Vector3)

var move_dir := Vector3.ZERO
var movement_state := false

func _input(event):
	if event.is_action_pressed("primary_attack"):
		if can_attack():
			primary_fired.emit()

	if event.is_action_pressed("active_dash"):
		if can_attack():
			active_dash_fired.emit()
	
	move_dir.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	move_dir.z = Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	
	if movement_state != is_movement_ongoing():
		movement_state = is_movement_ongoing()
		move_dir_change.emit(move_dir)
	
func can_attack():
	var value = true
	
	# Add conditions for verifying if attack is possible
	
	return value


func is_movement_ongoing() -> bool:
	return abs(move_dir.x) > 0 or abs(move_dir.z) > 0
