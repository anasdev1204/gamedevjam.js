class_name DroneManager
extends Node

@export var camera_bounds: Area3D

@onready var main = get_tree().root.get_node("main")
@onready var projectile_manager: Node = %ProjectileManager
@onready var drone = preload("res://assets/scenes/drone.tscn")
@onready var drone_spawner: Marker3D = $"../Spawns/drone_spawner"
@onready var dronepostspawn: Marker3D = $"../PostSpawn/dronepostspawn"
@onready var global_spawner: Marker3D = $"../GlobalSpawner"

func _ready():
	#_spawn("", true)
	pass


func spawn(controlled: bool):
	_spawn("", controlled)
	
func _generate_instance() -> Drone:
	var drone_instance: Drone = drone.instantiate()
	drone_instance.visible_area = camera_bounds
	drone_instance.shot_fired.connect(
		projectile_manager.spawn_projectile
	)
	return drone_instance

func _spawn(_animation: String, controlled: bool):
	var drone_instance: Drone = _generate_instance()
	drone_instance.is_controlled = controlled
	
	var active_spawner = drone_spawner if not controlled else global_spawner
	drone_instance.global_transform = active_spawner.global_transform
	main.add_child.call_deferred(drone_instance)
	
	if not controlled:
		drone_instance.ready.connect(
			drone_instance.on_spawn.bind(
				dronepostspawn.global_position, 
				main.active_player,
				do_nothing
			)
		)
	else:
		main.active_player = drone_instance

func do_nothing():
	pass
