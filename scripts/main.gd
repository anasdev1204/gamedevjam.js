extends Node3D

@onready var robot_1_manager: Robot1Manager = $Robot1Manager
@onready var drone_manager: DroneManager = %DroneManager
@onready var big_enemy_manager: BigEnemyManager = %BigEnemyManager

@onready var hp_bar: ProgressBar = %HPbar
@onready var dash_icon: TextureRect = %dash_icon
@onready var switch_icon: TextureRect = %switch_icon
@onready var wave_counter: Label = %wave_counter
@onready var enemies_counter: Label = %enemies_counter

@onready var dash_available_icon = preload("res://assets/source/HUD/dash_available.png")
@onready var dash_not_available_icon = preload("res://assets/source/HUD/dash_not_available.png")
@onready var switch_available_icon = preload("res://assets/source/HUD/switch_available.png")
@onready var switch_not_available_icon = preload("res://assets/source/HUD/switch_not_available.png")

@onready var start_menu: CanvasLayer = %Start
@onready var hud: CanvasLayer = %HUD
@onready var pause_menu: CanvasLayer = $Paused
@onready var resume_button: Button = %ResumeButton
@onready var end_menu: CanvasLayer = %End
@onready var play_button: Button = $Start/Control/PlayButton
@onready var play_again_button: Button = $End/Control/PlayAgain

var current_wave := 0
var active_player: Player
var remaining_enemies := 0
var spawn_session := 0

func _ready():
	get_tree().paused = true
	hud.visible = false
	pause_menu.visible = false
	end_menu.visible = false
	
	play_button.pressed.connect(_start_game)
	resume_button.pressed.connect(_on_resume_pressed)
	play_again_button.pressed.connect(_on_play_again_pressed)

func _start_game():
	get_tree().paused = false
	hud.visible = true
	start_menu.visible = false
	end_menu.visible = false
	
	active_player = robot_1_manager.init_spawn()
	await get_tree().process_frame
	bind_signals()
	
func _end_game():
	get_tree().paused = true
	end_menu.visible = true

func _process(_delta):
	_update_remaining_enemies()
	enemies_counter.text = str(remaining_enemies) + " remaining enemies"
	if remaining_enemies <= 0:
		current_wave += 1
		spawn_session += 1
		var wave_data := _generate_wave()
		_spawn_wave(
			wave_data.robot_1,
			wave_data.big_enemy,
			wave_data.drone
		)
		
func _update_remaining_enemies():
	remaining_enemies = 0

	for child in get_children():
		if child is Player:
			remaining_enemies += 1

	remaining_enemies = max(remaining_enemies - 1, 0)

func _purge_entities():
	for child in get_children():
		if child is Player:
			child.queue_free()

func _generate_wave() -> Dictionary:
	return {
		"robot_1": 3 + current_wave,
		"big_enemy": int(current_wave / 2),
		"drone": 2 + int(current_wave / 2)
	}

func _reset_wave():
	current_wave = 0
	Global.wave_multiplier = 1
	remaining_enemies = 0
	spawn_session = 0

func _spawn_wave(r1_n: int, be_n: int, dr_n: int):
	wave_counter.text = "Wave " + str(current_wave)
	Global.wave_multiplier *= 1.1
	if r1_n != 0:
		robot_1_manager.spawn(false, r1_n, spawn_session)
	if be_n != 0:
		big_enemy_manager.spawn(false, be_n, spawn_session)
	if dr_n != 0:
		drone_manager.spawn(false, dr_n, spawn_session)
	remaining_enemies += r1_n + be_n + dr_n

func _unhandled_input(event):
	if event.is_action_pressed("menu"):
		_toggle_pause()
		
func _toggle_pause():
	get_tree().paused = !get_tree().paused
	pause_menu.visible = get_tree().paused
	
func _on_resume_pressed():
	get_tree().paused = false
	pause_menu.visible = false

func _on_play_again_pressed():
	_reset_wave()
	_purge_entities()
	_start_game()

func bind_signals():
	active_player.health_component.hp_change.connect(
		_on_active_player_hp_change
	)
	
	active_player.health_component.die.connect(
		_end_game
	)
	
	active_player.movement_component.dash_used.connect(
		_on_dash_used
	)
	active_player.movement_component.dash_ready.connect(
		_on_dash_ready
	)
	
	active_player.switched.connect(
		_on_switch_used
	)
	active_player.switch_ready.connect(
		_on_switch_ready
	)
	
func unbind_signals():
	if active_player.health_component.hp_change.is_connected(_on_active_player_hp_change):
		active_player.health_component.hp_change.disconnect(_on_active_player_hp_change)
	
	if 	active_player.health_component.die.is_connected(_end_game):
		active_player.health_component.die.disconnect(_end_game)
	
	if active_player.movement_component.dash_used.is_connected(_on_dash_used):
		active_player.movement_component.dash_used.disconnect(_on_dash_used)
		
	if active_player.movement_component.dash_ready.is_connected(_on_dash_ready):
		active_player.movement_component.dash_ready.disconnect(_on_dash_ready)

	if active_player.switched.is_connected(_on_switch_used):
		active_player.switched.disconnect(_on_switch_used)
		
	if active_player.switch_ready.is_connected(_on_switch_ready):
		active_player.switch_ready.disconnect(_on_switch_ready)
	
func set_active_player(player: Player):
	unbind_signals()
	active_player = player
	bind_signals()
	active_player.health_component.reset_health()
	active_player.switched.emit()
	active_player.start_switch_cooldown()
	
func _on_active_player_hp_change(current_health):
	create_tween().tween_property(
		hp_bar,
		"value",
		current_health,
		0.3
	)
	
func _on_dash_used():
	_swap_dash_icon(dash_not_available_icon)
	
func _on_dash_ready():
	_swap_dash_icon(dash_available_icon)
	
func _on_switch_used():
	_swap_switch_icon(switch_not_available_icon)
	
func _on_switch_ready():
	_swap_switch_icon(switch_available_icon)
	
func _swap_dash_icon(new_texture: Texture2D):
	var tween := create_tween()

	tween.parallel().tween_property(dash_icon, "modulate:a", 0.0, 0.1)
	tween.parallel().tween_property(dash_icon, "scale", Vector2(0.9, 0.9), 0.1)

	tween.tween_callback(func():
		dash_icon.texture = new_texture
	)

	tween.parallel().tween_property(dash_icon, "modulate:a", 1.0, 0.12)
	tween.parallel().tween_property(dash_icon, "scale", Vector2.ONE, 0.12)
	
func _swap_switch_icon(new_texture: Texture2D):
	var tween := create_tween()

	tween.parallel().tween_property(switch_icon, "modulate:a", 0.0, 0.1)
	tween.parallel().tween_property(switch_icon, "scale", Vector2(0.9, 0.9), 0.1)

	tween.tween_callback(func():
		switch_icon.texture = new_texture
	)

	tween.parallel().tween_property(switch_icon, "modulate:a", 1.0, 0.12)
	tween.parallel().tween_property(switch_icon, "scale", Vector2.ONE, 0.12)
