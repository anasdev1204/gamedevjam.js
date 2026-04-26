extends Node3D

@onready var clouds: CPUParticles3D = $clouds
@onready var particles: GPUParticles3D = $particles
@onready var flare: CPUParticles3D = $flare

@onready var hitbox: Hitbox = $Hitbox


var spawnPos: Vector3
var is_enemy: bool

func _ready():
	global_position = spawnPos
	
	if is_enemy:
		hitbox.set_enemy_group()
	
	flare.emitting = true
	particles.emitting = true
	clouds.emitting = true
	clouds.finished.connect(_on_clouds_finished)
	
func _on_clouds_finished():
	queue_free()
