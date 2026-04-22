class_name Player extends CharacterBody3D

@export var visible_area: Area3D
@export var movement_time_scale := 1.2

@onready var input_component: InputComponent = %InputComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var rotation_component: RotationComponent = %RotationComponent
@onready var camera_component: CameraComponent = %CameraComponent
@onready var active_skill_component: ActiveSkillComponent = %ActiveSkillComponent

@onready var animation_tree: AnimationTree = %AnimationTree

var is_attacking := false

func _ready():
	print(visible_area)
	camera_component.bounds_area = visible_area
	camera_component.update_bounds()
	
	input_component.move_dir_change.connect(
		_on_movement_change
	)
	
	input_component.primary_fired.connect(
		active_skill_component._on_primary_fire
	)
	
	input_component.active_dash_fired.connect(
		movement_component._on_active_dash
	)

func _physics_process(delta: float) -> void:		
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
	
func set_player_attacking(attacking: bool):
	is_attacking = attacking
	
func set_camera_bounds(new_bounds: Area3D):
	camera_component.bounds_area = new_bounds
