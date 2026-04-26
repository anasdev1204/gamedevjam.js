class_name LifestealAugment
extends Augment

func _ready():
	augment_name = "Blood Pact"
	description = "Heal when attacking."
	augment_type = AUGMENT_TYPE.SURVIVAL

func _on_enabled():
	Global.life_steal += 0.10

func _on_disabled():
	Global.life_steal = 0
