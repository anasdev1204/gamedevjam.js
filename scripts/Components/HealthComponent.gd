class_name HealthComponent
extends Node

signal die

@export var model: MeshInstance3D
@export var max_health := 100.0
@export var hurtbox: Hurtbox
@export var hit_cooldown := 0.1
@export var hit_flash_frames := 20

var current_health: float
var hit_memory := {}

func _ready():
	current_health = max_health
	hurtbox.area_entered.connect(_hurtbox_entered)
	hurtbox.area_overlap.connect(_hurtbox_entered)

func _hurtbox_entered(hitbox: Area3D):
	if not is_instance_of(hitbox, Hitbox):
		return
	
	print(get_parent().is_controlled, hitbox.is_in_group("enemy"))
	
	if (
		(get_parent().is_controlled and hitbox.is_in_group("enemy"))
		or
		(not get_parent().is_controlled and not hitbox.is_in_group("enemy"))
	):
		var now := Time.get_ticks_msec()
		if hit_memory.has(hitbox) and hit_memory[hitbox] > now:
			return
			
		hit_memory[hitbox] = now + int(hit_cooldown * 1000)
		_hit(hitbox.damage)
	
func _hit(damage: float):
	current_health -= damage
	
	if current_health <= 0:
		die.emit()
	else:
		_hit_flash_shader(true)
		_reset_hit_flash()

		
func _heal(healed_hp: float):
	current_health += healed_hp
	
func _reset_hit_flash() -> void:
	for i in hit_flash_frames:
		await get_tree().process_frame
	
	_hit_flash_shader(false)
	
func _hit_flash_shader(is_hit: bool):
	print("got hit")
	var mat := model.get_active_material(0) as ShaderMaterial
	mat.set_shader_parameter("is_hit", is_hit)
	
func display_health():
	pass
