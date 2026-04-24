class_name BigEnemy
extends Player

#@onready var beam_marker: Marker3D = $Armature/beam_marker
@onready var beam_marker: Marker3D = $Armature/Skeleton3D/Cube_004/beam_marker

signal shot_fired

func _ready():
	super._ready()
	
	input_component.primary_fired.connect(
		_on_primary_fired
	)
	
func _on_primary_fired():
	await get_tree().create_timer(5.0 / Engine.physics_ticks_per_second).timeout
	var projectile_spawn_location = beam_marker.global_position
	var projectile_dir = -beam_marker.global_basis.z

	shot_fired.emit(projectile_spawn_location, projectile_dir)
