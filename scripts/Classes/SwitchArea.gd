class_name SwitchArea
extends Area3D

@export var active := false

var entities = {}

func _ready():
	area_entered.connect(on_area_entered)
	area_exited.connect(on_area_exited)

func _physics_process(_delta: float) -> void:
	check_radius()

func check_radius():
	if not active:
		return
		
	for e in entities:
		var parent: Player = e.get_parent()
		var is_exploding: bool = parent.is_exploding
		entities[e] = is_exploding
		
		if is_exploding:
			parent.get_node("SwitchIndicator").visible = true
			
func get_closest_exploding_in_range(mouse_position: Vector3) -> Player:
	var closest: Player = null
	var best_dist := INF

	for entity in entities.keys():
		if entities[entity] != true:
			continue

		var player: Player = entity.get_parent()

		if player == null or not (player is Player):
			continue

		var dist := player.global_position.distance_to(mouse_position)

		if dist < best_dist:
			best_dist = dist
			closest = player

	return closest
			
func is_exploding_in_range() -> bool:
	for value in entities.values():
		if value:
			return true
	return false

func on_area_entered(area: Area3D):
	if not active:
		return
	
	var area_parent := area.get_parent()
	if area_parent.is_controlled:
		return
		
	entities[area] = area_parent.is_exploding

func on_area_exited(area: Area3D):
	if not active:
		return
	entities.erase(area)
