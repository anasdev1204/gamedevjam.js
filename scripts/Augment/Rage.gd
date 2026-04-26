# SharedBuffAugment.gd
class_name SharedBuffAugment
extends Augment

func _ready():
	augment_name = "Mutual Rage"
	description = "You gain a 100% dmg, enemies gain 50% dmg."
	augment_type = AUGMENT_TYPE.DOUBLE_OR_NOTHING

func _on_enabled():
	Global.dmg_mult *= 2.
	Global.enemy_dmg_mult *= 1.5

func _on_disabled():
	Global.dmg_mult = 1.
	Global.enemy_dmg_mult = 1.
	
