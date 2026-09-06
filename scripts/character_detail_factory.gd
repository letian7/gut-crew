extends RefCounted

static func clay(color: Color, alpha := 1.0, glow := 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color.r, color.g, color.b, alpha)
	material.roughness = 0.86
	material.metallic_specular = 0.34
	if alpha < 0.999:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if glow > 0.0:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = glow
	return material

static func sphere(root: Node3D, part_name: String, pos: Vector3, scale_v: Vector3, color: Color, alpha := 1.0, glow := 0.0) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	item.name = part_name
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	item.mesh = mesh
	item.position = pos
	item.scale = scale_v
	item.material_override = clay(color, alpha, glow)
	root.add_child(item)
	return item
static func box(root: Node3D, part_name: String, pos: Vector3, scale_v: Vector3, color: Color, rot_z := 0.0, alpha := 1.0, glow := 0.0) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	item.name = part_name
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE
	item.mesh = mesh
	item.position = pos
	item.scale = scale_v
	item.rotation.z = rot_z
	item.material_override = clay(color, alpha, glow)
	root.add_child(item)
	return item

static func torus(root: Node3D, part_name: String, pos: Vector3, scale_v: Vector3, color: Color, rot := Vector3.ZERO, alpha := 1.0) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	item.name = part_name
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.62
	mesh.outer_radius = 1.0
	item.mesh = mesh
	item.position = pos
	item.scale = scale_v
	item.rotation = rot
	item.material_override = clay(color, alpha)
	root.add_child(item)
	return item

static func build_details(root: Node3D, role: int) -> void:
	_add_face(root, role)
	_add_hands(root, role)
	_add_feet(root, role)
	_add_suit_seams(root, role)
	_add_role_signature(root, role)
	root.set_meta("model_version", 5)
	root.set_meta("v5_part_count", root.get_child_count())
static func _add_face(root: Node3D, role: int) -> void:
	var face_y: Array[float] = [1.58, 1.72, 1.58, 1.34]
	var face_z: Array[float] = [-0.535, -0.445, -0.475, -0.365]
	var eye_x: Array[float] = [0.24, 0.20, 0.20, 0.17]
	var colors: Array[Color] = [Color("#f3a33b"), Color("#e4d4bd"), Color("#baf4ff"), Color("#f0e7d4")]
	var dark := Color("#302a36")
	sphere(root, "ClayNose", Vector3(0.0, face_y[role] - 0.08, face_z[role]), Vector3(0.10, 0.075, 0.065), colors[role], 0.92)
	sphere(root, "LowerLip", Vector3(0.0, face_y[role] - 0.23, face_z[role] + 0.01), Vector3(0.13, 0.045, 0.035), dark, 0.70)
	for side in [-1.0, 1.0]:
		sphere(root, "EyeCatchlight", Vector3(eye_x[role] * side - 0.025, face_y[role] + 0.035, face_z[role] - 0.044), Vector3(0.025, 0.032, 0.018), Color.WHITE, 0.96, 0.12)
		var lid := box(root, "ClayEyelid", Vector3(eye_x[role] * side, face_y[role] + 0.105, face_z[role] - 0.016), Vector3(0.13, 0.025, 0.022), colors[role], -side * 0.05, 0.90)
		lid.set_meta("face_detail", true)
	for i in range(2):
		var print_ring := torus(root, "FaceThumbPrint", Vector3(-0.10 + float(i) * 0.20, face_y[role] - 0.36, face_z[role] + 0.025), Vector3.ONE * (0.045 + float(i) * 0.012), colors[role].darkened(0.16), Vector3(PI * 0.5, 0, 0), 0.18)
		print_ring.set_meta("clay_print", true)
static func _add_hands(root: Node3D, role: int) -> void:
	var hand_x: Array[float] = [0.67, 0.74, 0.64, 0.58]
	var hand_y: Array[float] = [0.48, 0.53, 0.61, 0.55]
	var colors: Array[Color] = [Color("#f39a32"), Color("#f2e8d4"), Color("#8ce8ff"), Color("#9ee8c8")]
	for side in [-1.0, 1.0]:
		var x: float = hand_x[role] * float(side)
		sphere(root, "Palm", Vector3(x, hand_y[role], -0.08), Vector3(0.19, 0.17, 0.16), colors[role], 0.92 if role != 2 else 0.58)
		for finger in range(3):
			var spread := (float(finger) - 1.0) * 0.075
			var finger_pos := Vector3(x + spread * side, hand_y[role] - 0.14, -0.16 + absf(spread) * 0.22)
			sphere(root, "Finger", finger_pos, Vector3(0.055, 0.105, 0.055), colors[role], 0.92 if role != 2 else 0.52)
		sphere(root, "Thumb", Vector3(x - side * 0.16, hand_y[role] - 0.02, -0.13), Vector3(0.07, 0.12, 0.065), colors[role], 0.92 if role != 2 else 0.52)

static func _add_feet(root: Node3D, role: int) -> void:
	var foot_x: Array[float] = [0.22, 0.28, 0.26, 0.24]
	var sole_y: Array[float] = [-0.035, -0.025, 0.095, 0.085]
	var darks: Array[Color] = [Color("#302b38"), Color("#44373f"), Color("#214151"), Color("#533a88")]
	for side in [-1.0, 1.0]:
		var x: float = foot_x[role] * float(side)
		sphere(root, "BootToe", Vector3(x, sole_y[role] + 0.08, -0.28), Vector3(0.25, 0.12, 0.25), darks[role], 0.90)
		box(root, "BootSole", Vector3(x, sole_y[role], -0.16), Vector3(0.27, 0.055, 0.34), darks[role].darkened(0.22))
		for tread in range(2):
			box(root, "SoleTread", Vector3(x + (float(tread) - 0.5) * 0.16, sole_y[role] - 0.035, -0.24), Vector3(0.045, 0.025, 0.20), Color("#201c27"))
static func _add_suit_seams(root: Node3D, role: int) -> void:
	var chest_y: Array[float] = [1.02, 1.08, 1.10, 0.93]
	var chest_z: Array[float] = [-0.57, -0.48, -0.70, -0.54]
	var colors: Array[Color] = [Color("#f39a32"), Color("#e98b39"), Color("#ff7aa8"), Color("#6a48a8")]
	for side in [-1.0, 1.0]:
		box(root, "ChestSeam", Vector3(0.30 * side, chest_y[role], chest_z[role]), Vector3(0.028, 0.31, 0.025), colors[role].lightened(0.12), side * 0.08, 0.82)
		sphere(root, "ElbowPad", Vector3((0.55 if role != 1 else 0.67) * side, 0.82, -0.10), Vector3(0.13, 0.10, 0.12), colors[role], 0.88)
	for i in range(3):
		sphere(root, "ClayDent", Vector3(-0.22 + float(i) * 0.22, chest_y[role] - 0.22, chest_z[role] + 0.025), Vector3(0.055, 0.028, 0.022), colors[role].darkened(0.20), 0.35)

static func _add_role_signature(root: Node3D, role: int) -> void:
	match role:
		0:
			box(root, "SparkChestBoltTop", Vector3(-0.04, 1.08, -0.63), Vector3(0.09, 0.24, 0.035), Color("#fff3a0"), -0.52, 1.0, 0.28)
			box(root, "SparkChestBoltBottom", Vector3(0.05, 0.92, -0.63), Vector3(0.09, 0.22, 0.035), Color("#fff3a0"), 0.52, 1.0, 0.28)
			for side in [-1.0, 1.0]:
				sphere(root, "SparkEarCoil", Vector3(0.66 * side, 1.66, -0.02), Vector3(0.16, 0.22, 0.16), Color("#f39a32"), 1.0, 0.20)
		1:
			for i in range(4):
				sphere(root, "KakaBackVertebra", Vector3(0.0, 0.72 + float(i) * 0.28, 0.48), Vector3(0.20, 0.12, 0.18), Color("#f2e8d4"))
			for side in [-1.0, 1.0]:
				box(root, "KakaForearmPlate", Vector3(0.70 * side, 0.73, -0.08), Vector3(0.18, 0.28, 0.16), Color("#e98b39"), side * 0.12)
		2:
			for i in range(5):
				var a := TAU * float(i) / 5.0
				sphere(root, "BubbleSuspendedCell", Vector3(cos(a) * 0.38, 0.96 + sin(a * 1.6) * 0.28, 0.26), Vector3.ONE * (0.055 + float(i % 2) * 0.018), Color("#fff2fb"), 0.42, 0.20)
			sphere(root, "BubbleSurfaceDrop", Vector3(0.48, 1.58, -0.24), Vector3(0.09, 0.18, 0.07), Color("#d9fbff"), 0.48, 0.15)
		3:
			for i in range(7):
				var a := TAU * float(i) / 7.0
				var gill := box(root, "ShroomRadialGill", Vector3(cos(a) * 0.58, 1.70, sin(a) * 0.48), Vector3(0.055, 0.028, 0.38), Color("#f0e7d4"), -a, 0.78)
				gill.rotation.y = -a
			sphere(root, "ShroomCapDripL", Vector3(-0.72, 1.74, -0.12), Vector3(0.12, 0.24, 0.10), Color("#a978f0"))
			sphere(root, "ShroomCapDripR", Vector3(0.68, 1.72, 0.06), Vector3(0.11, 0.21, 0.10), Color("#a978f0"))

# GODOT_CHARACTER_DETAIL_V5
