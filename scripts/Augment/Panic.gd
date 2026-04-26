class_name PanicModeAugment
extends Augment

func _ready():
	augment_name = "Panic Mode"
	description = "Enemies move faster, switch cooldown reduced."
	augment_type = AUGMENT_TYPE.DOUBLE_OR_NOTHING

func _on_enabled():
	Global.switch_cooldown_mult *= 0.5
	Global.enemy_speed_mult *= 1.5
	
func _on_disabled():
	Global.switch_cooldown_mult = 1.
	Global.enemy_speed_mult = 1.
