class_name BigEnemyManager
extends Node

@export var camera_bounds: Area3D
@export var map: NavigationRegion3D

@onready var main = get_tree().root.get_node("main")
@onready var projectile_manager: Node = %ProjectileManager
@onready var bigenemy = preload("res://assets/scenes/bigenemy.tscn")
@onready var door: Node3D = $"../Map/door/door"
@onready var bigenemy_spawner: Marker3D = $"../Spawns/bigenemy_spawner"
@onready var bigenemypostspawn: Marker3D = $"../PostSpawn/bigenemypostspawn"
@onready var global_spawner: Marker3D = $"../GlobalSpawner"

func _ready():
	_spawn("", true)
	#pass

func spawn(controlled: bool):
	door.open(_spawn.bind(controlled))
	
func _generate_instance() -> BigEnemy:
	var bigenemy_instance: BigEnemy = bigenemy.instantiate()
	bigenemy_instance.visible_area = camera_bounds
	bigenemy_instance.shot_fired.connect(
		projectile_manager.spawn_beam
	)
	return bigenemy_instance

func _spawn(_animation: String, controlled: bool):
	var bigenemy_instance = _generate_instance()
	bigenemy_instance.is_controlled = controlled
	
	var active_spawner = bigenemy_spawner if not controlled else global_spawner
	bigenemy_instance.global_transform = active_spawner.global_transform
	map.add_child.call_deferred(bigenemy_instance)
	
	if not controlled:
		bigenemy_instance.ready.connect(
			bigenemy_instance.on_spawn.bind(
				bigenemypostspawn.global_position, 
				main.active_player,
				door.close
			)
		)
	else:
		main.active_player = bigenemy_instance

func do_nothing():
	pass
