extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	animation_player.play("open")
	await get_tree().process_frame
	animation_player.seek(0.08, true)
	animation_player.pause()

func open(callable: Callable):
	if animation_player.is_playing():
		return
		
	animation_player.play("open")
	animation_player.animation_finished.connect(callable, CONNECT_ONE_SHOT)

func close():
	if animation_player.is_playing():
		return
	animation_player.play("close")
