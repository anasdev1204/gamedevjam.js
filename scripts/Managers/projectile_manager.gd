extends Node

@onready var main = get_tree().root.get_node("main")
@onready var drone_projectile = preload("res://assets/source/entities/drone/drone_projectile.tscn")

func _spawn_projectile(
	projectile_spawn_locations: Array,
	projectile_dir: Array
) -> void:
	for i in range(projectile_spawn_locations.size()):
		var projectile_instance = drone_projectile.instantiate()
		
		projectile_instance.dir = projectile_dir[i]
		projectile_instance.spawnPos = projectile_spawn_locations[i]
		
		main.call_deferred("add_child", projectile_instance)
