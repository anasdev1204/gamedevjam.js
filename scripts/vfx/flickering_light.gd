extends Node3D

@onready var light: OmniLight3D = $OmniLight3D

@export var base_energy := 1.
@export var base_range := 5.
@export_range(0., 1., 0.1) var flicker_speed := 1.

@export_range(0., 1., 0.1) var intensity_range := 0.5
@export_range(0., 1., 0.1) var flicker_chance := 0.4
@export_range(0., 1., 0.01) var check_interval := 0.1
@export_range(0., 20.) var smooth_speed := 20.

var timer: float
var target_energy: float
var current_energy: float

func _ready():
	target_energy = base_energy
	current_energy = base_energy
	
	light.light_energy = base_energy
	light.omni_range = base_range
	
func _process(delta):
	timer += delta * flicker_speed
	
	if timer >= check_interval:
		timer = 0
		
		if randf() < flicker_chance:
			var flicker_amount := randf_range(0.0, intensity_range)
			target_energy = base_energy - (base_energy * flicker_amount)
		else:
			target_energy = base_energy
		
	current_energy = lerp(current_energy, target_energy, smooth_speed * delta)
	light.light_energy = current_energy
