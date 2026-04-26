class_name GhostAugment
extends Augment

func _ready():
	augment_name = "Ghost Skin"
	description = "Longer invincibility after taking damage."
	augment_type = AUGMENT_TYPE.SURVIVAL

func _on_enabled():
	Global.invincible_duration_offset += 0.1

func _on_disabled():
	Global.invincible_duration_offset = 0
