extends RefCounted

static func mat(color: Color, alpha: float = 1.0, glow: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(color.r, color.g, color.b, alpha)
	m.roughness = 0.86
	if alpha < 0.999:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if glow > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = glow
	return m

static func sphere(root: Node3D, name: String, pos: Vector3, scale_v: Vector3, color: Color, alpha: float = 1.0, glow: float = 0.0) -> MeshInstance3D:
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
static func cylinder(root: Node3D, name: String, a: Vector3, b: Vector3, radius: float, color: Color, alpha: float = 1.0, glow: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.5
	mesh.bottom_radius = 0.5
	mesh.height = 1.0
	mi.mesh = mesh
	var dir: Vector3 = b - a
	var length: float = maxf(0.001, dir.length())
	mi.position = (a + b) * 0.5
	mi.basis = Basis(Quaternion(Vector3.UP, dir.normalized()))
	mi.scale = Vector3(radius * 2.0, length, radius * 2.0)
	mi.material_override = mat(color, alpha, glow)
	root.add_child(mi)
	return mi

static func torus(root: Node3D, name: String, pos: Vector3, scale_v: Vector3, color: Color, alpha: float = 1.0, glow: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.62
	mesh.outer_radius = 1.0
	mi.mesh = mesh
	mi.position = pos
	mi.scale = scale_v
	mi.rotation.x = 0.0
	mi.material_override = mat(color, alpha, glow)
	root.add_child(mi)
	return mi
static func _fade_free(node: Node3D, duration: float, end_scale: Vector3 = Vector3.ZERO) -> void:
	var tw := node.create_tween()
	tw.tween_property(node, "scale", end_scale, duration)
	tw.tween_callback(node.queue_free)

static func _burst(root: Node3D, pos: Vector3, color: Color, count: int, radius: float) -> void:
	for i in range(count):
		var a: float = TAU * float(i) / float(maxi(count, 1))
		var p := pos + Vector3(cos(a) * radius, 0.12 + float(i % 3) * 0.08, sin(a) * radius)
		var bead := sphere(root, "VFXBurst", pos, Vector3.ONE * 0.09, color, 0.78, 2.8)
		var tw := root.create_tween()
		tw.set_parallel(true)
		tw.tween_property(bead, "position", p, 0.22)
		tw.tween_property(bead, "scale", Vector3.ZERO, 0.22)
		tw.chain().tween_callback(bead.queue_free)

static func spawn_cast(parent: Node3D, role: int, slot: int, origin: Vector3, forward: Vector3, target: Vector3) -> void:
	match role:
		0: _spark(parent, slot, origin, forward, target)
		1: _kaka(parent, slot, origin, forward, target)
		2: _bubble(parent, slot, origin, forward, target)
		3: _shroom(parent, slot, origin, forward, target)

static func spawn_hit(parent: Node3D, pos: Vector3, color: Color, role: int = -1) -> void:
	var ring := torus(parent, "HitRing", pos, Vector3.ONE * 0.18, color, 0.55, 2.5)
	var tw := parent.create_tween()
	tw.tween_property(ring, "scale", Vector3.ONE * 1.05, 0.14)
	tw.tween_property(ring, "scale", Vector3.ZERO, 0.08)
	tw.tween_callback(ring.queue_free)
	match role:
		0:
			for a in [-0.55,0.55]:
				var tip := pos + Vector3(a,0.45,0.35)
				var arc := cylinder(parent,"HitArc",pos,tip,0.035,Color("#fff3a1"),0.9,4.0)
				_fade_free(arc,0.14)
			_burst(parent,pos,Color("#ffe65b"),6,0.72)
		1:
			for i in range(5):
				var a := TAU*float(i)/5.0
				var tip := pos + Vector3(cos(a)*0.58,0.35,sin(a)*0.58)
				var chip := cylinder(parent,"BoneChip",pos,tip,0.045,Color("#f4ead4"),1.0,0.55)
				_fade_free(chip,0.20)
			_burst(parent,pos,Color("#f1a047"),7,0.65)
		2:
			_burst(parent,pos,Color("#7ce9ff"),10,0.85)
			_burst(parent,pos+Vector3.UP*0.08,Color("#ff7aa8"),5,0.55)
		3:
			_burst(parent,pos,Color("#a7f2b7"),11,0.82)
			_burst(parent,pos+Vector3.UP*0.12,Color("#ad7af0"),6,0.58)
		_:
			_burst(parent,pos,color,7,0.75)
static func _spark(parent: Node3D, slot: int, origin: Vector3, forward: Vector3, target: Vector3) -> void:
	var yellow := Color("#ffe65b")
	var white := Color("#fff8bf")
	if slot == 0:
		var root := Node3D.new()
		root.name = "SparkWireVFX"
		parent.add_child(root)
		var end: Vector3 = target
		var prev: Vector3 = origin
		for i in range(7):
			var t: float = float(i + 1) / 7.0
			var p: Vector3 = origin.lerp(end, t)
			p += Vector3(sin(float(i) * 2.1) * 0.18, cos(float(i) * 1.7) * 0.12, sin(float(i) * 1.3) * 0.12)
			cylinder(root, "Lightning", prev, p, 0.055 if i % 2 == 0 else 0.035, yellow if i % 2 == 0 else white, 0.9, 4.5)
			prev = p
		_burst(parent, end, yellow, 9, 1.0)
		root.scale = Vector3.ONE * 0.15
		var tw := parent.create_tween()
		tw.tween_property(root, "scale", Vector3.ONE, 0.08)
		tw.tween_interval(0.11)
		tw.tween_property(root, "scale", Vector3.ZERO, 0.07)
		tw.tween_callback(root.queue_free)
	else:
		for i in range(3):
			var ring := torus(parent, "OverloadRing", origin, Vector3.ONE * (0.25 + i * 0.10), yellow, 0.36, 2.5)
			var tw := parent.create_tween()
			tw.tween_property(ring, "scale", Vector3.ONE * (1.75 + i * 0.68), 0.24 + i * 0.05)
			tw.tween_property(ring, "scale", Vector3.ZERO, 0.10)
			tw.tween_callback(ring.queue_free)
		_burst(parent, origin + Vector3.UP * 0.12, white, 10, 1.65)
static func _kaka(parent: Node3D, slot: int, origin: Vector3, forward: Vector3, target: Vector3) -> void:
	var bone := Color("#f5ead5")
	var orange := Color("#f1a047")
	if slot == 0:
		origin -= Vector3.UP * 0.78
		var root := Node3D.new()
		root.name = "BoneGrowthVFX"
		parent.add_child(root)
		for i in range(6):
			var p: Vector3 = origin + forward * (1.1 + float(i) * 0.8)
			var spike := cylinder(root, "BoneSpike", p, p + Vector3.UP * (0.75 + float(i % 3) * 0.18), 0.15 + float(i % 2) * 0.04, bone, 1.0, 0.62)
			spike.scale *= Vector3(1.0, 0.08, 1.0)
			var tw := parent.create_tween()
			tw.tween_interval(float(i) * 0.025)
			tw.tween_property(spike, "scale", spike.scale * Vector3(1.0, 12.5, 1.0), 0.16)
		_burst(parent, origin + forward * 2.8, orange, 14, 1.65)
		parent.get_tree().create_timer(0.90).timeout.connect(root.queue_free)
	else:
		var start: Vector3 = origin + Vector3.UP * 0.15
		var pin := cylinder(parent, "BonePinVFX", start, target, 0.13, bone, 1.0, 1.2)
		var tw := parent.create_tween()
		tw.tween_property(pin, "scale", pin.scale * Vector3(1.25, 1.0, 1.25), 0.08)
		tw.tween_property(pin, "scale", Vector3.ZERO, 0.13)
		tw.tween_callback(pin.queue_free)
		for i in range(4):
			var a: float = TAU * float(i) / 4.0
			var tip := target + Vector3(cos(a) * 0.75, 0.0, sin(a) * 0.75)
			var shard := cylinder(parent, "PinImpact", target, tip + Vector3.UP * 0.18, 0.055, orange, 0.9, 1.8)
			_fade_free(shard, 0.24)
static func _bubble(parent: Node3D, slot: int, origin: Vector3, forward: Vector3, target: Vector3) -> void:
	var cyan := Color("#6be4ff")
	var pink := Color("#ff729f")
	if slot == 0:
		origin -= Vector3.UP * 0.72
		for i in range(10):
			var p: Vector3 = origin + forward * (0.8 + float(i) * 0.7)
			var drop := sphere(parent, "PlasmaDrop", p, Vector3(0.18, 0.09, 0.28), cyan if i % 2 == 0 else pink, 0.58, 1.8)
			drop.position.x += sin(float(i) * 1.5) * 0.32
			var tw := parent.create_tween()
			tw.set_parallel(true)
			tw.tween_property(drop, "position", drop.position + forward * 1.25, 0.34)
			tw.tween_property(drop, "scale", Vector3.ZERO, 0.34)
			tw.chain().tween_callback(drop.queue_free)
		var wave := torus(parent, "PlasmaWave", origin + forward * 2.8, Vector3(0.8,0.20,1.6), cyan, 0.42, 2.4)
		_fade_free(wave, 0.30, Vector3(2.0,0.08,3.6))
	else:
		var shell := sphere(parent, "EngulfShell", origin, Vector3.ONE * 0.28, cyan, 0.26, 1.5)
		var core := sphere(parent, "EngulfCore", origin, Vector3.ONE * 0.18, pink, 0.48, 2.2)
		var tw := parent.create_tween()
		tw.set_parallel(true)
		tw.tween_property(shell, "scale", Vector3.ONE * 1.8, 0.24)
		tw.tween_property(core, "scale", Vector3.ONE * 0.75, 0.24)
		tw.chain().tween_property(shell, "scale", Vector3.ZERO, 0.12)
		tw.tween_property(core, "scale", Vector3.ZERO, 0.12)
		tw.chain().tween_callback(shell.queue_free)
		tw.tween_callback(core.queue_free)
static func _shroom(parent: Node3D, slot: int, origin: Vector3, forward: Vector3, target: Vector3) -> void:
	var mint := Color("#9df3c5")
	var purple := Color("#b47cff")
	if slot == 0:
		origin -= Vector3.UP * 0.78
		for i in range(12):
			var a: float = TAU * float(i) / 12.0
			var p := origin + Vector3(cos(a) * (0.6 + float(i % 3) * 0.35), 0.04, sin(a) * (0.6 + float(i % 3) * 0.35))
			var spore := sphere(parent, "Spore", p, Vector3.ONE * (0.10 + float(i % 2) * 0.04), mint if i % 2 == 0 else purple, 0.62, 1.6)
			var tw := parent.create_tween()
			tw.tween_property(spore, "position:y", 0.55 + float(i % 4) * 0.10, 0.32)
			tw.tween_property(spore, "scale", Vector3.ZERO, 0.16)
			tw.tween_callback(spore.queue_free)
		for i in range(3):
			var ring := torus(parent, "FungusPulse", origin, Vector3.ONE * (0.25 + i * 0.14), mint if i % 2 == 0 else purple, 0.36, 1.9)
			var tw := parent.create_tween()
			tw.tween_interval(float(i) * 0.04)
			tw.tween_property(ring, "scale", Vector3.ONE * (1.6 + i * 0.55), 0.26)
			tw.tween_property(ring, "scale", Vector3.ZERO, 0.09)
			tw.tween_callback(ring.queue_free)
	else:
		var center: Vector3 = target if origin.distance_to(target) < 7.5 else origin
		for i in range(10):
			var a: float = TAU * float(i) / 10.0
			var p := center + Vector3(cos(a) * 0.85, 0.25 + float(i % 3) * 0.18, sin(a) * 0.85)
			var spore := sphere(parent, "FermentSpore", p, Vector3.ONE * 0.13, purple, 0.62, 2.0)
			var tw := parent.create_tween()
			tw.tween_property(spore, "position", center + Vector3.UP * 1.25, 0.34)
			tw.tween_property(spore, "scale", Vector3.ZERO, 0.10)
			tw.tween_callback(spore.queue_free)
		var ring := torus(parent, "FermentRing", center, Vector3.ONE * 0.3, purple, 0.48, 2.5)
		_fade_free(ring, 0.38, Vector3.ONE * 2.0)
static func decorate_bone(root: Node3D, boosted: bool) -> void:
	var bone := Color("#f4ead6")
	var orange := Color("#e99b47")
	var extent: float = 3.35 if boosted else 2.75
	for sx in [-0.28,0.28]:
		cylinder(root,"BoneRail",Vector3(sx,0.36,-extent),Vector3(sx,0.36,extent),0.14 if boosted else 0.11,bone,1.0,0.22)
	for i in range(6):
		var z: float = -2.7 + float(i) * 1.05
		var rib := sphere(root, "BoneKnuckle", Vector3(0, 0.42, z), Vector3(0.48 if boosted else 0.38, 0.24, 0.32), bone, 1.0, 0.18)
		rib.rotation.y = float(i % 2) * 0.2
		if i % 2 == 0:
			sphere(root, "BoneNode", Vector3(0, 0.72, z), Vector3(0.16,0.16,0.16), orange, 1.0, 0.35)

static func decorate_lane(root: Node3D, bone_sync: bool) -> void:
	var red := Color("#ff4f78")
	var cyan := Color("#78e9ff")
	for i in range(12):
		var z: float = -3.2 + float(i) * 0.58
		var x: float = sin(float(i) * 1.45) * 0.36
		var drop := sphere(root, "FlowBead", Vector3(x, 0.12, z), Vector3(0.22,0.08,0.34), cyan if bone_sync and i % 3 == 0 else red, 0.52, 1.5)
		drop.set_meta("flow_phase", float(i) * 0.32)
		drop.set_meta("base_z", z)
	for sx in [-1.0, 1.0]:
		var rail_x: float = sx * (0.82 if bone_sync else 0.62)
		cylinder(root, "PlasmaRail", Vector3(rail_x,0.10,-3.2), Vector3(rail_x,0.10,3.2), 0.045, cyan if bone_sync else red, 0.58, 1.7)

static func decorate_fungus(root: Node3D, blood_sync: bool) -> void:
	var mint := Color("#a3f3ba")
	var purple := Color("#a875e9")
	for i in range(14):
		var a: float = TAU * float(i) / 14.0
		var r: float = 1.1 + float(i % 4) * 0.42
		var p := Vector3(cos(a) * r, 0.10, sin(a) * r)
		var cap := sphere(root, "PatchSpore", p, Vector3(0.22,0.10,0.22), purple if i % 3 == 0 else mint, 0.72, 0.65)
		cap.set_meta("spore_phase", float(i) * 0.41)
	for i in range(6):
		var a: float = TAU * float(i) / 6.0
		var p := Vector3(cos(a)*1.65,0.08,sin(a)*1.65)
		cylinder(root,"MiniShroomStem",p,p+Vector3.UP*0.28,0.055,mint,0.92,0.15)
		sphere(root,"MiniShroomCap",p+Vector3.UP*0.31,Vector3(0.22,0.09,0.22),purple,0.78,0.35)
	if blood_sync:
		var ring := torus(root, "BioFlowRing", Vector3(0,0.11,0), Vector3.ONE * 1.55, Color("#ff7092"), 0.34, 1.3)
		ring.scale.y = 0.18

# GODOT_SKILL_VFX_V1
static func animate_zone(root: Node3D, time: float, charged: bool = false) -> void:
	if not is_instance_valid(root): return
	for child in root.get_children():
		if not (child is MeshInstance3D): continue
		var mi := child as MeshInstance3D
		if mi.name == "FlowBead":
			var phase: float = float(mi.get_meta("flow_phase", 0.0))
			var z0: float = float(mi.get_meta("base_z", mi.position.z))
			mi.position.z = z0 + fmod(time * (1.8 if charged else 1.25) + phase, 0.58) - 0.29
			mi.position.y = 0.12 + sin(time * 5.2 + phase) * 0.035
		elif mi.name == "PatchSpore":
			var phase: float = float(mi.get_meta("spore_phase", 0.0))
			mi.position.y = 0.10 + absf(sin(time * (3.2 if charged else 2.4) + phase)) * 0.15
			var sm := mi.material_override as StandardMaterial3D
			if sm: sm.emission_energy_multiplier = (1.35 if charged else 0.65) + absf(sin(time * 3.0 + phase)) * 0.35
		elif mi.name == "PlasmaRail":
			var rm := mi.material_override as StandardMaterial3D
			if rm: rm.emission_energy_multiplier = (2.8 if charged else 1.7) + sin(time * 4.4) * 0.25

# GODOT_SKILL_VFX_ZONE_ANIM

# GODOT_VFX_BALANCE_V3

# GODOT_ENEMY_ANIM_KAKA_READABILITY

# GODOT_HIT_VFX_V2

static func spawn_sync(parent: Node3D, pos: Vector3, chain: int, color_a: Color, color_b: Color) -> void:
	var size: float = 1.15 + float(chain) * 0.13
	for i in range(2):
		var col: Color = color_a if i == 0 else color_b
		var ring := torus(parent, "SyncRing", pos + Vector3.UP * 0.08, Vector3.ONE * (0.22 + i * 0.06), col, 0.62, 2.6)
		var tw := parent.create_tween()
		tw.tween_property(ring, "scale", Vector3.ONE * (size + i * 0.22), 0.24 + i * 0.04)
		tw.tween_property(ring, "scale", Vector3.ZERO, 0.10)
		tw.tween_callback(ring.queue_free)
	for i in range(8 + mini(chain, 4) * 2):
		var a: float = TAU * float(i) / float(8 + mini(chain, 4) * 2)
		var col: Color = color_a if i % 2 == 0 else color_b
		var bead := sphere(parent, "SyncBead", pos + Vector3.UP * 0.55, Vector3.ONE * 0.07, col, 0.88, 3.2)
		var target := pos + Vector3(cos(a) * size, 0.18 + float(i % 3) * 0.15, sin(a) * size)
		var tw := parent.create_tween()
		tw.set_parallel(true)
		tw.tween_property(bead, "position", target, 0.28)
		tw.tween_property(bead, "scale", Vector3.ZERO, 0.28)
		tw.chain().tween_callback(bead.queue_free)
	var core := sphere(parent, "SyncCore", pos + Vector3.UP * 0.48, Vector3.ONE * 0.22, color_a.lerp(color_b, 0.5), 0.50, 4.2)
	_fade_free(core, 0.30, Vector3.ONE * (1.35 + float(chain) * 0.08))

# GODOT_SYNC_VFX_V1
