extends Node

@export var camera_bounds: Area3D

@onready var main = get_tree().root.get_node("main")
@onready var projectile_manager: Node = %ProjectileManager
@onready var bigenemy = preload("res://assets/scenes/bigenemy.tscn")

func _ready():
	var bigenemy_instance = bigenemy.instantiate()
	bigenemy_instance.visible_area = camera_bounds
	main.add_child.call_deferred(bigenemy_instance)
	bigenemy_instance.shot_fired.connect(
		projectile_manager._spawn_beam
	)
