extends RefCounted

static func clay(color: Color, alpha: float = 1.0, glow: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(color.r, color.g, color.b, alpha)
	mat.roughness = 0.93
	if alpha < 0.999:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if glow > 0.0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = glow
	return mat

static func _sphere(root: Node3D, part_name: String, pos: Vector3, scale_v: Vector3, color: Color, alpha: float = 1.0, glow: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = part_name
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mi.mesh = mesh
	mi.position = pos
	mi.scale = scale_v
	mi.material_override = clay(color, alpha, glow)
	root.add_child(mi)
	return mi

static func _box(root: Node3D, part_name: String, pos: Vector3, size_v: Vector3, color: Color, alpha: float = 1.0, glow: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = part_name
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE
	mi.mesh = mesh
	mi.position = pos
	mi.scale = size_v
	mi.material_override = clay(color, alpha, glow)
	root.add_child(mi)
	return mi

static func _cylinder(root: Node3D, part_name: String, pos: Vector3, scale_v: Vector3, color: Color, rot: Vector3 = Vector3.ZERO, alpha: float = 1.0, glow: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = part_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.5
	mesh.bottom_radius = 0.5
	mesh.height = 1.0
	mi.mesh = mesh
	mi.position = pos
	mi.rotation = rot
	mi.scale = scale_v
	mi.material_override = clay(color, alpha, glow)
	root.add_child(mi)
	return mi

static func build_role(root: Node3D, role: int) -> Dictionary:
	for child in root.get_children():
		child.queue_free()
	var result: Dictionary = {}
	match role:
		0: result = _build_spark(root)
		1: result = _build_kaka(root)
		2: result = _build_bubble(root)
		3: result = _build_shroom(root)
	return result

static func _eyes(root: Node3D, y: float, x_gap: float, z: float, scale_v: Vector3 = Vector3(0.15, 0.19, 0.09)) -> void:
	var white := Color("#fff8de")
	var dark := Color("#2d2633")
	for sx in [-1.0, 1.0]:
		_sphere(root, "EyeWhite", Vector3(x_gap * sx, y, z), scale_v, white)
		_sphere(root, "Pupil", Vector3(x_gap * sx, y, z - 0.055), scale_v * Vector3(0.42, 0.56, 0.45), dark)

static func _limb(root: Node3D, part_name: String, pos: Vector3, scale_v: Vector3, color: Color, rot_z: float = 0.0) -> MeshInstance3D:
	return _cylinder(root, part_name, pos, scale_v, color, Vector3(0.0, 0.0, rot_z))

static func _build_spark(root: Node3D) -> Dictionary:
	var yellow := Color("#ffd83f")
	var orange := Color("#f39a32")
	var dark := Color("#40343f")
	var metal := Color("#d9e3d7")
	var body := _sphere(root, "SparkBody", Vector3(0, 0.78, 0), Vector3(0.72, 0.88, 0.62), yellow)
	var head := _sphere(root, "SparkHead", Vector3(0, 1.58, -0.02), Vector3(1.18, 1.04, 1.02), yellow)
	_eyes(root, 1.64, 0.24, -0.49, Vector3(0.16, 0.21, 0.09))
	_box(root, "SparkMouth", Vector3(0, 1.37, -0.52), Vector3(0.22, 0.055, 0.055), dark)
	_box(root, "SparkBelt", Vector3(0, 0.75, -0.39), Vector3(0.72, 0.12, 0.08), orange)
	_limb(root, "SparkArmL", Vector3(-0.52, 0.82, 0), Vector3(0.18, 0.55, 0.18), yellow, -0.28)
	_limb(root, "SparkArmR", Vector3(0.52, 0.82, 0), Vector3(0.18, 0.55, 0.18), yellow, 0.28)
	_limb(root, "SparkLegL", Vector3(-0.22, 0.24, 0), Vector3(0.19, 0.48, 0.19), dark)
	_limb(root, "SparkLegR", Vector3(0.22, 0.24, 0), Vector3(0.19, 0.48, 0.19), dark)
	_cylinder(root, "SparkProngL", Vector3(-0.22, 2.34, 0), Vector3(0.10, 0.52, 0.10), metal)
	_cylinder(root, "SparkProngR", Vector3(0.22, 2.34, 0), Vector3(0.10, 0.52, 0.10), metal)
	_sphere(root, "SparkCoil", Vector3(0, 2.03, 0), Vector3(0.42, 0.16, 0.42), orange, 1.0, 0.6)
	return {"body": body, "head": head}

static func _build_kaka(root: Node3D) -> Dictionary:
	var bone := Color("#f2e8d4")
	var orange := Color("#e98b39")
	var dark := Color("#54454a")
	var body := _box(root, "KakaBody", Vector3(0, 0.88, 0), Vector3(0.95, 1.02, 0.58), bone)
	var head := _box(root, "KakaHead", Vector3(0, 1.72, -0.02), Vector3(0.82, 0.72, 0.68), bone)
	_eyes(root, 1.78, 0.20, -0.39, Vector3(0.13, 0.17, 0.08))
	for i in range(3):
		_box(root, "KakaRib", Vector3(0, 1.04 - i * 0.18, -0.34), Vector3(0.70 - i * 0.06, 0.075, 0.09), orange)
	_box(root, "KakaBelt", Vector3(0, 0.52, -0.36), Vector3(0.88, 0.14, 0.10), orange)
	_box(root, "KakaToolL", Vector3(-0.58, 0.58, -0.12), Vector3(0.22, 0.34, 0.22), orange)
	_box(root, "KakaToolR", Vector3(0.58, 0.58, -0.12), Vector3(0.22, 0.34, 0.22), orange)
	_limb(root, "KakaArmL", Vector3(-0.66, 0.95, 0), Vector3(0.16, 0.70, 0.16), bone, -0.14)
	_limb(root, "KakaArmR", Vector3(0.66, 0.95, 0), Vector3(0.16, 0.70, 0.16), bone, 0.14)
	_limb(root, "KakaLegL", Vector3(-0.28, 0.25, 0), Vector3(0.18, 0.50, 0.18), bone)
	_limb(root, "KakaLegR", Vector3(0.28, 0.25, 0), Vector3(0.18, 0.50, 0.18), bone)
	_box(root, "KakaBootL", Vector3(-0.28, 0.06, -0.10), Vector3(0.28, 0.16, 0.42), dark)
	_box(root, "KakaBootR", Vector3(0.28, 0.06, -0.10), Vector3(0.28, 0.16, 0.42), dark)
	return {"body": body, "head": head}

static func _build_bubble(root: Node3D) -> Dictionary:
	var cyan := Color("#63dcff")
	var pale := Color("#baf4ff")
	var pink := Color("#ff7aa8")
	var dark := Color("#284454")
	var body := _sphere(root, "BubbleBody", Vector3(0, 0.96, 0), Vector3(0.88, 1.16, 0.78), cyan, 0.58, 0.55)
	var head := _sphere(root, "BubbleHead", Vector3(0, 1.58, -0.03), Vector3(0.92, 0.78, 0.82), pale, 0.46, 0.35)
	_eyes(root, 1.64, 0.20, -0.42, Vector3(0.14, 0.18, 0.08))
	_sphere(root, "BubbleCore", Vector3(0, 0.88, -0.12), Vector3(0.30, 0.40, 0.24), pink, 0.72, 0.9)
	_sphere(root, "BubbleCheekL", Vector3(-0.31, 1.46, -0.39), Vector3(0.12, 0.09, 0.07), pink, 0.58)
	_sphere(root, "BubbleCheekR", Vector3(0.31, 1.46, -0.39), Vector3(0.12, 0.09, 0.07), pink, 0.58)
	_sphere(root, "BubbleArmL", Vector3(-0.55, 0.90, 0), Vector3(0.24, 0.42, 0.22), cyan, 0.52, 0.25)
	_sphere(root, "BubbleArmR", Vector3(0.55, 0.90, 0), Vector3(0.24, 0.42, 0.22), cyan, 0.52, 0.25)
	_sphere(root, "BubbleFootL", Vector3(-0.26, 0.18, -0.05), Vector3(0.32, 0.20, 0.38), dark, 0.72)
	_sphere(root, "BubbleFootR", Vector3(0.26, 0.18, -0.05), Vector3(0.32, 0.20, 0.38), dark, 0.72)
	for i in range(4):
		var bx := -0.30 + float(i) * 0.20
		_sphere(root, "BubbleSpeck", Vector3(bx, 1.05 + float(i % 2) * 0.25, 0.38), Vector3(0.09, 0.09, 0.09), pale, 0.45, 0.25)
	return {"body": body, "head": head}

static func _build_shroom(root: Node3D) -> Dictionary:
	var mint := Color("#9ee8c8")
	var purple := Color("#a978f0")
	var deep := Color("#6a48a8")
	var cream := Color("#f0e7d4")
	var body := _sphere(root, "ShroomBody", Vector3(0, 0.82, 0), Vector3(0.68, 0.92, 0.62), mint)
	var head := _sphere(root, "ShroomFace", Vector3(0, 1.34, -0.05), Vector3(0.58, 0.62, 0.55), cream)
	_eyes(root, 1.40, 0.17, -0.31, Vector3(0.12, 0.16, 0.075))
	_sphere(root, "ShroomCap", Vector3(0, 1.88, 0.02), Vector3(1.42, 0.48, 1.30), purple, 1.0, 0.22)
	_cylinder(root, "ShroomUnderside", Vector3(0, 1.70, 0.02), Vector3(0.84, 0.14, 0.84), mint, Vector3.ZERO, 1.0, 0.25)
	_limb(root, "ShroomArmL", Vector3(-0.48, 0.88, 0), Vector3(0.15, 0.46, 0.15), mint, -0.22)
	_limb(root, "ShroomArmR", Vector3(0.48, 0.88, 0), Vector3(0.15, 0.46, 0.15), mint, 0.22)
	_sphere(root, "ShroomFootL", Vector3(-0.24, 0.17, -0.04), Vector3(0.30, 0.18, 0.36), deep)
	_sphere(root, "ShroomFootR", Vector3(0.24, 0.17, -0.04), Vector3(0.30, 0.18, 0.36), deep)
	var spot_positions: Array[Vector3] = [Vector3(-0.48,2.05,-0.25), Vector3(0.42,2.08,-0.18), Vector3(0,2.11,0.22), Vector3(-0.62,1.94,0.20), Vector3(0.62,1.94,0.18)]
	for pos: Vector3 in spot_positions:
		_sphere(root, "ShroomSpot", pos, Vector3(0.18, 0.09, 0.18), mint, 1.0, 0.35)
	return {"body": body, "head": head}
