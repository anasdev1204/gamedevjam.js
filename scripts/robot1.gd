class_name Robot1
extends Player

@onready var sword: MeshInstance3D = $Armature/Skeleton3D/righthand/Sword
@onready var sword_trail: MeshInstance3D = $VFX/SwordTrail
@onready var skills: SkillsContainer = $Armature/Skeleton3D/righthand/skills

func _ready():
	super._ready()

	skills.attack_started.connect(_on_attack_started)
	skills.completed_recovery.connect(_on_completed_recovery)

func enable():
	super.enable()
	
	sword.set_is_ally()


func disable(_init := true):
	super.disable()
	
	sword.set_is_enemy()
	
func _on_attack_started():
	_toggle_sword(true)
	_enable_trail()

func _on_completed_recovery():
	_toggle_sword(false)
	_disable_trail()

func _toggle_sword(state: bool):
	sword.visible = state
	
func _enable_trail():
	sword_trail.visible = true
	await get_tree().process_frame
	await get_tree().process_frame
	
func _disable_trail():
	sword_trail.visible = false
	sword_trail.points.clear()
	sword_trail.mesh = null
