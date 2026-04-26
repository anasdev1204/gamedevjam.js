extends Node

@onready var main = get_tree().root.get_node("main")
@onready var explosion = preload("res://assets/scenes/vfx/explosion_vfx.tscn")

func spawn_explosion(position: Vector3, is_enemy: bool):
	var explosion_instance = explosion.instantiate()
	explosion_instance.spawnPos = position + Vector3(0., 1., 0.)
	explosion_instance.is_enemy = is_enemy

	main.call_deferred("add_child", explosion_instance)
