extends Node3D

@export var fog_size: Vector2 = Vector2(10.0, 10.0)

@onready var fog_mesh: MeshInstance3D = $fog_mesh

func _ready():
	var quad := fog_mesh.mesh as QuadMesh
	if quad:
		quad = quad.duplicate() # ensure unique instance
		fog_mesh.mesh = quad
		quad.size = fog_size
