class_name DroneManager
extends Node

@export var camera_bounds: Area3D
@export var spawn_delay := 3.

@onready var main = get_tree().root.get_node("main")

@onready var projectile_manager: Node = %ProjectileManager
@onready var explosion_manager: Node = %ExplosionManager

@onready var drone = preload("res://assets/scenes/drone.tscn")
@onready var drone_spawner: Marker3D = $"../Spawns/drone_spawner"
@onready var dronepostspawn: Marker3D = $"../PostSpawn/dronepostspawn"

func spawn(controlled: bool, number: float, local_session: float):
	_spawn("", controlled, number, local_session)
	
func _generate_instance() -> Drone:
	var drone_instance: Drone = drone.instantiate()
	drone_instance.visible_area = camera_bounds
	drone_instance.shot_fired.connect(
		projectile_manager.spawn_projectile
	)
	drone_instance.explode.connect(
		explosion_manager.spawn_explosion
	)
	return drone_instance

func _spawn(_animation: String, controlled: bool, number: float, local_session: float):
	for i in range(number):
		var drone_instance: Drone = _generate_instance()
		drone_instance.is_controlled = controlled
		
		drone_instance.global_transform = drone_spawner.global_transform
		main.add_child.call_deferred(drone_instance)
		
		if not controlled:
			drone_instance.ready.connect(
				drone_instance.on_spawn.bind(
					dronepostspawn.global_position, 
					main.active_player,
					do_nothing
				)
			)
		await get_tree().create_timer(spawn_delay).timeout
	
		if local_session != main.spawn_session:
			return
func do_nothing():
	pass
