class_name BigEnemy
extends Player

#@onready var beam_marker: Marker3D = $Armature/beam_marker
@onready var beam_marker: Marker3D = $Armature/Skeleton3D/Cube_004/beam_marker

signal shot_fired

func _ready():
	super._ready()
	
	input_component.primary_fired.connect(
		_on_shot_fired
	)
	
func _on_shot_fired():
	var projectile_spawn_location = beam_marker.global_position
	var projectile_dir = -beam_marker.global_basis.z

	shot_fired.emit(projectile_spawn_location, projectile_dir)
