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

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var omni_light_3d: OmniLight3D = $OmniLight3D

var is_attacking := false

func _ready():
	if is_controlled:
		camera_component.disabled = false
		camera_component.set_camera_current(true)
		camera_component.bounds_area = visible_area
		camera_component.update_bounds()
		
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
	else:
		ai_component.move_dir_change.connect(
			_on_movement_change
		)
		
func _physics_process(delta: float) -> void:
	if is_controlled:
		movement_component.update(
			delta,
			input_component.move_dir,
			is_attacking
		)

		rotation_component.update(
			delta,
			input_component.move_dir
		)
		
		camera_component.update(
			delta
		)
	elif ai_component.is_AI_active():
		movement_component.update(
			delta,
			ai_component.move_dir,
			is_attacking
		)

		rotation_component.update(
			delta,
			ai_component.move_dir
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
