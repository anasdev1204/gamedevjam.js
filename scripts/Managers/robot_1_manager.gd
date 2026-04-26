class_name Robot1Manager
extends Node

@export var camera_bounds: Area3D
@export var spawn_delay := 2.

@onready var main = get_tree().root.get_node("main")
@onready var robot1 = preload("res://assets/scenes/robot_1.tscn")

@onready var explosion_manager: Node = %ExplosionManager

@onready var robot1_spawner: Marker3D = $"../Spawns/robot1_spawner"
@onready var robot_1_postspawn: Marker3D = $"../PostSpawn/robot1postspawn"
@onready var lift_1: Node3D = $"../Map/lifts/lift1"
@onready var global_spawner: Marker3D = $"../GlobalSpawner"

func init_spawn() -> Robot1:
	var robot1_instance = _generate_instance()
	robot1_instance.is_controlled = true
	robot1_instance.global_transform = global_spawner.global_transform
	main.add_child(robot1_instance)
	return robot1_instance

func spawn(controlled: bool, number: float,  local_session: float):
	lift_1.open(_spawn.bind(controlled, number, local_session))
	
func _generate_instance() -> Robot1:
	var robot1_instance: Robot1 = robot1.instantiate()
	robot1_instance.visible_area = camera_bounds
	robot1_instance.explode.connect(
		explosion_manager.spawn_explosion
	)
	return robot1_instance
	
func _spawn(_animation: String, controlled: bool, number: float,  local_session: float):
	for i in range(number):
		var robot1_instance = _generate_instance()
		robot1_instance.is_controlled = controlled
		
		robot1_instance.global_transform = robot1_spawner.global_transform
		main.add_child.call_deferred(robot1_instance)
		if not controlled:
			robot1_instance.ready.connect(
				robot1_instance.on_spawn.bind(
					robot_1_postspawn.global_position, 
					main.active_player,
					lift_1.close  if i + 1 == number else do_nothing
				)
			)
		await get_tree().create_timer(spawn_delay).timeout

		if local_session != main.spawn_session:
			return
func do_nothing():
	pass
