class_name Drone
extends Player

@onready var projectile_markers: Node3D = $model/projectile_markers
@onready var ally_texture = preload("res://assets/source/entities/drone/drone_text_ally.png")
@onready var enemy_texture = preload("res://assets/source/entities/drone/drone_text_enemy.png")
@onready var gun: MeshInstance3D = %gun
@onready var propellers: Node3D = %propellers

signal shot_fired

func enable():
	super.enable()
	
	input_component.primary_fired.connect(
		_on_primary_fired
	)
	
	_set_material(ally_texture)
	_set_propellers_color(false)
	_set_gun_color(false)

func disable(_init := true):
	super.disable()
	
	if not ai_component.primary_fired.is_connected(_on_primary_fired):
		ai_component.primary_fired.connect(
			_on_primary_fired
		)
	
	if 	input_component.primary_fired.is_connected(_on_primary_fired):
		input_component.primary_fired.disconnect(
			_on_primary_fired
		)
	_set_material(enemy_texture)
	_set_propellers_color(true)
	_set_gun_color(true)

func _on_primary_fired():
	var projectile_spawn_locations := []
	var projectile_dirs := []
	
	for marker in projectile_markers.get_children():
		projectile_spawn_locations.append(marker.global_position)
		projectile_dirs.append(-marker.global_transform.basis.z)
	
	shot_fired.emit(projectile_spawn_locations, projectile_dirs, not is_controlled)

func _set_material(texture):
	var mat = model.material_override 
	
	if mat is ShaderMaterial:
		mat = mat.duplicate()
		mat.set_shader_parameter("albedo", texture)
		model.material_override = mat

func _set_propellers_color(is_enemy: bool):
	for prop in propellers.get_children():
		prop.is_enemy = is_enemy
		prop.set_color()

func _set_gun_color(is_enemy: bool):
	var mat = gun.material_override 
	
	if mat is StandardMaterial3D:
		var new_color := Global.enemy_color if is_enemy else Global.ally_color
		mat = mat.duplicate()
		mat.emission = new_color
		gun.material_override = mat
