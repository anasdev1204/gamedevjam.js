extends Node

@onready var main = get_tree().root.get_node("main")
@onready var drone_projectile = preload("res://assets/scenes/vfx/drone_projectile.tscn")
@onready var bigenemy_beam = preload("res://assets/scenes/vfx/laser_vfx.tscn")

func _spawn_projectile(
	projectile_spawn_locations: Array,
	projectile_dir: Array
) -> void:
	for i in range(projectile_spawn_locations.size()):
		var projectile_instance = drone_projectile.instantiate()
		
		projectile_instance.dir = projectile_dir[i]
		projectile_instance.spawnPos = projectile_spawn_locations[i]
		
		main.call_deferred("add_child", projectile_instance)


func _spawn_beam(
	projectile_spawn_locations: Vector3,
	projectile_dir: Vector3
) -> void:
	await get_tree().create_timer(5.0 / Engine.physics_ticks_per_second).timeout
	var beam_instance = bigenemy_beam.instantiate()

	beam_instance.dir = projectile_dir
	beam_instance.spawnPos = projectile_spawn_locations
	
	main.call_deferred("add_child", beam_instance)
