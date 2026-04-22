extends Node3D
class_name SkillsContainer

signal attack_started
signal completed_recovery

@export var active_skills : Array[ActiveSkill]
@export var max_combo := 3
@export var combo_reset_duration := 1.

var current_attack_id : int = 0
@onready var current_active_skill : ActiveSkill = active_skills[current_attack_id]

var anim_tree : AnimationTree
var attack_transition_node : AnimationNodeTransition
var attack_anim_node : AnimationNodeAnimation
var attack_buffer : AnimationNodeBlendTree
var attack_buffer_id : int = 0

var windup_timer : Timer = Timer.new()
var delivery_timer : Timer = Timer.new()
var recovery_timer : Timer = Timer.new()
var end_timer : Timer = Timer.new()
var combo_reset_timer: Timer = Timer.new()

var attack_state : ActiveSkill.State = ActiveSkill.State.READY


func _ready():
	windup_timer.timeout.connect(_on_windup_timer_timeout)
	delivery_timer.timeout.connect(_on_delivery_timer_timeout)
	recovery_timer.timeout.connect(_on_recovery_timer_timeout)
	end_timer.timeout.connect(_on_end_timer_timeout)
	combo_reset_timer.timeout.connect(_on_combo_reset_timeout)
	windup_timer.one_shot = true
	delivery_timer.one_shot = true
	recovery_timer.one_shot = true
	end_timer.one_shot = true
	combo_reset_timer.one_shot = true
	add_child(windup_timer)
	add_child(delivery_timer)
	add_child(recovery_timer)
	add_child(end_timer)
	add_child(combo_reset_timer)


func set_anim_tree(_anim_tree : AnimationTree):
	anim_tree = _anim_tree
	attack_transition_node = anim_tree.tree_root.get("nodes/attack_transition/node")

func switch_attack_buffer(attack_anim_name : StringName):
	attack_buffer_id = 1 - attack_buffer_id
	attack_buffer = anim_tree.tree_root.get("nodes/attack_buffer_" + str(attack_buffer_id) + "/node")
	attack_anim_node = attack_buffer.get_node("Animation")
	attack_anim_node.animation = attack_anim_name


func set_attack_buffer_timescale(value : float):
	anim_tree["parameters/attack_buffer_" + str(attack_buffer_id) + "/TimeScale/scale"] = value


func set_attack_transition(value : String):
	anim_tree["parameters/attack_transition/transition_request"] = value


func get_current_skill() -> ActiveSkill:
	return active_skills[current_attack_id]

func start_attack():
	windup_timer.stop()
	delivery_timer.stop()
	recovery_timer.stop()
	end_timer.stop()
	combo_reset_timer.stop()
	
	current_active_skill = active_skills[current_attack_id]
	switch_attack_buffer(current_active_skill.animation_name)
	
	current_attack_id += 1
	current_attack_id %= max_combo
	
	attack_started.emit()
	windup()


func windup():
	attack_state = ActiveSkill.State.WIND_UP
	attack_transition_node.xfade_time = current_active_skill.windup_duration
	set_attack_transition("attack_buffer_" + str(attack_buffer_id))
	set_attack_buffer_timescale(current_active_skill.windup_scale)
	windup_timer.start(current_active_skill.windup_duration)

func _on_windup_timer_timeout():
	deliver()

func deliver():
	attack_state = ActiveSkill.State.DELIVERING
	set_attack_buffer_timescale(current_active_skill.delivery_scale)
	delivery_timer.start(current_active_skill.delivery_duration)

func _on_delivery_timer_timeout():
	recover()

func recover():
	attack_state = ActiveSkill.State.RECOVERING
	set_attack_buffer_timescale(current_active_skill.recovery_scale)
	recovery_timer.start(current_active_skill.recovery_duration)

func _on_recovery_timer_timeout():
	attack_state = ActiveSkill.State.READY	
	end_timer.start(0.05)

func _on_end_timer_timeout():
	set_attack_transition("end_attack")
	completed_recovery.emit()

func _on_combo_reset_timeout():
	current_attack_id = 0
