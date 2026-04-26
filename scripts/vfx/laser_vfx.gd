extends Node3D

var dir: Vector3
var spawnPos: Vector3
var is_enemy: bool

@onready var hitbox: Hitbox = $hitbox

@export var length_curve: Curve
@export var max_length: float = 2.
@export var duration: float = 0.8

@export var enemy_particles_color: Color = Color("ff8a6a")
@export var ally_particles_color: Color = Color("6AC8FF")


@onready var beam: MeshInstance3D = $beam
@onready var inner_beam: MeshInstance3D = $inner_beam
@onready var start_beam: MeshInstance3D = $start_beam
@onready var particles: CPUParticles3D = $particles

var time := 0.0

func _ready():
	global_position = spawnPos
	dir = dir.normalized()
	
	if is_enemy:
		hitbox.set_enemy_group()
		set_enemy_color()
	else:
		set_ally_color()
		
	look_at(global_position + dir, Vector3.UP)
	particles.emitting = true

func _process(delta):
	time += delta

	var t: float = clamp(time / duration, 0.0, 1.0)

	# curve controls beam growth
	var curve_value := length_curve.sample(t)
	var length := curve_value * max_length

	_apply_inner_beam(length)
	_apply_beam(length)

	if t >= 1.0:
		queue_free()
		
func _apply_beam(length: float) -> void:
	beam.position = Vector3(0, 0, length * 0.05)
	beam.scale = Vector3(0.8, 0.8, length)	
	
func _apply_inner_beam(length: float) -> void:
	hitbox.update_monitorable(true)	
	inner_beam.position = Vector3(0, 0, length * 0.05)
	inner_beam.scale = Vector3(0.4, 0.4, length)
	

func set_ally_color():
	var beam_mat = beam.material_override as ShaderMaterial
	beam_mat.set_shader_parameter("Color", Global.ally_color)
	beam.material_override = beam_mat
	
	var start_beam_mat = start_beam.material_override as ShaderMaterial
	start_beam_mat.set_shader_parameter("Color", Global.ally_color)
	start_beam.material_override = start_beam_mat
	
	var particles_mat = particles.material_override as ShaderMaterial
	particles_mat.set_shader_parameter("Color", ally_particles_color)
	particles.material_override = particles_mat

func set_enemy_color():
	var beam_mat = beam.material_override as ShaderMaterial
	beam_mat.set_shader_parameter("Color", Global.enemy_color)
	beam.material_override = beam_mat
	
	var start_beam_mat = start_beam.material_override as ShaderMaterial
	start_beam_mat.set_shader_parameter("Color", Global.enemy_color)
	start_beam.material_override = start_beam_mat
	
	var particles_mat = particles.material_override as ShaderMaterial
	particles_mat.set_shader_parameter("Color", enemy_particles_color)
	particles.material_override = particles_mat
