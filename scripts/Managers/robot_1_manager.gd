extends Node

@export var camera_bounds: Area3D

@onready var main = get_tree().root.get_node("main")
@onready var robot1 = preload("res://assets/scenes/robot_1.tscn")
@onready var robot1_spawner: Marker3D = $"../Spawns/robot1_spawner"

func _ready():
	var robot1_instance = robot1.instantiate()
	robot1_instance.visible_area = camera_bounds
	main.add_child.call_deferred(robot1_instance)
