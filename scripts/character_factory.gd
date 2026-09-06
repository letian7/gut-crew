extends RefCounted

const CharacterDetailFactory = preload("res://scripts/character_detail_factory.gd")
const CharacterArt = preload("res://scripts/art18_character.gd")

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

static func _torus(root: Node3D, part_name: String, pos: Vector3, scale_v: Vector3, color: Color, rot: Vector3 = Vector3.ZERO, alpha: float = 1.0, glow: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = part_name
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.58
	mesh.outer_radius = 1.0
	mi.mesh = mesh
	mi.position = pos
	mi.rotation = rot
	mi.scale = scale_v
	mi.material_override = clay(color, alpha, glow)
	root.add_child(mi)
	return mi

static func build_role(root: Node3D, role: int) -> Dictionary:
	for child in root.get_children():
		root.remove_child(child)
		child.queue_free()
	var result: Dictionary = {}
	match role:
		0: result = _build_spark(root)
		1: result = _build_kaka(root)
		2: result = _build_bubble(root)
		3: result = _build_shroom(root)
	_add_clay_marks(root, role)
	CharacterDetailFactory.build_details(root, role)
	CharacterArt.attach(root, role)
	return result

static func _add_clay_marks(root: Node3D, role: int) -> void:
	var colors: Array[Color] = [Color("#fff0a4"),Color("#fff8e8"),Color("#d6f8ff"),Color("#d9c7ff")]
	var zs: Array[float] = [-0.60,-0.43,-0.80,-0.58]
	var ys: Array[float] = [1.08,0.94,1.02,0.90]
	for i in range(3):
		var mark := _torus(root,"ClayPrint",Vector3(-0.30 + float(i)*0.09,ys[role] + float(i)*0.035,zs[role]),Vector3.ONE*(0.075+float(i)*0.025),colors[role],Vector3(PI*0.5,0,0),0.075)
		mark.rotation.z = -0.22 + float(i)*0.11
		mark.set_meta("clay_print", true)

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
	var body := _sphere(root, "SparkBody", Vector3(0, 0.78, 0), Vector3(0.72, 0.88, 0.62), yellow, 1.0, 0.16)
	var head := _sphere(root, "SparkHead", Vector3(0, 1.58, -0.02), Vector3(1.18, 1.04, 1.02), yellow, 1.0, 0.18)
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
	_sphere(root, "SparkGloveL", Vector3(-0.67, 0.48, -0.04), Vector3(0.24,0.22,0.24), orange)
	_sphere(root, "SparkGloveR", Vector3(0.67, 0.48, -0.04), Vector3(0.24,0.22,0.24), orange)
	_box(root, "SparkBootL", Vector3(-0.22, 0.04, -0.12), Vector3(0.32,0.16,0.42), dark)
	_box(root, "SparkBootR", Vector3(0.22, 0.04, -0.12), Vector3(0.32,0.16,0.42), dark)
	_box(root, "SparkBattery", Vector3(0, 0.86, 0.42), Vector3(0.48,0.54,0.20), orange, 1.0, 0.25)
	_box(root, "SparkBrowL", Vector3(-0.24,1.87,-0.50), Vector3(0.20,0.045,0.045), dark).rotation.z = -0.14
	_box(root, "SparkBrowR", Vector3(0.24,1.87,-0.50), Vector3(0.20,0.045,0.045), dark).rotation.z = 0.14
	_sphere(root, "SparkCheekL", Vector3(-0.38,1.43,-0.47), Vector3(0.11,0.075,0.06), orange, 0.80)
	_sphere(root, "SparkCheekR", Vector3(0.38,1.43,-0.47), Vector3(0.11,0.075,0.06), orange, 0.80)
	_sphere(root, "SparkSocketL", Vector3(-0.22,2.05,0), Vector3(0.18,0.12,0.18), dark)
	_sphere(root, "SparkSocketR", Vector3(0.22,2.05,0), Vector3(0.18,0.12,0.18), dark)
	_box(root, "SparkBoltA", Vector3(-0.04,0.96,-0.58), Vector3(0.10,0.28,0.055), orange).rotation.z = -0.55
	_box(root, "SparkBoltB", Vector3(0.05,0.78,-0.58), Vector3(0.10,0.28,0.055), orange).rotation.z = 0.55
	_torus(root, "SparkCable", Vector3(0,0.84,0.48), Vector3(0.35,0.35,0.14), metal, Vector3(PI*0.5,0,0), 1.0, 0.12)
	_cylinder(root,"SparkPlugTipL",Vector3(-0.22,2.63,0),Vector3(0.07,0.24,0.07),metal,Vector3(0,0,PI*0.5))
	_cylinder(root,"SparkPlugTipR",Vector3(0.22,2.63,0),Vector3(0.07,0.24,0.07),metal,Vector3(0,0,PI*0.5))
	_sphere(root,"SparkRivetL",Vector3(-0.32,0.92,-0.57),Vector3(0.07,0.07,0.04),metal,1.0,0.18)
	_sphere(root,"SparkRivetR",Vector3(0.32,0.92,-0.57),Vector3(0.07,0.07,0.04),metal,1.0,0.18)
	return {"body": body, "head": head}

static func _build_kaka(root: Node3D) -> Dictionary:
	var bone := Color("#f2e8d4")
	var orange := Color("#e98b39")
	var dark := Color("#54454a")
	var body := _box(root, "KakaBody", Vector3(0, 0.88, 0), Vector3(0.95, 1.02, 0.58), bone, 1.0, 0.05)
	var head := _box(root, "KakaHead", Vector3(0, 1.72, -0.02), Vector3(0.82, 0.72, 0.68), bone, 1.0, 0.05)
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
	_sphere(root, "KakaFistL", Vector3(-0.74,0.53,-0.02), Vector3(0.23,0.21,0.23), bone)
	_sphere(root, "KakaFistR", Vector3(0.74,0.53,-0.02), Vector3(0.23,0.21,0.23), bone)
	_box(root, "KakaShoulderL", Vector3(-0.60,1.34,0), Vector3(0.34,0.18,0.42), orange)
	_box(root, "KakaShoulderR", Vector3(0.60,1.34,0), Vector3(0.34,0.18,0.42), orange)
	_cylinder(root, "KakaWrench", Vector3(0.76,0.86,0.18), Vector3(0.10,0.62,0.10), orange, Vector3(0,0,0.28))
	_box(root, "KakaJaw", Vector3(0,1.46,-0.36), Vector3(0.48,0.18,0.16), bone)
	_box(root, "KakaMouth", Vector3(0,1.49,-0.46), Vector3(0.34,0.07,0.04), dark)
	for tx in [-0.20,-0.07,0.07,0.20]:
		_box(root, "KakaTooth", Vector3(tx,1.49,-0.49), Vector3(0.055,0.09,0.045), bone)
	_box(root, "KakaBrowL", Vector3(-0.20,1.96,-0.39), Vector3(0.22,0.055,0.055), dark).rotation.z = -0.10
	_box(root, "KakaBrowR", Vector3(0.20,1.96,-0.39), Vector3(0.22,0.055,0.055), dark).rotation.z = 0.10
	_cylinder(root, "KakaClavicleL", Vector3(-0.24,1.27,-0.34), Vector3(0.08,0.38,0.08), bone, Vector3(0,0,PI*0.5-0.22))
	_cylinder(root, "KakaClavicleR", Vector3(0.24,1.27,-0.34), Vector3(0.08,0.38,0.08), bone, Vector3(0,0,PI*0.5+0.22))
	_sphere(root, "KakaKneeL", Vector3(-0.28,0.30,-0.16), Vector3(0.20,0.16,0.20), orange)
	_sphere(root, "KakaKneeR", Vector3(0.28,0.30,-0.16), Vector3(0.20,0.16,0.20), orange)
	_torus(root, "KakaWrenchHead", Vector3(0.92,1.14,0.16), Vector3(0.17,0.17,0.09), orange, Vector3(PI*0.5,0,0))
	_box(root,"KakaCrown",Vector3(0,2.10,0.02),Vector3(0.54,0.12,0.50),bone)
	_sphere(root,"KakaBoltL",Vector3(-0.34,2.11,-0.20),Vector3(0.09,0.07,0.09),orange)
	_sphere(root,"KakaBoltR",Vector3(0.34,2.11,-0.20),Vector3(0.09,0.07,0.09),orange)
	return {"body": body, "head": head}

static func _build_bubble(root: Node3D) -> Dictionary:
	var cyan := Color("#63dcff")
	var pale := Color("#baf4ff")
	var pink := Color("#ff7aa8")
	var dark := Color("#284454")
	var body := _sphere(root, "BubbleBody", Vector3(0, 0.96, 0), Vector3(0.88, 1.16, 0.78), cyan, 0.72, 1.05)
	var head := _sphere(root, "BubbleHead", Vector3(0, 1.58, -0.03), Vector3(0.92, 0.78, 0.82), pale, 0.58, 0.78)
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
	_box(root, "BubbleMouth", Vector3(0,1.43,-0.45), Vector3(0.18,0.045,0.045), dark, 0.72)
	for i in range(3):
		_sphere(root, "BubbleInner", Vector3(-0.20 + i*0.20,0.72 + i*0.17,0.12), Vector3(0.10,0.10,0.10), pale, 0.30, 0.35)
	_sphere(root, "BubbleMembrane", Vector3(0,1.04,0.02), Vector3(1.02,1.36,0.92), cyan, 0.08, 0.20)
	_sphere(root, "BubbleGlintA", Vector3(-0.33,1.90,-0.27), Vector3(0.13,0.26,0.06), Color.WHITE, 0.55, 0.25).rotation.z = -0.35
	_sphere(root, "BubbleGlintB", Vector3(-0.47,1.66,-0.32), Vector3(0.07,0.13,0.045), Color.WHITE, 0.45, 0.18)
	_torus(root, "BubbleBeltWave", Vector3(0,0.88,0), Vector3(0.58,0.18,0.58), pink, Vector3.ZERO, 0.42, 0.35)
	_sphere(root, "BubbleTopDrop", Vector3(0.12,2.05,0.02), Vector3(0.20,0.26,0.18), pale, 0.46, 0.25)
	_torus(root,"BubbleCrownRing",Vector3(0,1.94,0),Vector3(0.40,0.08,0.40),cyan,Vector3.ZERO,0.22,0.22)
	_sphere(root,"BubbleDropL",Vector3(-0.66,1.18,0.08),Vector3(0.12,0.20,0.10),pale,0.36,0.20)
	_sphere(root,"BubbleDropR",Vector3(0.66,1.04,0.10),Vector3(0.10,0.17,0.09),pale,0.32,0.18)
	return {"body": body, "head": head}

static func _build_shroom(root: Node3D) -> Dictionary:
	var mint := Color("#9ee8c8")
	var purple := Color("#a978f0")
	var deep := Color("#6a48a8")
	var cream := Color("#f0e7d4")
	var body := _sphere(root, "ShroomBody", Vector3(0, 0.82, 0), Vector3(0.68, 0.92, 0.62), mint, 1.0, 0.28)
	var head := _sphere(root, "ShroomFace", Vector3(0, 1.34, -0.05), Vector3(0.58, 0.62, 0.55), cream)
	_eyes(root, 1.40, 0.17, -0.31, Vector3(0.12, 0.16, 0.075))
	_sphere(root, "ShroomCap", Vector3(0, 1.88, 0.02), Vector3(1.42, 0.48, 1.30), purple, 1.0, 0.46)
	_cylinder(root, "ShroomUnderside", Vector3(0, 1.70, 0.02), Vector3(0.84, 0.14, 0.84), mint, Vector3.ZERO, 1.0, 0.25)
	_limb(root, "ShroomArmL", Vector3(-0.48, 0.88, 0), Vector3(0.15, 0.46, 0.15), mint, -0.22)
	_limb(root, "ShroomArmR", Vector3(0.48, 0.88, 0), Vector3(0.15, 0.46, 0.15), mint, 0.22)
	_sphere(root, "ShroomFootL", Vector3(-0.24, 0.17, -0.04), Vector3(0.30, 0.18, 0.36), deep)
	_sphere(root, "ShroomFootR", Vector3(0.24, 0.17, -0.04), Vector3(0.30, 0.18, 0.36), deep)
	var spot_positions: Array[Vector3] = [Vector3(-0.48,2.05,-0.25), Vector3(0.42,2.08,-0.18), Vector3(0,2.11,0.22), Vector3(-0.62,1.94,0.20), Vector3(0.62,1.94,0.18)]
	for pos: Vector3 in spot_positions:
		_sphere(root, "ShroomSpot", pos, Vector3(0.18, 0.09, 0.18), mint, 1.0, 0.35)
	_box(root, "ShroomMouth", Vector3(0,1.20,-0.33), Vector3(0.16,0.04,0.04), deep)
	for gx in [-0.42,-0.14,0.14,0.42]:
		_box(root, "ShroomGill", Vector3(gx,1.68,-0.08), Vector3(0.08,0.035,0.62), cream, 0.78)
	_sphere(root, "ShroomSporeL", Vector3(-0.82,1.28,0.18), Vector3(0.10,0.10,0.10), mint, 0.72, 0.45)
	_sphere(root, "ShroomSporeR", Vector3(0.82,1.36,0.22), Vector3(0.08,0.08,0.08), mint, 0.62, 0.45)
	_torus(root, "ShroomCapRim", Vector3(0,1.78,0.02), Vector3(0.96,0.16,0.88), deep, Vector3.ZERO, 0.82, 0.22)
	_torus(root, "ShroomCollar", Vector3(0,1.08,0), Vector3(0.44,0.11,0.44), cream, Vector3.ZERO, 0.92, 0.12)
	_sphere(root, "ShroomBlushL", Vector3(-0.30,1.27,-0.30), Vector3(0.10,0.065,0.05), Color("#e99abc"), 0.72)
	_sphere(root, "ShroomBlushR", Vector3(0.30,1.27,-0.30), Vector3(0.10,0.065,0.05), Color("#e99abc"), 0.72)
	for i in range(4):
		var a := TAU * float(i) / 4.0
		_sphere(root, "ShroomHaloSpore", Vector3(cos(a)*0.92,1.58 + sin(a*1.7)*0.14,sin(a)*0.72), Vector3(0.065,0.065,0.065), mint, 0.55, 0.55)
	_box(root,"ShroomMedicBag",Vector3(0.54,0.72,0.22),Vector3(0.30,0.34,0.18),deep)
	_cylinder(root,"ShroomVialA",Vector3(0.54,0.78,-0.02),Vector3(0.07,0.20,0.07),mint,Vector3.ZERO,0.72,0.35)
	_cylinder(root,"ShroomVialB",Vector3(0.70,0.78,-0.01),Vector3(0.07,0.17,0.07),purple,Vector3.ZERO,0.76,0.28)
	return {"body": body, "head": head}

# GODOT_CHARACTER_MODELS_V2
# GODOT_CHARACTER_MODELS_V3
# GODOT_CHARACTER_MODELS_V4

# GODOT_CLAY_SURFACE_V1
