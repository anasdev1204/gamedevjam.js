class_name Hitbox
extends Area3D

@export var damage := 10.
@export var knockback := 10.
@export var ally_multiplier := 2.

var on_enter: Callable

func _ready():
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area):	
	var active_multiplier: float = (ally_multiplier * Global.dmg_mult) if not is_in_group("enemy") else (Global.wave_multiplier * Global.enemy_dmg_mult)
	if monitoring and is_instance_of(area, Hurtbox):		
		if (
			(area.get_parent().is_in_group("enemy") and not is_in_group("enemy"))
			or
			(not area.get_parent().is_in_group("enemy") and is_in_group("enemy"))
		):
			area.hurtbox_entered(
				damage * active_multiplier, 
				get_parent().global_position, 
				knockback
			)
			
			
			if not is_in_group("enemy"):
				get_tree().current_scene.heal_player(damage * active_multiplier * Global.life_steal)
				
			if on_enter:
				on_enter.call()

func set_enemy_group():
	add_to_group("enemy")

func leave_enemy_group():
	remove_from_group("enemy")

func update_monitorable(new_monitorable: bool):
	monitorable = new_monitorable
	monitoring = new_monitorable
