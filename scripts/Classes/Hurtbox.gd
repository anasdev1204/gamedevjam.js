class_name Hurtbox
extends Area3D

signal area_overlap

func on_area_overlap(area: Hitbox):
	area_overlap.emit(area)
