class_name Robot1Manager
extends Node

@export var camera_bounds: Area3D

@onready var main = get_tree().root.get_node("main")
@onready var robot1 = preload("res://assets/scenes/robot_1.tscn")
@onready var robot1_spawner: Marker3D = $"../Spawns/robot1_spawner"
@onready var robot_1_postspawn: Marker3D = $"../PostSpawn/robot1postspawn"
@onready var lift_1: Node3D = $"../Map/lifts/lift1"
@onready var global_spawner: Marker3D = $"../GlobalSpawner"

func _ready():
	#_spawn("", true)
	pass

func spawn(controlled: bool):
	lift_1.open(_spawn.bind(controlled))
	
func _generate_instance() -> Robot1:
	var robot1_instance: Robot1 = robot1.instantiate()
	robot1_instance.visible_area = camera_bounds
	return robot1_instance
	
func _spawn(_animation: String, controlled: bool):
	var robot1_instance = _generate_instance()
	robot1_instance.is_controlled = controlled
	
	var active_spawner = robot1_spawner if not controlled else global_spawner
	robot1_instance.global_transform = active_spawner.global_transform
	main.add_child.call_deferred(robot1_instance)

	if not controlled:
		robot1_instance.ready.connect(
			robot1_instance.on_spawn.bind(
				robot_1_postspawn.global_position, 
				main.active_player,
				lift_1.close
			)
		)
	else:
		main.active_player = robot1_instance
		
func do_nothing():
	pass
