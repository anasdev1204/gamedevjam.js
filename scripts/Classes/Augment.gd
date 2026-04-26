class_name Augment
extends Node

enum AUGMENT_TYPE {BUFF, SURVIVAL, MISC, DOUBLE_OR_NOTHING}

@export var icon: Texture2D
@export var augment_name: String
@export var description: String
@export var augment_type: AUGMENT_TYPE


var is_active: bool = false

func enable() -> void:
	if is_active:
		return

	is_active = true
	_on_enabled()

func disable() -> void:
	if not is_active:
		return

	is_active = false
	_on_disabled()
	
func _on_enabled() -> void:
	pass

func _on_disabled() -> void:
	pass
