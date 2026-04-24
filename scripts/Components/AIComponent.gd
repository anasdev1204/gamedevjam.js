class_name AIComponent
extends Node

@onready var nav_agent: NavigationAgent3D = $"../NavigationAgent3D"
var player_to_follow: Player

signal primary_fired
signal move_dir_change(move_dir: Vector3)

var move_dir := Vector3.ZERO
var movement_state := false

func _physics_process(_delta: float):
	if not is_AI_active():
		return
	
	nav_agent.set_target_position(player_to_follow.global_transform.origin)
	var next_nav_point = nav_agent.get_next_path_position()
	move_dir = (next_nav_point - get_parent().global_transform.origin).normalized()

	if movement_state != is_movement_ongoing():
		movement_state = is_movement_ongoing()
		move_dir_change.emit(move_dir)
		
func set_player_to_follow(new_player_to_follow: Player):
	player_to_follow = new_player_to_follow

func is_AI_active():
	return player_to_follow and not get_parent().is_controlled

func is_movement_ongoing() -> bool:
	return abs(move_dir.x) > 0 or abs(move_dir.z) > 0
	
