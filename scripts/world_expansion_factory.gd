extends RefCounted

static func mat(color: Color, alpha := 1.0, glow := 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color.r, color.g, color.b, alpha)
	material.roughness = 0.9
	if alpha < 0.999:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if glow > 0.0:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = glow
	return material

static func _static_box(root: Node3D, name: String, pos: Vector3, size: Vector3, color: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = name
	body.position = pos
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = mat(color)
	body.add_child(mesh_instance)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	root.add_child(body)
	return body

static func _sphere(root: Node3D, name: String, pos: Vector3, scale_v: Vector3, color: Color, glow := 0.0) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh_instance.mesh = mesh
	mesh_instance.position = pos
	mesh_instance.scale = scale_v
	mesh_instance.material_override = mat(color, 1.0, glow)
	root.add_child(mesh_instance)
	return mesh_instance

static func _cylinder(root: Node3D, name: String, pos: Vector3, scale_v: Vector3, color: Color, rotation := Vector3.ZERO, glow := 0.0) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.5
	mesh.bottom_radius = 0.5
	mesh.height = 1.0
	mesh_instance.mesh = mesh
	mesh_instance.position = pos
	mesh_instance.scale = scale_v
	mesh_instance.rotation = rotation
	mesh_instance.material_override = mat(color, 1.0, glow)
	root.add_child(mesh_instance)
	return mesh_instance

static func _landmark(root: Node3D, name: String, pos: Vector3, title: String, color: Color) -> Node3D:
	var marker := Node3D.new()
	marker.name = name
	marker.position = pos
	var core := _sphere(marker, "BeaconCore", Vector3.UP * 0.65, Vector3(0.55, 0.72, 0.55), color, 1.8)
	core.set_meta("pulse_phase", float(root.get_child_count()))
	var label := Label3D.new()
	label.text = title
	label.position = Vector3(0, 2.0, 0)
	label.font_size = 23
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = color
	marker.add_child(label)
	root.add_child(marker)
	return marker

static func build(parent: Node3D) -> Node3D:
	var root := Node3D.new()
	root.name = "ExpandedStomachWorld"
	parent.add_child(root)

	_static_box(root, "WestForeignBodyShelf", Vector3(-18.0, 0.02, 0.0), Vector3(8.5, 0.48, 12.5), Color("#963e68"))
	_static_box(root, "WestTissueBridge", Vector3(-13.9, 0.08, -0.6), Vector3(4.0, 0.34, 4.2), Color("#b95779"))
	_static_box(root, "EastPlateletShelf", Vector3(18.0, 0.04, 0.3), Vector3(8.5, 0.52, 12.0), Color("#8a3b65"))
	_static_box(root, "EastTissueBridge", Vector3(13.9, 0.10, 0.5), Vector3(4.0, 0.36, 4.0), Color("#a84a70"))
	_static_box(root, "NorthNerveShelf", Vector3(0.0, 0.10, -11.1), Vector3(16.0, 0.56, 5.2), Color("#6f315a"))
	_static_box(root, "NorthTissueBridge", Vector3(0.0, 0.12, -8.2), Vector3(5.0, 0.38, 3.5), Color("#873862"))

	_landmark(root, "ForeignBodyGraveyard", Vector3(-18.0, 0.34, -3.4), "FOREIGN BODY GRAVEYARD", Color("#ffb36d"))
	_landmark(root, "PlateletCheckpoint", Vector3(18.0, 0.38, 3.1), "PLATELET CHECKPOINT", Color("#ff8394"))
	_landmark(root, "NerveChoir", Vector3(0.0, 0.40, -11.2), "NERVE CHOIR", Color("#f6e866"))
	for i in range(20):
		var side := -1.0 if i < 10 else 1.0
		var local_i := i if i < 10 else i - 10
		var z := -6.0 + float(local_i) * 1.35
		var x := side * (20.5 + sin(float(local_i) * 1.7) * 0.7)
		_sphere(root, "OuterRugae%02d" % i, Vector3(x, 0.35, z), Vector3(2.6, 0.75, 1.25), Color("#a3476d"))

	for i in range(12):
		var x := -7.2 + float(i) * 1.3
		var y := 0.55 + sin(float(i) * 1.4) * 0.18
		_cylinder(root, "NerveString%02d" % i, Vector3(x, y, -11.0), Vector3(0.12, 1.15, 0.12), Color("#e4d952"), Vector3(0, 0, PI * 0.5), 1.3)
		_sphere(root, "NerveNode%02d" % i, Vector3(x, y + 0.15, -11.0), Vector3.ONE * 0.28, Color("#fff17a"), 1.7)

	for i in range(10):
		var z := -4.8 + float(i % 5) * 2.2
		var x := -19.2 + float(i / 5) * 2.5
		var color := Color("#68a8c7") if i % 2 == 0 else Color("#d76582")
		_static_box(root, "ForeignDebris%02d" % i, Vector3(x, 0.45, z), Vector3(0.9, 0.65, 1.35), color)
	for i in range(10):
		var z := -4.5 + float(i % 5) * 2.1
		var x := 16.7 + float(i / 5) * 2.4
		_cylinder(root, "PlateletBarrier%02d" % i, Vector3(x, 0.72, z), Vector3(0.25, 1.35, 0.25), Color("#e36270"), Vector3(PI * 0.5, 0, 0))
		_sphere(root, "PlateletLamp%02d" % i, Vector3(x, 1.25, z), Vector3.ONE * 0.22, Color("#ff9c88"), 1.1)

	for i in range(14):
		var angle := TAU * float(i) / 14.0
		var x := cos(angle) * 21.5
		var z := sin(angle) * 12.2
		_sphere(root, "PerimeterGland%02d" % i, Vector3(x, 0.2, z), Vector3(0.48, 0.32, 0.48), Color("#c6537b"))

	root.set_meta("region_count", 3)
	root.set_meta("visual_parts", root.get_child_count())
	return root

static func animate(root: Node3D, time: float) -> void:
	if not is_instance_valid(root):
		return
	for child in root.get_children():
		if child is MeshInstance3D and child.name.begins_with("NerveNode"):
			child.scale = Vector3.ONE * (0.26 + sin(time * 4.0 + float(child.get_index())) * 0.05)
	for marker_name in ["ForeignBodyGraveyard", "PlateletCheckpoint", "NerveChoir"]:
		var marker := root.get_node_or_null(marker_name) as Node3D
		if marker:
			var core := marker.get_node_or_null("BeaconCore") as MeshInstance3D
			if core:
				core.position.y = 0.65 + sin(time * 2.1 + float(marker.get_index())) * 0.12
