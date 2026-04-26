class_name BigEnemy
extends Player

#@onready var beam_marker: Marker3D = $Armature/beam_marker
@onready var beam_marker: Marker3D = $Armature/Skeleton3D/model/beam_marker
@onready var ally_texture = preload("res://assets/source/entities/bigenemy/bigenemy_text_ally.png")
@onready var enemy_texture = preload("res://assets/source/entities/bigenemy/bigenemy_text_enemy.png")


signal shot_fired
		
func enable():
	super.enable()
	
	input_component.primary_fired.connect(
		_on_primary_fired
	)
	
	_set_material(ally_texture)
		
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


func _on_primary_fired():
	await get_tree().create_timer(15.0 / Engine.physics_ticks_per_second).timeout
	var projectile_spawn_location = beam_marker.global_position
	var projectile_dir = -beam_marker.global_basis.z

	shot_fired.emit(projectile_spawn_location, projectile_dir, not is_controlled)

func _set_material(texture):
	var mat = model.material_override 

	if mat is ShaderMaterial:
		mat = mat.duplicate()
		mat.set_shader_parameter("albedo", texture)
		model.material_override = mat
