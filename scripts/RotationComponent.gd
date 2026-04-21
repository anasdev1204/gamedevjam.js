class_name RotationComponent extends Node

@export var player: Player
@export var model: Node3D
@export var rotation_speed := 10.0

var tween: Tween
var player_init_rotation : float


func _ready():
	player_init_rotation = player.rotation.y

func update(delta: float, direction: Vector3):
	if model and direction.length_squared() > 0.001:
		var look_dir := Vector2(direction.x, direction.z).normalized()
		var target_angle := atan2(look_dir.x, look_dir.y)
		model.rotation.y = lerp_angle(
			model.rotation.y,
			target_angle,
			rotation_speed * delta
		)

func tween_rotate(duration : float, direction: Vector3):
	if tween:
		tween.kill()
	
	var target_rotation : Vector3 = model.rotation
	target_rotation.y = lerp_angle(model.rotation.y, atan2(direction.x, direction.z) - player_init_rotation, 1)
	
	tween = create_tween()
	tween.tween_property(model, "rotation", target_rotation, duration)

func lerp_rotate(delta: float, direction: Vector3):
	#print('updating rotation in lerp function')
	
	var target_rotation = atan2(direction.x, direction.z) - player_init_rotation
	model.rotation.y = lerp_angle(model.rotation.y, target_rotation, rotation_speed * delta)
	 
