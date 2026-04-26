class_name RandomAugment
extends Augment

@export var augments: Array[Augment]

func _ready():
	augment_name = "Chaos"
	description = "Gain a random augment."
	augment_type = AUGMENT_TYPE.MISC

func _on_enabled():
	var chosen = augments.pick_random()
	chosen.enable()
