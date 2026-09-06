extends RefCounted

static func mat(color: Color, alpha := 1.0, glow := 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color.r, color.g, color.b, alpha)
	material.roughness = 0.48 if alpha < 0.9 else 0.78
	material.metallic_specular = 0.42
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
	item.material_override = mat(color, alpha, glow)
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
	item.material_override = mat(color, alpha, glow)
	root.add_child(item)
	return item

static func torus(root: Node3D, part_name: String, pos: Vector3, scale_v: Vector3, color: Color, rot := Vector3.ZERO, alpha := 1.0, glow := 0.0) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	item.name = part_name
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.58
	mesh.outer_radius = 1.0
	item.mesh = mesh
	item.position = pos
	item.rotation = rot
	item.scale = scale_v
	item.material_override = mat(color, alpha, glow)
	root.add_child(item)
	return item
static func capsule(root: Node3D, part_name: String, pos: Vector3, scale_v: Vector3, color: Color, rot := Vector3.ZERO, alpha := 1.0, glow := 0.0) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	item.name = part_name
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.4
	item.mesh = mesh
	item.position = pos
	item.rotation = rot
	item.scale = scale_v
	item.material_override = mat(color, alpha, glow)
	root.add_child(item)
	return item

static func static_pad(root: Node3D, part_name: String, pos: Vector3, size_v: Vector3, color: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = part_name
	body.position = pos
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size_v
	mesh_instance.mesh = mesh
	mesh_instance.material_override = mat(color)
	body.add_child(mesh_instance)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size_v
	collision.shape = shape
	body.add_child(collision)
	root.add_child(body)
	return body
static func zone_label(root: Node3D, text: String, pos: Vector3, color: Color) -> Label3D:
	var label := Label3D.new()
	label.name = text.replace(" ", "") + "Label"
	label.text = text
	label.position = pos
	label.font_size = 28
	label.outline_size = 8
	label.modulate = color
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	root.add_child(label)
	return label

static func zone_light(root: Node3D, light_name: String, pos: Vector3, color: Color) -> OmniLight3D:
	var light := OmniLight3D.new()
	light.name = light_name
	light.position = pos
	light.light_color = color
	light.light_energy = 2.6
	light.omni_range = 8.5
	light.shadow_enabled = false
	root.add_child(light)
	return light

static func make_prop(root: Node3D, prop_name: String, pos: Vector3, color: Color, prop_type: String, prompt: String) -> Node3D:
	var prop := Node3D.new()
	prop.name = prop_name
	prop.position = pos
	prop.set_meta("prop_type", prop_type)
	prop.set_meta("prompt", prompt)
	prop.set_meta("cooldown", 0.0)
	prop.set_meta("used_count", 0)
	root.add_child(prop)
	var core := cylinder(prop, "Core", Vector3(0, 0.75, 0), Vector3(0.56, 0.75, 0.56), color, Vector3.ZERO, 1.0, 0.55)
	var ring := torus(prop, "ActionRing", Vector3(0, 1.35, 0), Vector3.ONE * 0.72, color.lightened(0.18), Vector3(PI * 0.5, 0, 0), 0.88, 1.15)
	prop.set_meta("ring", ring)
	var label := zone_label(prop, prompt, Vector3(0, 2.35, 0), color.lightened(0.25))
	label.font_size = 18
	prop.set_meta("label", label)
	return prop

static func build(parent: Node3D) -> Dictionary:
	var root := Node3D.new()
	root.name = "CatOrganWorldV1"
	parent.add_child(root)
	var props: Array[Node3D] = []
	var enemy_specs: Array[Dictionary] = []
	_build_hairball_forest(root, props, enemy_specs)
	_build_intestinal_maze(root, props, enemy_specs)
	_build_lung_chamber(root, props, enemy_specs)
	_build_nerve_highway(root, props, enemy_specs)
	root.set_meta("zone_count", 4)
	root.set_meta("visual_parts", root.get_child_count())
	root.set_meta("reference_layout", "INSIDE_THE_CAT")
	return {
		"root": root,
		"props": props,
		"enemy_specs": enemy_specs,
		"zone_count": 4,
		"visual_parts": root.get_child_count()
	}

static func _build_hairball_forest(root: Node3D, props: Array[Node3D], specs: Array[Dictionary]) -> void:
	var center := Vector3(14.5, 0.0, 9.2)
	static_pad(root, "HairballForestShelf", center + Vector3(0, 0.28, 0), Vector3(8.0, 0.55, 5.2), Color("#5f3859"))
	zone_label(root, "4  HAIRBALL FOREST", center + Vector3(0, 4.7, 0), Color("#a5f39a"))
	zone_light(root, "HairballForestLight", center + Vector3(0, 3.2, 0), Color("#8de6ad"))
	for i in range(11):
		var a := TAU * float(i) / 11.0
		var radius := 1.3 + float(i % 3) * 0.72
		var trunk_pos := center + Vector3(cos(a) * radius, 1.0 + float(i % 4) * 0.28, sin(a) * radius)
		var trunk := capsule(root, "TangledHair%02d" % i, trunk_pos, Vector3(0.16, 1.25 + float(i % 3) * 0.28, 0.16), Color("#78536d"), Vector3(0.10, 0, sin(a) * 0.18))
		trunk.set_meta("phase", float(i) * 0.41)
		trunk.set_meta("base_rotation", trunk.rotation)
	for i in range(6):
		var bridge_pos := center + Vector3(-2.6 + float(i) * 1.05, 1.55 + float(i % 2) * 0.42, -1.45 + float(i % 3) * 1.45)
		var bridge := capsule(root, "HairBridge%02d" % i, bridge_pos, Vector3(0.14, 1.30, 0.14), Color("#a77a92"), Vector3(0, 0, PI * 0.5 + sin(float(i)) * 0.18))
		bridge.set_meta("phase", float(i) * 0.48)
		bridge.set_meta("base_rotation", bridge.rotation)
	for i in range(7):
		var a := TAU * float(i) / 7.0
		var nest_pos := center + Vector3(cos(a) * 2.35, 0.68, sin(a) * 1.65)
		var nest := torus(root, "HairNest%02d" % i, nest_pos, Vector3(0.72, 0.24, 0.72), Color("#936979"), Vector3.ZERO)
		nest.rotation.x = PI * 0.5
	for i in range(10):
		var a := TAU * float(i) / 10.0
		var item := sphere(root, "HiddenFurItem%02d" % i, center + Vector3(cos(a) * 3.1, 0.72, sin(a) * 2.0), Vector3.ONE * 0.12, Color("#8effc9"), 0.82, 1.8)
		item.set_meta("phase", float(i) * 0.57)
		item.set_meta("base_scale", item.scale)
	for tower in range(4):
		var tower_center := center + Vector3(-2.2 + float(tower) * 1.45, 1.35 + float(tower % 2) * 0.34, 0.25 + sin(float(tower) * 1.8) * 1.45)
		for layer in range(3):
			var cocoon := torus(root, "HairCocoon%02d" % (tower * 3 + layer), tower_center, Vector3(0.78 + float(layer) * 0.13, 0.62, 0.78 + float(layer) * 0.13), Color("#8d657c").lightened(float(layer) * 0.05), Vector3(float(layer) * 0.72, float(tower) * 0.44, float(layer) * 0.51))
			cocoon.set_meta("phase", float(tower * 3 + layer) * 0.29)
	var groomer := make_prop(root, "GroomingTurbine", center + Vector3(-2.6, 0.48, -1.6), Color("#ffd56e"), "groomer", "F  GROOMING TURBINE")
	props.append(groomer)
	var relay := make_prop(root, "ForestSynapseRelay", center + Vector3(2.9, 0.48, 1.5), Color("#76dbff"), "relay_to_nerve", "F  SYNAPSE RETURN")
	props.append(relay)
	specs.append({"kind":"HAIRBALL","pos":center+Vector3(-1.1,0.65,0.4),"display_name":"FUR MITE","accent":Color("#a880aa"),"hp":88.0,"speed":3.1,"territory":"HAIRBALL FOREST","trait":"tangle"})
	specs.append({"kind":"HAIRBALL","pos":center+Vector3(1.7,0.65,-0.5),"display_name":"NEST ROLLER","accent":Color("#6f4d7b"),"hp":110.0,"speed":2.6,"territory":"HAIRBALL FOREST","trait":"tangle"})

static func _build_intestinal_maze(root: Node3D, props: Array[Node3D], specs: Array[Dictionary]) -> void:
	var center := Vector3(18.0, 0.0, -8.7)
	static_pad(root, "IntestinalMazeShelf", center + Vector3(0, 0.24, 0), Vector3(8.2, 0.48, 6.8), Color("#69416f"))
	zone_label(root, "5  INTESTINAL MAZE", center + Vector3(0, 4.4, 0), Color("#d8a4ff"))
	zone_light(root, "IntestinalMazeLight", center + Vector3(0, 3.0, 0), Color("#d391ff"))
	for i in range(12):
		var row: int = i % 3
		var column: int = i / 3
		var p := center + Vector3(-2.8 + float(column) * 1.8, 0.78 + float((i + 1) % 2) * 0.20, -2.0 + float(row) * 1.9)
		var loop := torus(root, "GutLoop%02d" % i, p, Vector3(0.78, 0.58, 0.42), Color("#9d5a91") if i % 2 == 0 else Color("#6c376b"), Vector3(PI * 0.5, 0, float(i) * 0.16))
		loop.set_meta("phase", float(i) * 0.36)
		loop.set_meta("base_scale", loop.scale)
	for i in range(5):
		var gate_pos := center + Vector3(-2.8 + float(i) * 1.4, 0.80, sin(float(i) * 1.7) * 1.7)
		var gate := torus(root, "SqueezeGate%02d" % i, gate_pos, Vector3(0.62, 0.62, 0.30), Color("#d58bb2"), Vector3(PI * 0.5, 0, 0))
		gate.set_meta("phase", float(i) * 0.62)
		gate.set_meta("base_scale", gate.scale)
	for i in range(8):
		var mucus := sphere(root, "GutMucusPearl%02d" % i, center + Vector3(-3.0 + float(i) * 0.86, 0.64, sin(float(i) * 1.3) * 2.2), Vector3(0.22, 0.09, 0.32), Color("#fb8bc4"), 0.58, 0.55)
		mucus.set_meta("phase", float(i) * 0.44)
	var drum := make_prop(root, "PeristalsisDrum", center + Vector3(2.7, 0.48, -2.0), Color("#ff8caf"), "gut_drum", "F  PERISTALSIS DRUM")
	props.append(drum)
	specs.append({"kind":"PARASITE","pos":center+Vector3(-1.5,0.65,-1.0),"display_name":"GUT GNAWER","accent":Color("#d89a62"),"hp":142.0,"speed":2.7,"territory":"INTESTINAL MAZE","trait":"gnaw"})
	specs.append({"kind":"PLATELET","pos":center+Vector3(1.2,0.65,1.3),"display_name":"BILE BOUNCER","accent":Color("#d1db61"),"hp":76.0,"speed":3.7,"territory":"INTESTINAL MAZE","trait":"gnaw"})

static func _build_lung_chamber(root: Node3D, props: Array[Node3D], specs: Array[Dictionary]) -> void:
	var center := Vector3(-18.0, 0.0, 8.8)
	static_pad(root, "LungChamberShelf", center + Vector3(0, 0.22, 0), Vector3(8.0, 0.44, 6.4), Color("#574c7d"))
	zone_label(root, "7  LUNG CHAMBER", center + Vector3(0, 4.5, 0), Color("#9eeaff"))
	zone_light(root, "LungChamberLight", center + Vector3(0, 3.1, 0), Color("#8edfff"))
	for i in range(16):
		var a := TAU * float(i) / 16.0
		var radius := 3.7 + float(i % 2) * 0.16
		var bubble := sphere(root, "Alveolus%02d" % i, center + Vector3(cos(a) * radius, 1.0 + float(i % 3) * 0.58, sin(a) * radius * 0.70), Vector3.ONE * (0.72 + float(i % 3) * 0.22), Color("#ffb7df") if i % 2 == 0 else Color("#b9dcff"), 0.58, 0.55)
		bubble.set_meta("phase", float(i) * 0.39)
		bubble.set_meta("base_scale", bubble.scale)
	for i in range(5):
		var pad_pos := center + Vector3(-2.8 + float(i) * 1.4, 0.58 + float(i % 2) * 0.34, -1.7 + float(i % 3) * 1.55)
		static_pad(root, "BubblePad%02d" % i, pad_pos, Vector3(1.05, 0.18, 1.05), Color("#a78bc4"))
		sphere(root, "BubblePadSkin%02d" % i, pad_pos + Vector3(0,0.14,0), Vector3(1.15,0.22,1.15), Color("#c8e5ff"), 0.72, 0.70)
	var bellows := make_prop(root, "AlveoliBellows", center + Vector3(-2.6, 0.45, 1.8), Color("#9eeaff"), "bellows", "F  ALVEOLI BELLOWS")
	props.append(bellows)
	specs.append({"kind":"PARASITE","pos":center+Vector3(-0.8,0.65,-1.1),"display_name":"BUBBLE LEECH","accent":Color("#8cdfff"),"hp":118.0,"speed":2.9,"territory":"LUNG CHAMBER","trait":"bounce"})
	specs.append({"kind":"HAIRBALL","pos":center+Vector3(1.7,0.65,1.0),"display_name":"POLLEN PUFF","accent":Color("#f2a6d5"),"hp":82.0,"speed":3.0,"territory":"LUNG CHAMBER","trait":"bounce"})
static func _build_nerve_highway(root: Node3D, props: Array[Node3D], specs: Array[Dictionary]) -> void:
	var center := Vector3(0.0, 0.0, -11.2)
	static_pad(root, "NerveHighwayShelf", center + Vector3(0, 0.20, 0), Vector3(15.8, 0.40, 4.8), Color("#34275d"))
	zone_label(root, "8  NERVE HIGHWAY", center + Vector3(0, 4.2, 0), Color("#70b9ff"))
	zone_light(root, "NerveHighwayLight", center + Vector3(0, 2.8, 0), Color("#6b82ff"))
	for i in range(15):
		var x := -6.5 + float(i) * 0.93
		var z := sin(float(i) * 0.72) * 0.68
		var node := sphere(root, "SynapseNode%02d" % i, center + Vector3(x, 0.72, z), Vector3.ONE * (0.24 + float(i % 3) * 0.065), Color("#659cff"), 0.90, 2.0)
		node.set_meta("phase", float(i) * 0.31)
		node.set_meta("base_scale", node.scale)
		if i < 14:
			var next_x := -6.5 + float(i + 1) * 0.93
			var next_z := sin(float(i + 1) * 0.72) * 0.68
			var mid := Vector3((x + next_x) * 0.5, 0.66, (z + next_z) * 0.5)
			var length := Vector2(next_x - x, next_z - z).length()
			var axon := cylinder(root, "Axon%02d" % i, center + mid, Vector3(0.055, length, 0.055), Color("#845cff"), Vector3(0, atan2(next_z - z, next_x - x), PI * 0.5), 0.88, 1.3)
			axon.set_meta("phase", float(i) * 0.27)
	var relay := make_prop(root, "NerveFastTravelRelay", center + Vector3(-5.8, 0.44, -1.2), Color("#6fe4ff"), "relay_to_forest", "F  NERVE FAST TRAVEL")
	props.append(relay)
	for i in range(6):
		var hazard := cylinder(root, "StaticArc%02d" % i, center + Vector3(-4.0 + float(i) * 1.55, 1.25, 1.3), Vector3(0.035, 0.72, 0.035), Color("#b889ff"), Vector3(0,0,PI*0.5), 0.64, 2.0)
		hazard.set_meta("phase", float(i) * 0.73)
	specs.append({"kind":"PLATELET","pos":center+Vector3(-2.4,0.65,0.4),"display_name":"STATIC TICK","accent":Color("#7eb8ff"),"hp":72.0,"speed":4.1,"territory":"NERVE HIGHWAY","trait":"shock"})
	specs.append({"kind":"PARASITE","pos":center+Vector3(3.2,0.65,-0.4),"display_name":"AXON CHEWER","accent":Color("#a278ff"),"hp":132.0,"speed":3.2,"territory":"NERVE HIGHWAY","trait":"shock"})
static func decorate_enemy(enemy: CharacterBody3D, display_name: String, accent: Color, behavior: String) -> void:
	enemy.set_meta("display_name", display_name)
	enemy.set_meta("biome_trait", behavior)
	var label := enemy.get_meta("hp_label") as Label3D
	if label:
		label.text = "%s\n%d/%d" % [display_name, int(enemy.get_meta("hp")), int(enemy.get_meta("max_hp"))]
	match behavior:
		"tangle":
			for side in [-1.0, 1.0]:
				capsule(enemy, "FurAntenna", Vector3(0.32 * side, 1.24, 0), Vector3(0.07,0.42,0.07), accent, Vector3(0,0,side*0.34))
			torus(enemy, "CombSnare", Vector3(0,0.76,0.25), Vector3(0.62,0.18,0.62), accent.lightened(0.18), Vector3(PI*0.5,0,0))
		"gnaw":
			for side in [-1.0, 1.0]:
				capsule(enemy, "GnawTooth", Vector3(0.18*side,0.62,-0.58), Vector3(0.10,0.28,0.10), Color("#fff0c7"), Vector3(0.38,0,side*0.15))
			sphere(enemy, "BileSac", Vector3(0,0.76,0.46), Vector3(0.45,0.28,0.30), accent, 0.62, 0.55)
		"bounce":
			for side in [-1.0, 1.0]:
				sphere(enemy, "AirSac", Vector3(0.44*side,0.92,0.10), Vector3.ONE*0.34, accent, 0.36, 0.50)
			torus(enemy, "SuctionMouth", Vector3(0,0.58,-0.55), Vector3(0.28,0.28,0.12), accent.darkened(0.20), Vector3(PI*0.5,0,0))
		"shock":
			for side in [-1.0, 1.0]:
				torus(enemy, "StaticCoil", Vector3(0.40*side,0.96,0), Vector3.ONE*0.24, accent, Vector3(PI*0.5,0,0), 1.0, 1.5)
			sphere(enemy, "ChargeNode", Vector3(0,1.30,0), Vector3.ONE*0.18, Color("#e8f2ff"), 1.0, 2.2)
static func animate(root: Node3D, props: Array[Node3D], time: float, delta: float, danger := 0.0) -> void:
	if not is_instance_valid(root):
		return
	for child in root.get_children():
		if child is MeshInstance3D:
			var item := child as MeshInstance3D
			var phase := float(item.get_meta("phase", 0.0))
			if item.name.begins_with("TangledHair") or item.name.begins_with("HairBridge"):
				var base: Vector3 = item.get_meta("base_rotation", item.rotation)
				item.rotation.z = base.z + sin(time * 1.15 + phase) * 0.10
			elif item.name.begins_with("HairCocoon"):
				item.rotation.y += sin(time * 0.55 + phase) * 0.0015
			elif item.name.begins_with("HiddenFurItem") or item.name.begins_with("SynapseNode"):
				var base_scale: Vector3 = item.get_meta("base_scale", item.scale)
				item.scale = base_scale * (1.0 + sin(time * 2.8 + phase) * 0.10)
			elif item.name.begins_with("GutLoop") or item.name.begins_with("SqueezeGate"):
				var base_scale: Vector3 = item.get_meta("base_scale", item.scale)
				var pulse := 1.0 + sin(time * (1.25 + danger * 0.25) + phase) * 0.07
				item.scale = Vector3(base_scale.x * pulse, base_scale.y * (2.0 - pulse), base_scale.z)
			elif item.name.begins_with("Alveolus"):
				var base_scale: Vector3 = item.get_meta("base_scale", item.scale)
				item.scale = base_scale * (1.0 + sin(time * 0.92 + phase) * 0.08)
			elif item.name.begins_with("StaticArc") or item.name.begins_with("Axon"):
				item.visible = sin(time * 5.0 + phase) > -0.36
	for prop in props:
		if not is_instance_valid(prop):
			continue
		var cooldown := maxf(0.0, float(prop.get_meta("cooldown", 0.0)) - delta)
		prop.set_meta("cooldown", cooldown)
		var ring := prop.get_meta("ring") as Node3D
		if ring:
			ring.rotation.y += 0.018 + danger * 0.008
			ring.scale = Vector3.ONE * (1.0 + sin(time * 2.2 + float(prop.get_index())) * 0.08)
		var label := prop.get_meta("label") as Label3D
		if label:
			label.modulate.a = 0.38 if cooldown > 0.0 else 1.0

# GODOT_ORGAN_WORLD_V1
