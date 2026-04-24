extends Node3D

@onready var button: Button = $Control/Button
@onready var robot_1_manager: Robot1Manager = %Robot1Manager

@onready var button_2: Button = $Control/Button2
@onready var drone_manager: Node = %DroneManager

@onready var button_3: Button = $Control/Button3
@onready var big_enemy_manager: BigEnemyManager = %BigEnemyManager

var active_player: Player

func _ready():
	button.connect("button_down", robot_1_manager.spawn.bind(false))
	button_2.connect("button_down", big_enemy_manager.spawn.bind(false))
	button_3.connect("button_down", drone_manager.spawn.bind(false))
