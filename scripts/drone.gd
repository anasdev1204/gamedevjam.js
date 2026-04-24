class_name Drone
extends Player

@onready var projectile_markers: Node3D = $model/projectile_markers

signal shot_fired

func _ready():
	super._ready()
	
	input_component.primary_fired.connect(
		_on_primary_fired
	)
	
func _on_primary_fired():
	var projectile_spawn_locations := []
	var projectile_dirs := []
	
	for marker in projectile_markers.get_children():
		projectile_spawn_locations.append(marker.global_position)
		projectile_dirs.append(-marker.global_transform.basis.z)
	
	shot_fired.emit(projectile_spawn_locations, projectile_dirs)
