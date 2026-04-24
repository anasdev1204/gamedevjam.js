extends Node

@onready var main = get_tree().root.get_node("main")
@onready var drone_projectile = preload("res://assets/scenes/vfx/drone_projectile.tscn")
@onready var bigenemy_beam = preload("res://assets/scenes/vfx/laser_vfx.tscn")

func spawn_projectile(
	projectile_spawn_locations: Array,
	projectile_dir: Array
) -> void:
	for i in range(projectile_spawn_locations.size()):
		var projectile_instance = drone_projectile.instantiate()
		
		projectile_instance.dir = projectile_dir[i]
		projectile_instance.spawnPos = projectile_spawn_locations[i]
		
		main.call_deferred("add_child", projectile_instance)


func spawn_beam(
	projectile_spawn_locations: Vector3,
	projectile_dir: Vector3
) -> void:
	var beam_instance = bigenemy_beam.instantiate()

	beam_instance.dir = projectile_dir
	beam_instance.spawnPos = projectile_spawn_locations
	
	main.call_deferred("add_child", beam_instance)
