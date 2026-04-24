class_name AIComponent
extends Node

@export var body: CharacterBody3D
@export var speed := 20.
@export var attack_range := 8.0
@export var fire_cooldown := 0.8

@export var target_threshold := 0.1
@onready var nav_agent: NavigationAgent3D = $"../feet/NavigationAgent3D"
var player_to_follow: Player

signal primary_fired(dir: Vector3)
signal move_dir_change(move_dir: Vector3)

var move_dir := Vector3.ZERO
var fire_timer := 0.0

var last_movement: Vector3
var movement_state := false

func _physics_process(delta: float):
	if not is_AI_active():
		return
			#
	#nav_agent.set_target_position(player_to_follow.global_position)
	#var next_nav_point = nav_agent.get_next_path_position()
	#move_dir = (next_nav_point - body.global_position).normalized()
	#
	#body.velocity = move_dir * speed
	#
	#if movement_state != is_movement_ongoing():
		#movement_state = is_movement_ongoing()
		#move_dir_change.emit(move_dir)
		#
	#body.move_and_slide()
	
	fire_timer -= delta

	var dist = body.global_position.distance_to(player_to_follow.global_position)
	
	nav_agent.target_position = player_to_follow.global_position

	var next_nav_point = nav_agent.get_next_path_position()

	move_dir = (next_nav_point - body.global_position).normalized()
	move_dir.y = 0.0
	
	if dist <= attack_range:
		body.velocity = Vector3.ZERO

		if fire_timer <= 0.0:
			fire_timer = fire_cooldown
			primary_fired.emit()

		body.move_and_slide()
		return

	body.velocity = move_dir * speed

	if movement_state != is_movement_ongoing():
		movement_state = is_movement_ongoing()
		move_dir_change.emit(move_dir)

	body.move_and_slide()

		
func set_player_to_follow(new_player_to_follow: Player):
	player_to_follow = new_player_to_follow

func is_AI_active():
	return player_to_follow and not get_parent().is_controlled

func is_movement_ongoing() -> bool:
	return abs(move_dir.x) > 0 or abs(move_dir.z) > 0
	
