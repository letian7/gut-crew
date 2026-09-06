extends RefCounted

static func mat(color: Color, alpha: float = 1.0, glow: float = 0.0, double_sided := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(color.r, color.g, color.b, alpha)
	m.roughness = 0.94
	if alpha < 0.999:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if glow > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = glow
	if double_sided:
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m

static func sphere(root: Node3D, name: String, pos: Vector3, scale_v: Vector3, color: Color, alpha := 1.0, glow := 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mi.mesh = mesh
	mi.position = pos
	mi.scale = scale_v
	mi.material_override = mat(color, alpha, glow)
	root.add_child(mi)
	return mi

static func cylinder(root: Node3D, name: String, pos: Vector3, scale_v: Vector3, color: Color, rot := Vector3.ZERO, glow := 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.5
	mesh.bottom_radius = 0.5
	mesh.height = 1.0
	mi.mesh = mesh
	mi.position = pos
	mi.rotation = rot
	mi.scale = scale_v
	mi.material_override = mat(color, 1.0, glow)
	root.add_child(mi)
	return mi

static func torus(root: Node3D, name: String, pos: Vector3, scale_v: Vector3, color: Color, rot := Vector3.ZERO, glow := 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.62
	mesh.outer_radius = 1.0
	mi.mesh = mesh
	mi.position = pos
	mi.rotation = rot
	mi.scale = scale_v
	mi.material_override = mat(color, 1.0, glow)
	root.add_child(mi)
	return mi

static func build(parent: Node3D) -> Node3D:
	var root := Node3D.new()
	root.name = "MapVisualV2"
	parent.add_child(root)
	_build_shell(root)
	_build_rugae(root)
	_build_acid_rim(root)
	_build_acid_bubbles(root)
	_build_platform_skins(root)
	_build_gates(root)
	_build_nerve_ridge(root)
	_build_mucus_beads(root)
	_build_tissue_details(root)
	enhance_v3(root)
	_build_clay_surface_marks(root)
	return root

static func _build_clay_surface_marks(root: Node3D) -> void:
	for i in range(8):
		var x: float = -8.5 + float(i) * 2.4
		var y: float = 2.1 + float(i % 3) * 0.72
		for r in range(2):
			var ring := torus(root,"ClayWallPrint",Vector3(x,y,7.28),Vector3.ONE*(0.22+float(r)*0.11),Color("#d88ba0"),Vector3(PI*0.5,0,0),0.0)
			ring.set_meta("clay_wall_print", true)
			var rm := ring.material_override as StandardMaterial3D
			if rm:
				rm.albedo_color.a = 0.08
				rm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for i in range(6):
		var press := sphere(root,"ClayPress",Vector3(-6.0+float(i)*2.4,0.35,1.4+sin(float(i))*0.9),Vector3(0.42,0.08,0.26),Color("#d98098"))
		press.rotation.y = float(i)*0.37

static func _build_shell(root: Node3D) -> void:
	var shell := MeshInstance3D.new()
	shell.name = "StomachShell"
	var mesh := SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 2.0
	shell.mesh = mesh
	shell.position = Vector3(0, 3.8, 0)
	shell.scale = Vector3(21.0, 8.5, 16.5)
	shell.material_override = mat(Color("#713052"), 1.0, 0.08, true)
	root.add_child(shell)
	var ceiling := sphere(root, "CeilingBulge", Vector3(0, 6.6, 0.2), Vector3(14.5, 1.8, 8.4), Color("#9c466c"))
	ceiling.set_meta("base_scale", ceiling.scale)

static func _build_rugae(root: Node3D) -> void:
	var pinks: Array[Color] = [Color("#b6577b"), Color("#a94b72"), Color("#c56a86")]
	for side in [-1.0, 1.0]:
		for i in range(7):
			var z := -5.8 + float(i) * 1.9
			var fold := sphere(root, "RugaFold", Vector3(side * 12.8, 1.85 + float(i % 2) * 0.35, z), Vector3(1.0, 1.45, 2.45), pinks[i % pinks.size()])
			fold.rotation.z = side * (0.20 + float(i % 3) * 0.05)
			fold.set_meta("base_scale", fold.scale)
	for i in range(8):
		var x := -10.5 + float(i) * 3.0
		var fold := sphere(root, "BackFold", Vector3(x, 2.0 + float(i % 2) * 0.4, 7.7), Vector3(1.9, 1.45, 0.9), pinks[(i + 1) % pinks.size()])
		fold.set_meta("base_scale", fold.scale)

static func _build_acid_rim(root: Node3D) -> void:
	var rim := Color("#c98195")
	for side in [-1.0, 1.0]:
		for i in range(5):
			var z := 2.5 + float(i) * 1.1
			var lump := sphere(root, "AcidRim", Vector3(side * 6.25, 0.18, z), Vector3(0.7, 0.28, 0.8), rim)
			lump.set_meta("base_scale", lump.scale)
	for i in range(7):
		var x := -5.4 + float(i) * 1.8
		sphere(root, "AcidRim", Vector3(x, 0.18, 7.55), Vector3(0.75, 0.28, 0.62), rim)

static func _build_gates(root: Node3D) -> void:
	var cardia := torus(root, "CardiaGateModel", Vector3(-11.0, 2.0, -5.7), Vector3(1.55, 1.55, 1.0), Color("#d77a8e"), Vector3(PI * 0.5, 0, 0), 0.18)
	cardia.set_meta("base_scale", cardia.scale)
	for i in range(6):
		var a := TAU * float(i) / 6.0
		var p := Vector3(-11.0 + cos(a) * 1.65, 2.0 + sin(a) * 1.65, -5.6)
		sphere(root, "CardiaPetal", p, Vector3(0.58, 0.38, 0.68), Color("#c55d80"))
	var pyloric := torus(root, "PyloricGateModel", Vector3(10.7, 1.8, -5.6), Vector3(1.35, 1.35, 0.85), Color("#a96786"), Vector3(PI * 0.5, 0, 0), 0.12)
	pyloric.set_meta("base_scale", pyloric.scale)
	for i in range(5):
		var a := TAU * float(i) / 5.0
		var p := Vector3(10.7 + cos(a) * 1.42, 1.8 + sin(a) * 1.42, -5.5)
		sphere(root, "PyloricPetal", p, Vector3(0.52, 0.34, 0.60), Color("#b87693"))

static func _build_nerve_ridge(root: Node3D) -> void:
	var yellow := Color("#f2dc5d")
	for i in range(11):
		var x := -7.2 + float(i) * 1.45
		var y := 0.92 + sin(float(i) * 0.72) * 0.18
		var seg := cylinder(root, "NerveCord", Vector3(x, y, -5.72), Vector3(0.13, 0.88, 0.13), yellow, Vector3(0, 0, PI * 0.5), 0.85)
		seg.rotation.y = sin(float(i) * 0.55) * 0.14
		if i % 2 == 0:
			sphere(root, "NerveNode", Vector3(x, y + 0.12, -5.68), Vector3(0.28, 0.28, 0.28), yellow, 1.0, 1.25)

static func _build_mucus_beads(root: Node3D) -> void:
	var pink := Color("#ff66b0")
	var route_data := [[Vector3(-2.5, 0.12, -1.7), -0.7], [Vector3(6.7, 0.12, -2.0), 0.85]]
	for route in route_data:
		var center: Vector3 = route[0]
		var rot_y: float = route[1]
		for i in range(9):
			var local_z := -2.7 + float(i) * 0.68
			var local_x := sin(float(i) * 1.7) * 0.42
			var off := Vector3(local_x, 0.0, local_z).rotated(Vector3.UP, rot_y)
			var bead := sphere(root, "MucusBead", center + off, Vector3(0.34, 0.10, 0.48), pink, 0.52, 0.55)
			bead.set_meta("phase", float(i) * 0.55)

static func _build_tissue_details(root: Node3D) -> void:
	var dark := Color("#642848")
	var light := Color("#d47791")
	for i in range(18):
		var angle := TAU * float(i) / 18.0
		var radius := 9.0 + float(i % 3) * 0.8
		var p := Vector3(cos(angle) * radius, 0.42 + float(i % 4) * 0.12, sin(angle) * 5.4)
		var nodule := sphere(root, "TissueNodule", p, Vector3(0.30, 0.18, 0.32), light if i % 2 == 0 else dark)
		nodule.set_meta("phase", float(i) * 0.37)
	for i in range(10):
		var x := -10.5 + float(i) * 2.3
		cylinder(root, "Vein", Vector3(x, 0.11, -7.0 + sin(float(i)) * 0.35), Vector3(0.05, 0.75, 0.05), Color("#7a254c"), Vector3(0,0,PI*0.5), 0.12)

static func animate(root: Node3D, time: float, danger: float = 0.0) -> void:
	if not is_instance_valid(root): return
	for child in root.get_children():
		if not (child is MeshInstance3D): continue
		var mi := child as MeshInstance3D
		if mi.name == "RugaFold" or mi.name == "BackFold" or mi.name == "AcidRim":
			if mi.has_meta("base_scale"):
				var base: Vector3 = mi.get_meta("base_scale")
				var pulse := 1.0 + sin(time * (1.55 + danger * 0.5) + mi.position.x * 0.16 + mi.position.z * 0.12) * (0.035 + danger * 0.018)
				mi.scale = Vector3(base.x, base.y * pulse, base.z)
		elif mi.name == "CardiaGateModel" or mi.name == "PyloricGateModel":
			var base: Vector3 = mi.get_meta("base_scale")
			var pulse := 1.0 + sin(time * 2.15) * 0.055
			mi.scale = base * Vector3(pulse, pulse, 1.0)
		elif mi.name == "NerveNode":
			var nm := mi.material_override as StandardMaterial3D
			if nm: nm.emission_energy_multiplier = 1.0 + sin(time * 5.0 + mi.position.x) * 0.45 + danger * 0.25
		elif mi.name == "MucusBead":
			var phase := float(mi.get_meta("phase", 0.0))
			mi.position.y = 0.12 + sin(time * 4.0 + phase) * 0.025
		elif mi.name == "AcidBubble":
			var phase := float(mi.get_meta("phase", 0.0))
			mi.position.y = 0.18 + absf(sin(time * 2.8 + phase)) * 0.22
			mi.scale *= 1.0 + sin(time * 3.4 + phase) * 0.002
		elif mi.name == "TissueNodule":
			var phase := float(mi.get_meta("phase", 0.0))
			mi.scale = Vector3.ONE * (1.0 + sin(time * 2.0 + phase) * 0.06)
		elif mi.name == "HangingFold":
			var phase := float(mi.get_meta("phase",0.0))
			mi.rotation.z += sin(time*1.7+phase)*0.0008*(1.0+danger)
		elif mi.name == "AcidFoam":
			var phase := float(mi.get_meta("phase",0.0))
			mi.position.y = 0.16 + absf(sin(time*3.1+phase))*0.07
		elif mi.name == "GlandGlow":
			var gm := mi.material_override as StandardMaterial3D
			if gm: gm.emission_energy_multiplier = 0.45 + absf(sin(time*2.5+mi.position.z))*0.35

# GODOT_MAP_VISUAL_V2

static func box(root: Node3D, name: String, pos: Vector3, size_v: Vector3, color: Color, rot := Vector3.ZERO, glow := 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE
	mi.mesh = mesh
	mi.position = pos
	mi.rotation = rot
	mi.scale = size_v
	mi.material_override = mat(color, 1.0, glow)
	root.add_child(mi)
	return mi

static func capsule(root: Node3D, name: String, pos: Vector3, scale_v: Vector3, color: Color, rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.3
	mi.mesh = mesh
	mi.position = pos
	mi.rotation = rot
	mi.scale = scale_v
	mi.material_override = mat(color)
	root.add_child(mi)
	return mi

static func _build_acid_bubbles(root: Node3D) -> void:
	for i in range(14):
		var x := -5.2 + float(i % 7) * 1.7
		var z := 3.0 + float(i / 7) * 2.6 + sin(float(i) * 1.3) * 0.45
		var size := 0.12 + float(i % 4) * 0.035
		var b := sphere(root, "AcidBubble", Vector3(x,0.18,z), Vector3(size,size*0.72,size), Color("#b7ef4a"), 0.58, 0.85)
		b.set_meta("phase", float(i) * 0.53)

static func _build_platform_skins(root: Node3D) -> void:
	var skin_a := sphere(root, "HighGroundSkin", Vector3(-8.2, 1.17, 3.8), Vector3(5.1, 0.72, 3.2), Color("#bd6682"))
	skin_a.set_meta("base_scale", skin_a.scale)
	var skin_b := sphere(root, "HighGroundSkin", Vector3(7.7, 1.30, 4.0), Vector3(4.7, 0.78, 3.0), Color("#aa5577"))
	skin_b.set_meta("base_scale", skin_b.scale)
	for i in range(5):
		var t := float(i) / 4.0
		var left := sphere(root, "RampSkin", Vector3(lerpf(-7.1,-3.3,t), lerpf(0.66,0.30,t), lerpf(3.75,2.45,t)), Vector3(1.35,0.30,0.82), Color("#ca738d"))
		left.rotation.y = -0.30
		var right := sphere(root, "RampSkin", Vector3(lerpf(3.0,7.1,t), lerpf(0.30,0.78,t), lerpf(2.45,3.75,t)), Vector3(1.35,0.30,0.82), Color("#b86480"))
		right.rotation.y = 0.30

static func build_swallowed_prop(root: Node3D, kind: int) -> void:
	match kind % 4:
		0:
			capsule(root, "SwallowedPill", Vector3.ZERO, Vector3(0.65,0.65,1.2), Color("#6ed7f3"), Vector3(0,0,PI*0.5))
			box(root, "PillStripe", Vector3.ZERO, Vector3(0.08,0.68,0.68), Color("#f7e7c6"), Vector3(0,0,PI*0.5))
		1:
			cylinder(root, "SwallowedCap", Vector3.ZERO, Vector3(0.85,0.42,0.85), Color("#f07875"))
			torus(root, "CapRim", Vector3(0,0.18,0), Vector3(0.66,0.16,0.66), Color("#b9465f"))
		2:
			box(root, "SwallowedToy", Vector3.ZERO, Vector3(1.0,0.62,0.82), Color("#d7bb5b"), Vector3(0.12,0.18,0.08))
			for sx in [-1.0,1.0]:
				for sz in [-1.0,1.0]:
					sphere(root, "ToyBump", Vector3(sx*0.42,0.32,sz*0.32), Vector3(0.16,0.13,0.16), Color("#f1d67a"))
		3:
			cylinder(root, "SwallowedBone", Vector3.ZERO, Vector3(0.20,1.05,0.20), Color("#efe3c9"), Vector3(0,0,PI*0.5))
			for sx in [-1.0,1.0]:
				sphere(root, "BoneKnob", Vector3(sx*0.58,0,0), Vector3(0.34,0.30,0.30), Color("#efe3c9"))

# GODOT_MAP_VISUAL_V2_PROPS
static func enhance_v3(root: Node3D) -> void:
	_build_v3_lights(root)
	_build_hanging_folds(root)
	_build_gastric_glands(root)
	_build_acid_foam(root)
	_build_vessel_branches(root)

static func _build_v3_lights(root: Node3D) -> void:
	var data := [
		[Vector3(-7.5,3.6,-1.0), Color("#ff759e"), 2.2],
		[Vector3(7.0,3.1,2.0), Color("#ff9b76"), 1.8]
	]
	for d in data:
		var l := OmniLight3D.new()
		l.name = "OrganGlow"
		l.position = d[0]
		l.light_color = d[1]
		l.light_energy = d[2]
		l.omni_range = 8.5
		l.shadow_enabled = false
		root.add_child(l)

static func _build_hanging_folds(root: Node3D) -> void:
	for i in range(10):
		var x: float = -9.0 + float(i) * 2.0
		var z: float = -3.8 + sin(float(i) * 1.4) * 1.7
		var fold := sphere(root, "HangingFold", Vector3(x,5.2,z), Vector3(0.65,1.6 + float(i%3)*0.25,0.85), Color("#b95e7d"))
		fold.rotation.z = sin(float(i) * 0.9) * 0.18
		fold.set_meta("phase", float(i) * 0.43)
static func _build_gastric_glands(root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		for i in range(9):
			var z: float = -5.2 + float(i) * 1.35
			var y: float = 1.15 + float(i % 3) * 0.52
			var pore := sphere(root, "GlandPore", Vector3(side*11.7,y,z), Vector3(0.20,0.12,0.20), Color("#54223e"), 1.0, 0.12)
			pore.set_meta("phase", float(i) * 0.34 + side)
			if i % 3 == 0:
				sphere(root, "GlandGlow", Vector3(side*11.55,y+0.04,z), Vector3(0.09,0.06,0.09), Color("#ff8aaa"), 0.72, 0.55)

static func _build_acid_foam(root: Node3D) -> void:
	for i in range(24):
		var a: float = TAU * float(i) / 24.0
		var rx: float = 5.8 + sin(float(i)*1.9)*0.28
		var rz: float = 2.45 + cos(float(i)*1.3)*0.22
		var p := Vector3(cos(a)*rx,0.16,4.9+sin(a)*rz)
		var foam := sphere(root,"AcidFoam",p,Vector3(0.18,0.08,0.18),Color("#d7f56a"),0.46,0.42)
		foam.set_meta("phase",float(i)*0.29)

static func _build_vessel_branches(root: Node3D) -> void:
	var vein := Color("#7b2a51")
	for i in range(8):
		var z: float = -4.5 + float(i) * 1.2
		var a := Vector3(-10.5,0.16,z)
		var b := Vector3(-7.2,0.14,z+sin(float(i))*0.7)
		cylinder(root,"VesselBranch",a.lerp(b,0.5),Vector3(0.055,a.distance_to(b),0.055),vein,Vector3(0,0,PI*0.5),0.15)

# GODOT_MAP_VISUAL_V3

# GODOT_CLAY_SURFACE_V1
