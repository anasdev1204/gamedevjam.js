class_name MovementComponent
extends Node

@export var body: CharacterBody3D
@export var rotation_component: RotationComponent
@export var camera_component: CameraComponent
@export var dash_after_image_vfx: Node3D

@export var speed := 20.0
@export var acceleration := 100.0
@export var deceleration := 140.0
@export var turn_speed := 90.0

@export var active_dash_speed := 100.0
@export var active_dash_duration := 0.2
@export var active_dash_cooldown := 1.
@export var active_dash_camera_size := 25

var active_dash_timer: Timer
var active_dash_cooldown_timer: Timer

var target_velocity: Vector3

var passive_dash_velocity: Vector3
var passive_dash_acceleration: float
var passive_dash_timer : Timer
var last_direction: Vector3

func _ready():
	passive_dash_timer = Timer.new()
	passive_dash_timer.one_shot = true
	add_child(passive_dash_timer)
	
	active_dash_timer = Timer.new()
	active_dash_timer.one_shot = true
	add_child(active_dash_timer)
	
	active_dash_cooldown_timer = Timer.new()
	active_dash_cooldown_timer.one_shot = true
	add_child(active_dash_cooldown_timer)
	
	active_dash_timer.timeout.connect(
		_on_active_dash_end
	)

func update(delta: float, move_dir: Vector3, is_attacking: bool):	
	if body == null:
		return
	
	if move_dir != Vector3.ZERO:
		last_direction = move_dir
		
	if is_active_dashing():
		var dash_direction := last_direction.normalized()
		body.velocity = active_dash_speed * dash_direction
		body.move_and_slide()
		return
		
	var active_accel := acceleration
	var direction := move_dir.normalized()
	
	target_velocity = speed * direction.normalized()

	if is_passive_dashing():
		target_velocity.x = passive_dash_velocity.x
		target_velocity.z = passive_dash_velocity.z
		active_accel = passive_dash_acceleration
	elif is_attacking:
		target_velocity.x = 0
		target_velocity.z = 0
		
	if direction != Vector3.ZERO:
		body.velocity.x = move_toward(
			body.velocity.x,
			target_velocity.x,
			active_accel * delta
		)

		body.velocity.z = move_toward(
			body.velocity.z,
			target_velocity.z,
			active_accel * delta
		)
	else:
		body.velocity.x = move_toward(
			body.velocity.x,
			0.0,
			deceleration * delta
		)	

		body.velocity.z = move_toward(
			body.velocity.z,
			0.0,
			deceleration * delta
		)

	body.move_and_slide()

func passive_dash(_velocity : Vector3, duration : float, delay : float):
	if _velocity == Vector3.ZERO:
		return
	rotation_component.tween_rotate(delay * 0.5, last_direction)
	await get_tree().create_timer(delay).timeout
	passive_dash_timer.start(duration)
	var rotation : float = atan2(last_direction.x, last_direction.z)
	passive_dash_velocity = _velocity.rotated(Vector3.UP, rotation)

func is_passive_dashing() -> bool:
	return passive_dash_timer.time_left > 0

func _on_active_dash():
	if not can_active_dash():
		print("cant dash")
		return
		
	active_dash_timer.start(active_dash_duration)
	dash_after_image_vfx.start()
	camera_component.set_camera_size(active_dash_camera_size)
	
func _on_active_dash_end():
	camera_component.set_camera_size()
	dash_after_image_vfx.stop()
	active_dash_cooldown_timer.start(active_dash_cooldown)
	
func is_active_dashing() -> bool:
	return active_dash_timer.time_left > 0

func can_active_dash() -> bool:
	return active_dash_cooldown_timer.time_left <= 0
