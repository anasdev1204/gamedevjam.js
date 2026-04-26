class_name HealthComponent
extends Node

signal die
signal hp_change

@export var movement_component: MovementComponent
@export var enemy_health_bar_subview: SubViewport
@export var enemy_health_bar_sprite: Sprite3D
@export var enemy_health_bar_appear_duration := 1.

@export var model: MeshInstance3D
@export var max_health := 100.0
@export var hurtbox: Hurtbox
@export var hit_cooldown := 0.1

@export var invincibility_duration := 0.5

var current_health: float
var died := false

var invincibility_timer: Timer

var progress_bar: ProgressBar
var enemy_health_bar_apppear_timer: Timer

func _ready():
	current_health = max_health
	hurtbox.hit.connect(_hit)
	
	enemy_health_bar_apppear_timer = Timer.new()
	enemy_health_bar_apppear_timer.one_shot = true
	enemy_health_bar_apppear_timer.timeout.connect(hide_health)
	add_child(enemy_health_bar_apppear_timer)
	
	invincibility_timer = Timer.new()
	invincibility_timer.one_shot = true
	invincibility_timer.timeout.connect(_reset_invicibility)
	add_child(invincibility_timer)

	progress_bar = enemy_health_bar_subview.get_node("Panel/ProgressBar")
	
func _hit(damage: float, attack_global_position: Vector3, knockback_value: float):
	if get_parent().is_controlled and _is_invincible():
		return
		
	current_health -= damage
	hp_change.emit(current_health)
	
	if current_health <= 0:
		if not died:
			die.emit()
			died = true
	else:
		_hit_flash_shader(true)
		start_invincibility_timer(invincibility_duration)
		display_health()
		movement_component.knock_back(attack_global_position, knockback_value)

func start_invincibility_timer(duration: float):
	invincibility_timer.start(duration)

func _is_invincible():
	return invincibility_timer.time_left > 0.

func _reset_invicibility():
	_hit_flash_shader(false)

func _heal(healed_hp: float):
	current_health += healed_hp
	hp_change.emit(current_health)
	
func _hit_flash_shader(is_hit: bool):
	var mat := model.get_active_material(0) as ShaderMaterial
	mat.set_shader_parameter("is_hit", is_hit)
	
func reset_health(new_max_health := 100):
	max_health = new_max_health
	current_health = new_max_health
	enemy_health_bar_sprite.visible = false
	died = false
	hp_change.emit(current_health)
	
func display_health():
	if not get_parent().is_controlled:
		enemy_health_bar_sprite.visible = true
		create_tween().tween_property(
			progress_bar,
			"value",
			current_health,
			0.3
		)
		
		enemy_health_bar_apppear_timer.start()

func hide_health():
	if not get_parent().is_controlled:
		enemy_health_bar_sprite.visible = false
