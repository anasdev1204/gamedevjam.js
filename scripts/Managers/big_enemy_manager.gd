class_name BigEnemyManager
extends Node

@export var camera_bounds: Area3D
@export var map: NavigationRegion3D
@export var spawn_delay := 3.

@onready var main = get_tree().root.get_node("main")

@onready var projectile_manager: Node = %ProjectileManager
@onready var explosion_manager: Node = %ExplosionManager

@onready var bigenemy = preload("res://assets/scenes/bigenemy.tscn")
@onready var door: Node3D = $"../Map/door/door"
@onready var bigenemy_spawner: Marker3D = $"../Spawns/bigenemy_spawner"
@onready var bigenemypostspawn: Marker3D = $"../PostSpawn/bigenemypostspawn"

func spawn(controlled: bool, number: float):
	door.open(_spawn.bind(controlled, number))
	
func _generate_instance() -> BigEnemy:
	var bigenemy_instance: BigEnemy = bigenemy.instantiate()
	bigenemy_instance.visible_area = camera_bounds
	bigenemy_instance.shot_fired.connect(
		projectile_manager.spawn_beam
	)
	bigenemy_instance.explode.connect(
		explosion_manager.spawn_explosion
	)
	return bigenemy_instance

func _spawn(_animation: String, controlled: bool, number: float):
	for i in range(number):
		var bigenemy_instance = _generate_instance()
		bigenemy_instance.is_controlled = controlled
		
		bigenemy_instance.global_transform = bigenemy_spawner.global_transform
		main.add_child.call_deferred(bigenemy_instance)
		
		if not controlled:
			bigenemy_instance.ready.connect(
				bigenemy_instance.on_spawn.bind(
					bigenemypostspawn.global_position, 
					main.active_player,
					door.close if i + 1 == number else do_nothing
				)
			)
			await get_tree().create_timer(spawn_delay).timeout

func do_nothing():
	pass
