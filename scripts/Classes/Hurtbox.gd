class_name Hurtbox
extends Area3D

signal hit(float, Vector3)

func hurtbox_entered(damage: float, attack_global_position: Vector3, knockback_value: float):
	hit.emit(damage, attack_global_position, knockback_value)
