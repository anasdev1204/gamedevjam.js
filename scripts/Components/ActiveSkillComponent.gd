class_name ActiveSkillComponent
extends Node

@export var player: Player
@export var anim_tree: AnimationTree
@export var skills_container: SkillsContainer
@export var movement_component: MovementComponent
@export var camera_component: CameraComponent

func _ready():
	skills_container.set_anim_tree(anim_tree)
	skills_container.completed_recovery.connect(
		player.set_player_attacking.bind(false)
	)

func _on_primary_fire():
	if is_skill_active():
		return
	
	player.set_player_attacking(true)
	
	var current_skill: ActiveSkill = skills_container.get_current_skill()
	movement_component.passive_dash_acceleration = current_skill.acceleration
	movement_component.passive_dash(
		current_skill.passive_dash_velocity, 
		current_skill.passive_dash_duration,
		current_skill.passive_dash_delay
	)
	
	skills_container.start_attack()


func is_skill_active() -> bool:
	return skills_container.attack_state != ActiveSkill.State.READY
