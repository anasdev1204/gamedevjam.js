class_name ActiveSkill
extends Node

enum State {READY, WIND_UP, DELIVERING, RECOVERING}

@export_category("Animation")
@export var animation_name: StringName
@export var windup_duration: float
@export var windup_scale: float
@export var delivery_duration: float
@export var delivery_scale: float
@export var recovery_duration: float
@export var recovery_scale: float


@export_category("Movement")
@export var acceleration := 100.0
@export var passive_dash_delay := 0.1
@export var passive_dash_duration := 0.2
@export var passive_dash_velocity := Vector3(0, 0, 5)

@export_category("Camera")
@export var camera_fov := 70.0
