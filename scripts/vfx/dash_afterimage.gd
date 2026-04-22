extends Node3D

@export var character_mesh: MeshInstance3D
@export var spawn_interval: float = 0.04
@export var ghost_lifetime: float = 0.1
@export var ghost_color: Color = Color(0.4, 0.7, 1.0, 0.6)

var _timer: float = 0.0
var _is_active: bool = false

func _ready() -> void:
	print("Mesh found: ", character_mesh)
	print("Surface count: ", character_mesh.mesh.get_surface_count())

func start() -> void:
	_is_active = true

func stop() -> void:
	_is_active = false

func _process(delta: float) -> void:
	if not _is_active:
		return

	_timer -= delta
	if _timer <= 0.0:
		_timer = spawn_interval
		_spawn_ghost()

func _spawn_ghost():
	var ghost := MeshInstance3D.new()
	ghost.mesh = character_mesh.mesh 

	ghost.global_transform = character_mesh.global_transform

	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = ghost_color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED  # flat ghost look
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	ghost.material_override = mat

	get_tree().current_scene.add_child(ghost)

	var tween := get_tree().create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.0, ghost_lifetime)
	tween.tween_callback(ghost.queue_free)
