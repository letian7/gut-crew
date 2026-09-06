extends RefCounted

static func wet_mat(color: Color, alpha := 1.0, glow := 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color.r, color.g, color.b, alpha)
	material.roughness = 0.38 if alpha > 0.5 else 0.22
	material.metallic_specular = 0.58
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
	item.material_override = wet_mat(color, alpha, glow)
	root.add_child(item)
	return item
static func cylinder(root: Node3D, part_name: String, pos: Vector3, scale_v: Vector3, color: Color, rot := Vector3.ZERO, alpha := 1.0, glow := 0.0) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	item.name = part_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.5
	mesh.bottom_radius = 0.5
	mesh.height = 1.0
	item.mesh = mesh
	item.position = pos
	item.rotation = rot
	item.scale = scale_v
	item.material_override = wet_mat(color, alpha, glow)
	root.add_child(item)
	return item

static func capsule(root: Node3D, part_name: String, pos: Vector3, scale_v: Vector3, color: Color, rot := Vector3.ZERO, alpha := 1.0, glow := 0.0) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	item.name = part_name
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.5
	item.mesh = mesh
	item.position = pos
	item.rotation = rot
	item.scale = scale_v
	item.material_override = wet_mat(color, alpha, glow)
	root.add_child(item)
	return item

static func torus(root: Node3D, part_name: String, pos: Vector3, scale_v: Vector3, color: Color, rot := Vector3.ZERO, alpha := 1.0, glow := 0.0) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	item.name = part_name
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.68
	mesh.outer_radius = 1.0
	item.mesh = mesh
	item.position = pos
	item.rotation = rot
	item.scale = scale_v
	item.material_override = wet_mat(color, alpha, glow)
	root.add_child(item)
	return item

static func build(parent: Node3D) -> Node3D:
	var root := Node3D.new()
	root.name = "StomachAnatomyV1"
	parent.add_child(root)
	_build_anatomical_regions(root)
	_build_directional_rugae(root)
	_build_gastric_pits(root)
	_build_vascular_network(root)
	_build_mucus_film(root)
	_build_peristaltic_bands(root)
	_build_secretions(root)
	root.set_meta("anatomical_zones", 5)
	root.set_meta("visual_parts", root.get_child_count())
	root.set_meta("wet_surface_parts", 30)
	return root

static func _build_anatomical_regions(root: Node3D) -> void:
	var deep := Color("#6f284d")
	var mucosa := Color("#a9476b")
	var light := Color("#cf7188")
	for i in range(7):
		var angle := PI * 0.20 + float(i) * 0.34
		var lobe := sphere(root, "FundusLobe%02d" % i, Vector3(-19.05 + sin(angle) * 0.18, 2.55 + float(i) * 0.72, 2.6 + cos(angle) * 2.1), Vector3(0.28, 0.70, 1.05), mucosa if i % 2 == 0 else deep)
		lobe.rotation.z = -0.28 + float(i) * 0.08
		lobe.set_meta("base_scale", lobe.scale)
		lobe.set_meta("phase", float(i) * 0.42)
	for i in range(9):
		var x := -8.2 + float(i) * 2.05
		var body_pad := sphere(root, "CorpusMucosa%02d" % i, Vector3(x, 5.8 + sin(float(i) * 0.7) * 0.34, 14.92), Vector3(1.18, 0.40, 0.15), light if i % 3 == 0 else mucosa)
		body_pad.rotation.z = sin(float(i) * 0.8) * 0.18
		body_pad.set_meta("base_scale", body_pad.scale)
	for i in range(7):
		var t := float(i) / 6.0
		var x := 6.2 + t * 6.3
		var z := 4.6 - t * 7.8
		var antrum := sphere(root, "AntrumFunnel%02d" % i, Vector3(x, 0.24 + t * 0.08, z), Vector3(1.32 - t * 0.38, 0.16, 0.92 - t * 0.24), Color("#b85a78"))
		antrum.rotation.y = -0.52
		antrum.set_meta("base_scale", antrum.scale)
	for i in range(8):
		var a := TAU * float(i) / 8.0
		var collar := sphere(root, "PyloricCollar%02d" % i, Vector3(10.7 + cos(a) * 1.36, 1.8 + sin(a) * 1.36, -5.48), Vector3(0.44, 0.31, 0.48), Color("#d17a90"))
		collar.set_meta("phase", float(i) * 0.31)
	for i in range(7):
		var a := TAU * float(i) / 7.0
		sphere(root, "CardiaRosette%02d" % i, Vector3(-11.0 + cos(a) * 1.58, 2.0 + sin(a) * 1.58, -5.46), Vector3(0.48, 0.30, 0.50), Color("#de8292"))
static func _build_directional_rugae(root: Node3D) -> void:
	var colors: Array[Color] = [Color("#d17a8e"), Color("#c26580"), Color("#a94b70")]
	for i in range(30):
		var row := i % 3
		var column := float(i / 3)
		var x := -11.5 + column * 2.55
		var z := -3.9 + float(row) * 2.45 + sin(column * 0.72 + float(row)) * 0.55
		var fold := capsule(root, "MucosalRuga%02d" % i, Vector3(x, 0.30 + float(row) * 0.035, z), Vector3(0.34, 0.13 + float(i % 2) * 0.035, 1.15), colors[i % colors.size()], Vector3(0.0, -0.28 + sin(column) * 0.22, PI * 0.5))
		fold.set_meta("base_scale", fold.scale)
		fold.set_meta("phase", column * 0.28 + float(row) * 0.72)
	for i in range(18):
		var x := -11.8 + float(i) * 1.42
		var y := 1.2 + float(i % 5) * 1.05
		var wall_fold := capsule(root, "WallRuga%02d" % i, Vector3(x, y, 15.08), Vector3(0.17, 0.68 + float(i % 3) * 0.14, 0.075), colors[(i + 1) % colors.size()], Vector3(0.0, 0.0, sin(float(i)) * 0.22))
		wall_fold.set_meta("base_scale", wall_fold.scale)
		wall_fold.set_meta("phase", float(i) * 0.24)

static func _build_gastric_pits(root: Node3D) -> void:
	for i in range(28):
		var column := i % 10
		var row := i / 10
		var x := -10.8 + float(column) * 2.35 + float(row) * 0.28
		var y := 1.25 + float(row) * 1.55 + sin(float(column) * 0.9) * 0.18
		var pit := torus(root, "GastricPit%02d" % i, Vector3(x, y, 15.20), Vector3(0.14, 0.14, 0.035), Color("#642141"), Vector3(PI * 0.5, 0.0, 0.0), 1.0, 0.12)
		pit.set_meta("phase", float(i) * 0.37)
		sphere(root, "GlandGlow%02d" % i, Vector3(x, y, 15.16), Vector3(0.065, 0.065, 0.020), Color("#ef9f9a"), 0.72, 0.32)

static func _build_vascular_network(root: Node3D) -> void:
	var vessel_colors: Array[Color] = [Color("#7e2048"), Color("#5d315c"), Color("#a12b51")]
	for i in range(18):
		var x := -11.2 + float(i) * 1.35
		var y := 0.18 + float(i % 3) * 0.035
		var z := -6.4 + sin(float(i) * 0.68) * 0.62
		var vein := cylinder(root, "MucosalVessel%02d" % i, Vector3(x, y, z), Vector3(0.055 + float(i % 2) * 0.015, 0.78, 0.055), vessel_colors[i % vessel_colors.size()], Vector3(0.0, 0.0, PI * 0.5), 1.0, 0.10)
		vein.rotation.y = sin(float(i) * 0.5) * 0.34
		vein.set_meta("base_scale", vein.scale)
		vein.set_meta("phase", float(i) * 0.29)
		if i % 3 == 0:
			var branch := cylinder(root, "VesselBranch%02d" % i, Vector3(x + 0.35, y + 0.02, z + 0.38), Vector3(0.038, 0.48, 0.038), vessel_colors[(i + 1) % vessel_colors.size()], Vector3(0.55, 0.0, 0.72), 1.0, 0.08)
			branch.set_meta("base_scale", branch.scale)
static func _build_mucus_film(root: Node3D) -> void:
	for i in range(18):
		var x := -11.0 + float(i % 9) * 2.75
		var z := -4.7 + float(i / 9) * 8.7 + sin(float(i) * 1.23) * 0.62
		var film := sphere(root, "MucusFilm%02d" % i, Vector3(x, 0.19, z), Vector3(1.28, 0.035, 0.78), Color("#f29ab7"), 0.16, 0.08)
		film.rotation.y = float(i) * 0.41
	for i in range(12):
		var x := -9.8 + float(i) * 1.78
		var strand := capsule(root, "MucusThread%02d" % i, Vector3(x, 3.0 + float(i % 4) * 0.65, 15.13), Vector3(0.035, 0.54 + float(i % 3) * 0.18, 0.024), Color("#ffd0dc"), Vector3.ZERO, 0.28, 0.10)
		strand.set_meta("base_scale", strand.scale)
		strand.set_meta("phase", float(i) * 0.46)

static func _build_peristaltic_bands(root: Node3D) -> void:
	for i in range(8):
		var x := -9.6 + float(i) * 2.75
		var band := capsule(root, "PeristalticBand%02d" % i, Vector3(x, 0.24, 5.9), Vector3(0.24, 0.12, 3.8), Color("#8d355b"), Vector3(0.0, 0.0, PI * 0.5), 0.78)
		band.set_meta("base_scale", band.scale)
		band.set_meta("phase", float(i) * 0.58)

static func _build_secretions(root: Node3D) -> void:
	for i in range(16):
		var x := -10.5 + float(i) * 1.42
		var drop := sphere(root, "MucusDrop%02d" % i, Vector3(x, 5.1 + float(i % 3) * 0.58, 15.10), Vector3(0.075, 0.24 + float(i % 4) * 0.05, 0.038), Color("#ffc2d2"), 0.34, 0.10)
		drop.set_meta("base_y", drop.position.y)
		drop.set_meta("phase", float(i) * 0.33)
static func animate(root: Node3D, time: float, danger := 0.0) -> void:
	if not is_instance_valid(root):
		return
	for child in root.get_children():
		if not (child is MeshInstance3D):
			continue
		var item := child as MeshInstance3D
		var phase := float(item.get_meta("phase", 0.0))
		if item.name.begins_with("MucosalRuga") or item.name.begins_with("WallRuga"):
			var base: Vector3 = item.get_meta("base_scale", item.scale)
			var wave := 1.0 + sin(time * (1.25 + danger * 0.35) + phase) * (0.045 + danger * 0.025)
			item.scale = Vector3(base.x, base.y * wave, base.z * (2.0 - wave))
		elif item.name.begins_with("FundusLobe") or item.name.begins_with("CorpusMucosa"):
			var base: Vector3 = item.get_meta("base_scale", item.scale)
			item.scale = base * (1.0 + sin(time * 0.82 + phase) * 0.018)
		elif item.name.begins_with("PeristalticBand"):
			var base: Vector3 = item.get_meta("base_scale", item.scale)
			var contraction := maxf(0.0, sin(time * 1.35 - item.position.x * 0.26 + phase))
			item.scale = Vector3(base.x * (1.0 + contraction * 0.18), base.y * (1.0 + contraction * 0.45), base.z)
		elif item.name.begins_with("GlandGlow"):
			var material := item.material_override as StandardMaterial3D
			if material:
				material.emission_energy_multiplier = 0.22 + absf(sin(time * 2.2 + float(item.get_index()) * 0.16)) * 0.34
		elif item.name.begins_with("MucusDrop"):
			var base_y := float(item.get_meta("base_y", item.position.y))
			item.position.y = base_y - absf(sin(time * 0.72 + phase)) * 0.16
		elif item.name.begins_with("MucusThread"):
			var base: Vector3 = item.get_meta("base_scale", item.scale)
			item.scale.y = base.y * (1.0 + sin(time * 1.1 + phase) * 0.12)
		elif item.name.begins_with("MucosalVessel"):
			var base: Vector3 = item.get_meta("base_scale", item.scale)
			item.scale.x = base.x * (1.0 + sin(time * 2.5 + phase) * 0.10)

# GODOT_STOMACH_ANATOMY_V1
