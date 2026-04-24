class_name Hitbox
extends Area3D

@export var damage := 10.

func set_enemy_group():
	add_to_group("enemy")

func leave_enemy_group():
	remove_from_group("enemy")

func update_monitorable(new_monitorable: bool):
	monitorable = new_monitorable

	if new_monitorable:
		_check_initial_overlaps()
		
func _check_initial_overlaps():
	for area in get_overlapping_areas():
		if is_instance_of(area, Hurtbox):
			area.on_area_overlap(self)
