class_name TeleportationAugment
extends Augment

func _ready():
	augment_name = "Berserker"
	description = "Lose 50% HP, dash cooldown 100% shorter."
	augment_type = AUGMENT_TYPE.BUFF

func _on_enabled():
	Global.hp_mult *= 0.5
	Global.dash_cd_mult *= 0.5

func _on_disabled():
	Global.hp_mult = 1
	Global.dash_cd_mult = 1.
