class_name IronBodyAugment
extends Augment

func _ready():
	augment_name = "Iron Body"
	description = "Take less damage."
	augment_type = AUGMENT_TYPE.SURVIVAL

func _on_enabled():
	Global.flat_damage_reduction += 3

func _on_disabled():
	Global.flat_damage_reduction = 0
