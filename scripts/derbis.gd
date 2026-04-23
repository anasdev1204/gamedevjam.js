extends Node3D

@export var disable_collisions := true
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

func _ready():
	collision_shape_3d.disabled = disable_collisions
