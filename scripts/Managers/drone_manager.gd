extends Node

@export var camera_bounds: Area3D

@onready var main = get_tree().root.get_node("main")
@onready var projectile_manager: Node = %ProjectileManager
@onready var drone = preload("res://assets/scenes/drone.tscn")
@onready var drone_spawner: Marker3D = $"../Spawns/drone_spawner"

func _ready():
	var drone_instance = drone.instantiate()
	drone_instance.visible_area = camera_bounds
	main.add_child.call_deferred(drone_instance)
	drone_instance.shot_fired.connect(
		projectile_manager._spawn_projectile
	)
