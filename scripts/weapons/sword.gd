extends MeshInstance3D

@onready var hitbox: Hitbox = $Hitbox

func set_is_enemy():
	hitbox.set_enemy_group()
	
func set_is_ally():
	hitbox.leave_enemy_group()

func set_monitorable(monitorable: bool):
	hitbox.update_monitorable(monitorable)
