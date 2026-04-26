extends Node3D

@export var speed := 20.0
@export var lifetime := 2.

@onready var hitbox: Hitbox = $Hitbox

var dir: Vector3
var spawnPos: Vector3
var current_lifetime: float
var is_enemy: bool

@onready var outer: MeshInstance3D = $Outer
@onready var inner: MeshInstance3D = $Inner
@onready var trail: MeshInstance3D = $Trail
@onready var trail2: MeshInstance3D = $Trail2

@onready var enemy_trail = preload("res://res/projectile_trail_enemy.tres")
@onready var ally_trail = preload("res://res/projectile_trail_ally.tres")


func _ready():
	global_position = spawnPos
	look_at(global_position + dir, Vector3.DOWN)
	
	if is_enemy:
		hitbox.set_enemy_group()
		set_enemy_color()
	else:
		set_ally_color()
	
	hitbox.update_monitorable(true)
	hitbox.on_enter = impact

func _physics_process(delta: float) -> void:
	current_lifetime += delta
	if current_lifetime >= lifetime:
		queue_free()
	global_position += -global_transform.basis.x * speed * delta
	
func set_ally_color():
	var outer_mat = outer.material_override as ShaderMaterial
	outer_mat.set_shader_parameter("Color", Global.ally_color)
	outer.material_override = outer_mat
	
	var inner_mat = inner.material_override as ShaderMaterial
	inner_mat.set_shader_parameter("Color", Global.ally_color_dark)
	inner.material_override = inner_mat
	
	var trail_mat = trail.material_override as ShaderMaterial
	trail_mat.set_shader_parameter("Color", _gradient_to_texture(ally_trail))
	trail.material_override = trail_mat
	
	var trail2_mat = trail2.material_override as ShaderMaterial
	trail2_mat.set_shader_parameter("Color", _gradient_to_texture(ally_trail))
	trail2.material_override = trail2_mat
	
	
func _gradient_to_texture(grad: Gradient) -> GradientTexture1D:
	var tex := GradientTexture1D.new()
	tex.gradient = grad
	return tex

func set_enemy_color():
	var outer_mat = outer.material_override as ShaderMaterial
	outer_mat.set_shader_parameter("Color", Global.enemy_color)
	outer.material_override = outer_mat
	
	var inner_mat = inner.material_override as ShaderMaterial
	inner_mat.set_shader_parameter("Color", Global.enemy_color_dark)
	inner.material_override = inner_mat
	
	var trail_mat = trail.material_override as ShaderMaterial
	trail_mat.set_shader_parameter("Color", _gradient_to_texture(enemy_trail))
	trail.material_override = trail_mat
	
	var trail2_mat = trail2.material_override as ShaderMaterial
	trail2_mat.set_shader_parameter("Color", _gradient_to_texture(enemy_trail))	
	trail2.material_override = trail2_mat

func impact():
	queue_free()
		
func reset_lifetime():
	current_lifetime = 0.
	
