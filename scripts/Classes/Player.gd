class_name Player extends CharacterBody3D

@export var visible_area: Area3D
@export var movement_time_scale := 1.2
@export var is_controlled := false

@onready var input_component: InputComponent = %InputComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var rotation_component: RotationComponent = %RotationComponent
@onready var camera_component: CameraComponent = %CameraComponent
@onready var active_skill_component: ActiveSkillComponent = %ActiveSkillComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var ai_component: AIComponent = %AIComponent

@onready var model: MeshInstance3D = %model
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var omni_light_3d: OmniLight3D = $OmniLight3D

@onready var swtich_area: SwitchArea = %SwtichArea
@onready var switch_indicator: Sprite3D = %SwitchIndicator

const blinking_explosion_shader = preload("res://res/shaders/blinking_explosion.tres")
const EXPLOSION_CURVE = preload("res://res/explosion_curve.tres")
const EXPLOSION_RAMP = preload("res://res/explosion_ramp.tres")

var is_attacking := false

signal explode
signal switched
signal switch_ready

var switch_cooldown_timer: Timer
var switch_cooldown := 10.

var explosion_mat: ShaderMaterial
var progress := 0.0
var explode_speed := 0.5
var is_exploding := false

func _ready():
	camera_component.bounds_area = visible_area
	camera_component.update_bounds()
	
	if is_controlled:
		enable()
	else:
		disable()
		
	health_component.die.connect(
		_explode
	)
	
	switch_cooldown_timer = Timer.new()
	switch_cooldown_timer.one_shot = true
	add_child(switch_cooldown_timer)
	switch_cooldown_timer.timeout.connect(
		_on_switch_cooldown_timer_timeout
	)
	
func _physics_process(delta: float) -> void:
	if is_exploding:
		progress += delta * explode_speed
		progress = min(progress, 0.9)

		if explosion_mat:
			explosion_mat.set_shader_parameter("progress", progress)
		if progress >= 0.9:
			explode.emit(global_position, not is_controlled)
			queue_free()
			
		return
	
	if is_controlled:
		movement_component.update(
			delta,
			input_component.move_dir,
			is_attacking
		)

		rotation_component.update(
			delta,
			input_component.move_dir,
			input_component.attack_dir,
			is_attacking
		)
		
		camera_component.update(
			delta
		)
	elif ai_component.is_AI_active():
		rotation_component.update(
			delta,
			ai_component.move_dir,
			ai_component.move_dir,
			false
		)
	
var tween: Tween

func _on_movement_change(move_dir: Vector3):
	if tween:
		tween.kill()
		
	tween = create_tween()
	
	tween.tween_property(
		animation_tree, 
		"parameters/movement_blend/blend_position", 
		move_dir.length(),
		0.25
	)
	
	tween.parallel().tween_property(
		animation_tree, 
		"parameters/movement_time_scale/scale", 
		movement_time_scale,
		0.75
	)
	
func _active_ai(active_player: Player):
	ai_component.set_player_to_follow(active_player)
	
func _explode():
	is_exploding = true

	explosion_mat = ShaderMaterial.new()
	explosion_mat.shader = blinking_explosion_shader
	
	var curve_tex := CurveTexture.new()
	curve_tex.curve = EXPLOSION_CURVE
	
	var ramp_tex := GradientTexture1D.new()
	ramp_tex.gradient = EXPLOSION_RAMP
	
	explosion_mat.set_shader_parameter("curve_texture", curve_tex)
	explosion_mat.set_shader_parameter("color_ramp", ramp_tex)
	
	progress = 0.1
	model.material_overlay  = explosion_mat
	
func _unexplode():
	is_exploding = false
	model.material_overlay = null
	
func _switch(switch_to: Player):
	if _can_switch():
		return
	switch_to.enable()
	get_parent().set_active_player(switch_to)
	disable(false)
	_active_ai(switch_to)
	
func enable():
	is_controlled = true
	
	if is_exploding:
		_unexplode()
	
	camera_component.disabled = false
	camera_component.set_camera_current(true)
	
	omni_light_3d.visible = true
	
	input_component.disabled = false
	
	input_component.move_dir_change.connect(
		_on_movement_change
	)
	
	input_component.primary_fired.connect(
		active_skill_component._on_primary_fire
	)
	
	input_component.active_dash_fired.connect(
		movement_component._on_active_dash
	)
	
	input_component.switch_fired.connect(
		_switch
	)
	
	_disconnect_ai()
	
	swtich_area.active = true
	switch_indicator.visible = false
	
	if is_in_group("enemy"):
		remove_from_group("enemy")
		
	
func disable(_init := true):
	is_controlled = false
	
	if is_exploding:
		_unexplode()
		
	camera_component.disabled = true
	camera_component.set_camera_current(false)
	
	omni_light_3d.visible = false
	
	input_component.disabled = true
	
	_disconnect_input()
		
	ai_component.move_dir_change.connect(
		_on_movement_change
	)
	
	ai_component.primary_fired.connect(
		active_skill_component._on_primary_fire
	)
	
	swtich_area.active = false
	switch_indicator.visible = false
	
	health_component.reset_health(ai_component.health * Global.wave_multiplier)
	
	add_to_group("enemy")
	
	
func _disconnect_input():
	if input_component.move_dir_change.is_connected(_on_movement_change):
		input_component.move_dir_change.disconnect(_on_movement_change)

	if input_component.primary_fired.is_connected(active_skill_component._on_primary_fire):
		input_component.primary_fired.disconnect(active_skill_component._on_primary_fire)

	if input_component.active_dash_fired.is_connected(movement_component._on_active_dash):
		input_component.active_dash_fired.disconnect(movement_component._on_active_dash)

	if input_component.switch_fired.is_connected(_switch):
		input_component.switch_fired.disconnect(_switch)
		
func _disconnect_ai():
	if ai_component.move_dir_change.is_connected(_on_movement_change):
		ai_component.move_dir_change.disconnect(_on_movement_change)

	if ai_component.primary_fired.is_connected(active_skill_component._on_primary_fire):
		ai_component.primary_fired.disconnect(active_skill_component._on_primary_fire)

func start_switch_cooldown():
	switch_cooldown_timer.start(switch_cooldown)

func _on_switch_cooldown_timer_timeout():
	switch_ready.emit()
	
func _can_switch():
	return switch_cooldown_timer.time_left > 0

func on_spawn(pos: Vector3, active_player: Player, callable: Callable):
	set_collision_shape_state(true)

	var temp = func():
		set_collision_shape_state(false)
		_active_ai(active_player)
		callable.call()

	movement_component.move_to(pos, temp)
	
func set_player_attacking(attacking: bool):
	is_attacking = attacking
	
func set_camera_bounds(new_bounds: Area3D):
	camera_component.bounds_area = new_bounds
	camera_component.update_bounds()

func set_collision_shape_state(new_state: bool):
	collision_shape_3d.disabled = new_state
	
