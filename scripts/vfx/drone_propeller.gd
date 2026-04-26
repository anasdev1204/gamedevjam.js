extends Node3D

@onready var drone_propeller: MeshInstance3D = $DronePropeller

var is_enemy := false

func set_color():
	var mat = drone_propeller.material_override

	if mat is ShaderMaterial:
		var shader_mat := mat.duplicate() as ShaderMaterial
		var new_color := Global.enemy_color if is_enemy else Global.ally_color
		shader_mat.set_shader_parameter("tint", new_color) 
		drone_propeller.material_override = shader_mat
