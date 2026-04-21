extends Node3D

@export var spawn_interval: float = 0.04
@export var ghost_lifetime: float = 0.1
@export var ghost_color: Color = Color(0.4, 0.7, 1.0, 0.6)

var _timer: float = 0.0
var _is_active: bool = false

@onready var character_mesh: MeshInstance3D = $"../../Armature/Skeleton3D/model"
@onready var skeleton: Skeleton3D = $"../../Armature/Skeleton3D"


func _ready() -> void:
	print("Mesh found: ", character_mesh)
	print("Skeleton found: ", skeleton)
	print("Surface count: ", character_mesh.mesh.get_surface_count())

func start() -> void:
	_is_active = true

func stop() -> void:
	_is_active = false

func _process(delta: float) -> void:
	if not _is_active:
		return

	_timer -= delta
	if _timer <= 0.0:
		_timer = spawn_interval
		_spawn_ghost()
#
#func _spawn_ghost() -> void:
	#var source_mesh := character_mesh.mesh
#
	##var skel_xform := skeleton.global_transform
	##var mesh_xform := character_mesh.global_transform
##
	#var bone_transforms: Array[Transform3D] = []
	##for i in skeleton.get_bone_count():
		##var bone_global := skel_xform * skeleton.get_bone_global_pose(i)
		##var rest_global := skel_xform * skeleton.get_bone_rest(i)
		##bone_transforms.append(
			##mesh_xform.affine_inverse() * bone_global * rest_global.affine_inverse()
		##)
		#
	#for i in skeleton.get_bone_count():
		#bone_transforms.append(
			#skeleton.get_bone_global_pose(i) * skeleton.get_bone_rest(i).affine_inverse()
		#)
		#
	#var arrays = source_mesh.surface_get_arrays(0)
#
	## Apply current skeleton pose to vertex positions
	#var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	#var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	#var bones_raw = arrays[Mesh.ARRAY_BONES]
	#var weights_raw = arrays[Mesh.ARRAY_WEIGHTS]
	#var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	#var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	#
	#var influences: int = bones_raw.size() / verts.size()
#
	#var new_verts := PackedVector3Array()
	#new_verts.resize(verts.size())
	#var new_normals := PackedVector3Array()
	#new_normals.resize(normals.size())
		#
	#for i in verts.size():
		#var final_pos := Vector3.ZERO
		#var final_normal := Vector3.ZERO
#
		#for j in influences:
			#var idx: int = i * influences + j
			#var bone_idx: int = bones_raw[idx]
			#var weight: float = weights_raw[idx]
			#
			#if weight == 0.0:
				#continue
#
			#var xform := bone_transforms[bone_idx]
			#final_pos += xform * verts[i] * weight
			#final_normal += xform.basis * normals[i] * weight
			#
		#new_verts[i] = final_pos
		#new_normals[i] = final_normal.normalized()
#
	#var st := SurfaceTool.new()
	#st.begin(Mesh.PRIMITIVE_TRIANGLES)
#
	#for i in indices.size():
		#var v := indices[i]
		#st.set_normal(new_normals[v])
		#if uvs.size() > 0:
			#st.set_uv(uvs[v])
			#st.add_vertex(new_verts[v])
#
	#var baked_mesh := st.commit()
	## Spawn ghost
	#var ghost := MeshInstance3D.new()
	#ghost.mesh = baked_mesh
	#ghost.global_transform = skeleton.global_transform
#
	#var mat := StandardMaterial3D.new()
	#mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	#mat.albedo_color = ghost_color
	#mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	#mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	#ghost.material_override = mat
#
	#get_tree().current_scene.add_child(ghost)
#
	#var tween := get_tree().create_tween()
	#tween.tween_property(mat, "albedo_color:a", 0.0, ghost_lifetime)
	#tween.tween_callback(ghost.queue_free)

func _spawn_ghost():
	var ghost := MeshInstance3D.new()
	ghost.mesh = character_mesh.mesh 

	ghost.global_transform = character_mesh.global_transform

	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = ghost_color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED  # flat ghost look
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	ghost.material_override = mat

	get_tree().current_scene.add_child(ghost)

	var tween := get_tree().create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.0, ghost_lifetime)
	tween.tween_callback(ghost.queue_free)
