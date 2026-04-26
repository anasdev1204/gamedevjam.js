class_name MovementComponent
extends Node

@export var body: CharacterBody3D
@export var rotation_component: RotationComponent
@export var camera_component: CameraComponent
@export var health_component: HealthComponent
@export var dash_after_image_vfx: Node3D

@export var speed := 20.0
@export var acceleration := 100.0
@export var deceleration := 140.0
@export var turn_speed := 90.0

@export var active_dash_speed := 100.0
@export var active_dash_duration := 0.2
@export var active_dash_cooldown := 1.
@export var active_dash_camera_size := 25

@export var knockback_duration := 0.2

var active_dash_timer: Timer
var active_dash_cooldown_timer: Timer
signal dash_used
signal dash_ready

var knockback_speed := 8.0
var knockback_timer: Timer
var knockback_direction: Vector3

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
	
	knockback_timer = Timer.new()
	knockback_timer.one_shot = true
	add_child(knockback_timer)
	
	active_dash_timer.timeout.connect(
		_on_active_dash_end
	)
	active_dash_cooldown_timer.timeout.connect(
		_on_active_dash_cooldown_timer_end
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
	
	if is_knocked_back():
		var hit_direction := (body.global_position -knockback_direction ).normalized()
		hit_direction.y = 0.
		body.velocity = knockback_speed * hit_direction
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
	
func move_to(pos: Vector3, on_finished: Callable = Callable()) -> void:
	if body == null:
		return
		
	# radius of spread around target
	var spread_radius := 1.5

	# random point in circle (XZ plane)
	var angle := randf() * TAU
	var radius := sqrt(randf()) * spread_radius

	var offset := Vector3(
		cos(angle) * radius,
		0.0,
		sin(angle) * radius
	)

	var final_pos := pos + offset

	var threshold := 0.1

	while is_instance_valid(body):
		var to_target := final_pos - body.global_position

		var distance := to_target.length()

		if distance <= threshold:
			break

		var dir := to_target.normalized()
		get_parent()._on_movement_change(dir)
		if rotation_component:
			rotation_component.update(get_process_delta_time(), dir, dir, false)

		target_velocity = dir * speed

		body.velocity.x = move_toward(
			body.velocity.x,
			target_velocity.x,
			acceleration * get_process_delta_time()
		)
		
		body.velocity.y = move_toward(
			body.velocity.y,
			target_velocity.y,
			acceleration * get_process_delta_time()
		)

		body.velocity.z = move_toward(
			body.velocity.z,
			target_velocity.z,
			acceleration * get_process_delta_time()
		)

		body.move_and_slide()

		await get_tree().physics_frame

	# stop exactly at target
	body.global_position = Vector3(final_pos.x, final_pos.y, final_pos.z)
	body.velocity.x = 0.0
	body.velocity.z = 0.0
	get_parent()._on_movement_change(Vector3.ZERO)
	if on_finished.is_valid():
		on_finished.call()

func passive_dash(_velocity : Vector3, duration : float, delay : float):
	if _velocity == Vector3.ZERO:
		return

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
	health_component.start_invincibility_timer(active_dash_duration)
	dash_after_image_vfx.start()
	dash_used.emit()
	camera_component.set_camera_size(active_dash_camera_size)
	
func _on_active_dash_end():
	camera_component.set_camera_size()
	dash_after_image_vfx.stop()
	active_dash_cooldown_timer.start(active_dash_cooldown * Global.dash_cd_mult)
	
func _on_active_dash_cooldown_timer_end():
	dash_ready.emit()
	
func is_active_dashing() -> bool:
	return active_dash_timer.time_left > 0

func can_active_dash() -> bool:
	return active_dash_cooldown_timer.time_left <= 0

func knock_back(attack_global_position: Vector3, knockback_value: float):
	knockback_timer.start(knockback_duration)
	knockback_speed = knockback_value
	knockback_direction = attack_global_position
	
func is_knocked_back() -> bool:
	return knockback_timer.time_left > 0.
