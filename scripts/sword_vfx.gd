extends MeshInstance3D

@export var base_point: Node3D
@export var tip_point: Node3D
@export var max_segments := 25

var points: Array = []

func _process(_delta):
	if base_point == null or tip_point == null:
		return

	var b = base_point.global_position
	var t = tip_point.global_position

	points.append({
		"base": b,
		"tip": t
	})

	if points.size() > max_segments:
		points.pop_front()

	build_mesh()
	
func get_smoothed_points() -> Array:
	var smoothed = []
	for i in range(points.size()):
		var base_avg = Vector3.ZERO
		var tip_avg = Vector3.ZERO
		var count = 0
		for j in range(max(0, i - 2), min(points.size(), i + 3)):
			base_avg += points[j].base
			tip_avg += points[j].tip
			count += 1
		smoothed.append({ "base": base_avg / count, "tip": tip_avg / count })
	return smoothed

func build_mesh():
	if points.size() < 2:
		mesh = null
		return

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var smoothed_points = get_smoothed_points()
	
	for i in range(smoothed_points.size() - 1):
		var p0 = smoothed_points[i]
		var p1 = smoothed_points[i + 1]

		var alpha0 = 1.0 - float(i) / float(points.size() - 1)
		var alpha1 = 1.0 - float(i + 1) / float(points.size() - 1)

		var v0 = float(i) / float(smoothed_points.size() - 1)
		var v1 = float(i + 1) / float(smoothed_points.size() - 1)

		var c0 = Color(1, 1, 1, 1.0 - alpha0)
		var c1 = Color(1, 1, 1, 1.0 - alpha1)

		# Triangle 1
		st.set_color(c0)
		st.set_uv(Vector2(0.0, v0))
		st.add_vertex(to_local(p0.base))

		st.set_color(c0)
		st.set_uv(Vector2(1.0, v0))
		st.add_vertex(to_local(p0.tip))

		st.set_color(c1)
		st.set_uv(Vector2(1.0, v1))
		st.add_vertex(to_local(p1.tip))

		# Triangle 2
		st.set_color(c0)
		st.set_uv(Vector2(0.0, v0))
		st.add_vertex(to_local(p0.base))

		st.set_color(c1)
		st.set_uv(Vector2(1.0, v1))
		st.add_vertex(to_local(p1.tip))

		st.set_color(c1)
		st.set_uv(Vector2(0.0, v1))
		st.add_vertex(to_local(p1.base))

	st.generate_normals()
	mesh = st.commit()
