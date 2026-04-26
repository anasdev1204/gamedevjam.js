extends MeshInstance3D

@onready var hitbox: Hitbox = $Hitbox
@onready var blade_2: MeshInstance3D = $blade2

func set_is_enemy():
	hitbox.set_enemy_group()
	_set_blade_color(Global.enemy_color)


func set_is_ally():
	hitbox.leave_enemy_group()
	_set_blade_color(Global.ally_color)


func set_monitorable(monitorable: bool):
	hitbox.update_monitorable(monitorable)


func _set_blade_color(color: Color):
	var mat = blade_2.material_overlay

	if mat is StandardMaterial3D:
		mat = mat.duplicate()
		mat.emission = color
		blade_2.material_overlay = mat
