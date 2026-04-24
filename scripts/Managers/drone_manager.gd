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
	var drone_instance = _generate_instance()
	drone_instance.is_controlled = true
	drone_instance.global_transform = global_spawner.global_transform
	main.add_child.call_deferred(drone_instance)


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
	drone_instance.global_transform = drone_spawner.global_transform
	main.add_child.call_deferred(drone_instance)
	drone_instance.ready.connect(
		drone_instance.on_spawn.bind(
			dronepostspawn.global_position, 
			do_nothing
		)
	)

func do_nothing():
	pass
