class_name BerserkerAugment
extends Augment

func _ready():
	augment_name = "Berserker"
	description = "Lose 50% HP, deal 100% more damage"
	augment_type = AUGMENT_TYPE.BUFF

func _on_enabled():
	Global.hp_mult *= 0.5
	Global.dmg_mult *= 2.

func _on_disabled():
	Global.hp_mult = 1
	Global.dmg_mult = 1.
