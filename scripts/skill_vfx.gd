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

static func spawn_landing(parent: Node3D, pos: Vector3, color: Color) -> void:
	var ring := torus(parent,"LandingClayRing",pos + Vector3.UP*0.035,Vector3.ONE*0.14,color,0.42,1.6)
	var tw := parent.create_tween()
	tw.tween_property(ring,"scale",Vector3.ONE*0.88,0.16)
	tw.tween_property(ring,"scale",Vector3.ZERO,0.10)
	tw.tween_callback(ring.queue_free)
	for i in range(6):
		var a: float = TAU * float(i) / 6.0
		var bead := sphere(parent,"LandingClayBit",pos+Vector3(cos(a)*0.18,0.05,sin(a)*0.18),Vector3(0.10,0.035,0.10),color,0.55,0.8)
		var target := pos + Vector3(cos(a)*0.72,0.03,sin(a)*0.72)
		var bt := parent.create_tween()
		bt.set_parallel(true)
		bt.tween_property(bead,"position",target,0.20)
		bt.tween_property(bead,"scale",Vector3.ZERO,0.20)
		bt.chain().tween_callback(bead.queue_free)

static func spawn_sync_pair(parent: Node3D, pos: Vector3, chain: int, role_a: int, role_b: int, color_a: Color, color_b: Color) -> void:
	spawn_sync(parent,pos,chain,color_a,color_b)
	var lo: int = mini(role_a,role_b)
	var hi: int = maxi(role_a,role_b)
	var pair: int = lo * 10 + hi
	var power: float = 1.0 + minf(float(chain),4.0) * 0.10
	if pair == 1:
		for i in range(4):
			var a: float = TAU * float(i) / 4.0
			var base := pos + Vector3(cos(a)*0.44,0.03,sin(a)*0.44)
			var spike := cylinder(parent,"SyncBoneLightning",base,base+Vector3.UP*(0.72+float(i%2)*0.18),0.06,Color("#fff0bd") if i%2==0 else Color("#ffe84f"),0.92,2.4)
			_fade_free(spike,0.34,Vector3.ONE*0.04)
	elif pair == 2:
		for i in range(8):
			var a: float = TAU * float(i) / 8.0
			var bead := sphere(parent,"SyncPlasmaSpark",pos+Vector3(cos(a)*0.55,0.18+float(i%2)*0.18,sin(a)*0.55),Vector3.ONE*0.10,Color("#76eaff") if i%2==0 else Color("#ffe75a"),0.82,3.0)
			_fade_free(bead,0.34,Vector3.ONE*(0.28*power))
	elif pair == 3:
		for i in range(7):
			var a: float = TAU * float(i) / 7.0
			var spore := sphere(parent,"SyncElectricSpore",pos+Vector3(cos(a)*0.62,0.16+float(i%3)*0.12,sin(a)*0.62),Vector3.ONE*0.09,Color("#a7f5b8") if i%2==0 else Color("#ffe75a"),0.78,2.8)
			_fade_free(spore,0.38,Vector3.ONE*(0.22*power))
	elif pair == 12:
		for sx in [-0.34,0.34]:
			var rail := cylinder(parent,"SyncBonePlasmaRail",pos+Vector3(sx,0.08,-0.82),pos+Vector3(sx,0.08,0.82),0.055,Color("#f6ead2") if sx < 0.0 else Color("#72e8ff"),0.88,2.2)
			_fade_free(rail,0.38,Vector3.ONE*0.06)
	elif pair == 13:
		var stalk := cylinder(parent,"SyncFungusBone",pos+Vector3.UP*0.02,pos+Vector3.UP*(1.05*power),0.075,Color("#f4ead4"),0.90,1.8)
		_fade_free(stalk,0.42,Vector3.ONE*0.05)
		for i in range(6):
			var a: float = TAU * float(i) / 6.0
			var cap := sphere(parent,"SyncBoneSpore",pos+Vector3(cos(a)*0.38,0.28+float(i%3)*0.22,sin(a)*0.38),Vector3(0.12,0.07,0.12),Color("#a977e8"),0.78,2.0)
			_fade_free(cap,0.40,Vector3.ONE*0.20)
	elif pair == 23:
		var dome := sphere(parent,"SyncPlasmaFungusDome",pos+Vector3.UP*0.42,Vector3(1.05,0.55,1.05)*power,Color("#9eead0"),0.16,1.2)
		_fade_free(dome,0.42,Vector3.ONE*0.25)
		for i in range(7):
			var a: float = TAU * float(i) / 7.0
			var spore := sphere(parent,"SyncPlasmaSpore",pos+Vector3(cos(a)*0.72,0.16,sin(a)*0.72),Vector3.ONE*0.08,Color("#c68cff") if i%2==0 else Color("#75e7ff"),0.76,2.2)
			_fade_free(spore,0.36,Vector3.ONE*0.18)

# GODOT_PHASE6_LANDING_SYNC_PAIR_VFX

static func spawn_ko_splat(parent: Node3D, pos: Vector3, color: Color) -> void:
	var puddle := sphere(parent,"KOPuddle",pos + Vector3.UP*0.035,Vector3(0.72,0.055,0.58),color,0.52,0.8)
	var tw := parent.create_tween()
	tw.tween_property(puddle,"scale",Vector3(1.25,0.75,1.15),0.16)
	tw.tween_interval(0.48)
	tw.tween_property(puddle,"scale",Vector3.ZERO,0.20)
	tw.tween_callback(puddle.queue_free)
	for i in range(7):
		var a: float = TAU * float(i) / 7.0
		var bit := sphere(parent,"KOClayBit",pos+Vector3.UP*0.08,Vector3.ONE*0.09,color,0.68,1.0)
		var target := pos + Vector3(cos(a)*(0.45+float(i%2)*0.18),0.05,sin(a)*(0.45+float(i%3)*0.12))
		var bt := parent.create_tween()
		bt.set_parallel(true)
		bt.tween_property(bit,"position",target,0.18)
		bt.tween_property(bit,"scale",Vector3.ZERO,0.55)
		bt.chain().tween_callback(bit.queue_free)

# GODOT_PHASE6_KO_SPLAT

static func spawn_dodge_success(parent: Node3D, pos: Vector3, color: Color) -> void:
	var ring := torus(parent,"PerfectDodgeRing",pos+Vector3.UP*0.08,Vector3.ONE*0.18,color,0.72,3.0)
	var tw := parent.create_tween()
	tw.tween_property(ring,"scale",Vector3.ONE*0.92,0.20)
	tw.tween_property(ring,"scale",Vector3.ZERO,0.08)
	tw.tween_callback(ring.queue_free)
	for i in range(6):
		var a: float = TAU*float(i)/6.0
		var bead := sphere(parent,"DodgeClayBead",pos+Vector3(cos(a)*0.22,0.32,sin(a)*0.22),Vector3.ONE*0.07,color,0.82,2.1)
		_fade_free(bead,0.22,Vector3.ONE*0.16)

static func spawn_body_event(parent: Node3D, kind: String, dir: float = 1.0) -> void:
	var spread := Vector3.ONE
	if parent.has_method("world_point"): spread = parent.world_point(Vector3.ONE)
	var col: Color = Color("#c9ff45") if kind == "acid" else (Color("#77dcff") if kind == "drink" else Color("#ff86ad"))
	var center := Vector3(0,0.10,4.8) if kind == "acid" else Vector3.ZERO
	center *= spread
	for i in range(2 if kind != "drink" else 3):
		var ring := torus(parent,"BodyEventRing",center+Vector3.UP*float(i)*0.08,Vector3.ONE*(0.28+float(i)*0.08),col,0.42,2.4)
		var tw := parent.create_tween()
		tw.tween_property(ring,"scale",spread*(4.2+float(i)*1.1),0.42+float(i)*0.08)
		tw.tween_property(ring,"scale",Vector3.ZERO,0.12)
		tw.tween_callback(ring.queue_free)
	if kind == "drink":
		for i in range(10):
			var bead := sphere(parent,"SwallowDrop",Vector3(-8.0*dir,0.35+float(i%3)*0.22,-5.0+float(i)*1.0),Vector3(0.16,0.10,0.22),col,0.52,1.6)
			bead.position *= spread
			var t := parent.create_tween(); t.tween_property(bead,"position:x",8.0*dir*spread.x,0.72); t.tween_callback(bead.queue_free)

# GODOT_PHASE7_DODGE_BODY_VFX

# GODOT_PHASE9_COMBAT_VFX
static func spawn_basic_attack(parent: Node3D, role: int, heavy: bool, origin: Vector3, target: Vector3) -> void:
	var colors := [Color("#ffe65b"), Color("#f4ead4"), Color("#63dcff"), Color("#b989ff")]
	var color: Color = colors[clampi(role, 0, 3)]
	var root := Node3D.new()
	root.name = "HeavyAttackVFX" if heavy else "PrimaryAttackVFX"
	parent.add_child(root)
	var trail := cylinder(root, "AttackTrail", origin, target, 0.095 if heavy else 0.045, color, 0.76, 3.5 if heavy else 2.2)
	var muzzle := sphere(root, "AttackMuzzle", origin, Vector3.ONE * (0.24 if heavy else 0.14), color, 0.85, 3.2)
	var tw := parent.create_tween()
	tw.set_parallel(true)
	tw.tween_property(trail, "scale", trail.scale * Vector3(0.25, 1.0, 0.25), 0.18 if heavy else 0.11)
	tw.tween_property(muzzle, "scale", Vector3.ZERO, 0.18 if heavy else 0.11)
	if heavy:
		var ring := torus(root, "HeavyRing", target, Vector3.ONE * 0.16, color, 0.62, 3.4)
		tw.tween_property(ring, "scale", Vector3.ONE * 0.52, 0.18)
	parent.get_tree().create_timer(0.24 if heavy else 0.15).timeout.connect(root.queue_free)
static func spawn_phase_blink(parent: Node3D, start: Vector3, finish: Vector3, color: Color) -> void:
	var root := Node3D.new()
	root.name = "PhaseBlinkVFX"
	parent.add_child(root)
	cylinder(root, "PhaseTunnel", start, finish, 0.16, color, 0.38, 4.8)
	for i in range(8):
		var t := float(i) / 7.0
		var bead_pos := start.lerp(finish, t)
		var bead := sphere(root, "PhaseBead", bead_pos, Vector3(0.15,0.28,0.15), color, 0.82, 4.2)
		var tw := parent.create_tween()
		tw.set_parallel(true)
		tw.tween_property(bead, "position:y", bead.position.y + 0.55, 0.24)
		tw.tween_property(bead, "scale", Vector3.ZERO, 0.24)
	for pos in [start, finish]:
		var ring := torus(root, "PhaseGate", pos, Vector3.ONE * 0.28, color, 0.75, 4.8)
		ring.rotation.x = PI * 0.5
		var gate_tw := parent.create_tween()
		gate_tw.tween_property(ring, "scale", Vector3.ONE * 1.15, 0.22)
	parent.get_tree().create_timer(0.30).timeout.connect(root.queue_free)

# GODOT_PHASE11_ROLE_COMBAT_VFX
static func spawn_arc_stream(parent: Node3D, origin: Vector3, target: Vector3, hit: bool) -> void:
	var root := Node3D.new()
	root.name = "ArcStreamVFX"
	parent.add_child(root)
	var color := Color("#fff06a")
	var beam := cylinder(root, "RapidArc", origin, target, 0.028, color, 0.82, 4.2)
	for i in range(3):
		var t := float(i + 1) / 4.0
		var p := origin.lerp(target, t)
		p += Vector3(sin(float(i) * 4.1) * 0.08, cos(float(i) * 2.7) * 0.06, 0.0)
		var bead := sphere(root, "ArcNode", p, Vector3.ONE * 0.055, color, 0.9, 4.5)
		_fade_free(bead, 0.10, Vector3.ONE * 0.12)
	var muzzle := sphere(root, "ArcMuzzle", origin, Vector3.ONE * 0.10, color, 0.9, 4.5)
	_fade_free(muzzle, 0.10, Vector3.ONE * 0.16)
	if hit:
		var snap := torus(root, "ArcSnap", target, Vector3.ONE * 0.10, color, 0.8, 4.2)
		_fade_free(snap, 0.12, Vector3.ONE * 0.32)
	parent.get_tree().create_timer(0.18).timeout.connect(root.queue_free)

static func spawn_conductive_mark(parent: Node3D, pos: Vector3, follows_enemy: bool) -> Node3D:
	var root := Node3D.new()
	root.name = "ConductiveMark"
	parent.add_child(root)
	root.global_position = pos
	var ring := torus(root, "ConductorRing", Vector3.ZERO, Vector3.ONE * 0.42, Color("#fff06a"), 0.78, 4.4)
	ring.rotation.x = PI * 0.5
	for i in range(5):
		var a := TAU * float(i) / 5.0
		sphere(root, "ConductorSpark", Vector3(cos(a) * 0.5, sin(a * 2.0) * 0.12, sin(a) * 0.5), Vector3.ONE * 0.075, Color("#fff6a5"), 0.88, 4.8)
	root.set_meta("enemy_mark", follows_enemy)
	return root
static func spawn_neural_storm(parent: Node3D, pos: Vector3, radius: float) -> void:
	var root := Node3D.new()
	root.name = "NeuralStormVFX"
	parent.add_child(root)
	for i in range(3):
		var ring := torus(root, "StormRing", pos + Vector3.UP * (0.08 + float(i) * 0.18), Vector3.ONE * 0.12, Color("#ffe65b"), 0.28, 2.4)
		var tw := parent.create_tween()
		tw.tween_interval(float(i) * 0.04)
		tw.tween_property(ring, "scale", Vector3.ONE * (radius * (0.27 + float(i) * 0.035)), 0.28)
		tw.tween_property(ring, "scale", Vector3.ZERO, 0.10)
	for i in range(12):
		var a := TAU * float(i) / 12.0
		var end := pos + Vector3(cos(a) * radius * 0.85, 0.18 + float(i % 3) * 0.22, sin(a) * radius * 0.85)
		var bolt := cylinder(root, "StormBolt", pos + Vector3.UP * 0.75, end, 0.025, Color("#fff5a0"), 0.76, 4.5)
		_fade_free(bolt, 0.24 + float(i % 2) * 0.06, Vector3.ONE * 0.08)
	parent.get_tree().create_timer(0.45).timeout.connect(root.queue_free)

static func spawn_bone_charge(parent: Node3D, pos: Vector3, count: int) -> Node3D:
	var root := Node3D.new()
	root.name = "BoneChargeOrbit"
	parent.add_child(root)
	root.global_position = pos
	for i in range(count):
		var a := TAU * float(i) / maxf(1.0, float(count))
		var anchor := Node3D.new()
		anchor.position = Vector3(cos(a) * 0.78, sin(a * 2.0) * 0.16, sin(a) * 0.78)
		anchor.rotation.y = a
		root.add_child(anchor)
		decorate_bone_nail(anchor, true)
	return root

static func decorate_bone_nail(root: Node3D, volley: bool) -> void:
	var color := Color("#f4ead4") if not volley else Color("#fff7dc")
	var shaft := cylinder(root, "BoneNail", Vector3(0,0,-0.38), Vector3(0,0,0.38), 0.065 if volley else 0.08, color, 0.96, 1.5)
	var tip := sphere(root, "BoneTip", Vector3(0,0,-0.46), Vector3(0.085,0.085,0.18), color, 0.98, 1.8)
	shaft.rotation.z += 0.015
	tip.rotation.x = PI * 0.5
static func spawn_bone_impact(parent: Node3D, pos: Vector3, enemy_hit: bool) -> void:
	var root := Node3D.new()
	root.name = "BoneImpactVFX"
	parent.add_child(root)
	var color := Color("#fff2d8") if enemy_hit else Color("#d9cbb7")
	var ring := torus(root, "BoneImpactRing", pos, Vector3.ONE * 0.15, color, 0.72, 2.2)
	_fade_free(ring, 0.22, Vector3.ONE * (0.75 if enemy_hit else 0.52))
	for i in range(6):
		var a := TAU * float(i) / 6.0
		var chip := sphere(root, "BoneChip", pos + Vector3(cos(a)*0.12,0.08,sin(a)*0.12), Vector3(0.07,0.04,0.11), color, 0.9, 1.4)
		var tw := parent.create_tween()
		tw.set_parallel(true)
		tw.tween_property(chip, "position", pos + Vector3(cos(a)*0.75,0.18+float(i%2)*0.2,sin(a)*0.75), 0.24)
		tw.tween_property(chip, "scale", Vector3.ZERO, 0.32)
	parent.get_tree().create_timer(0.38).timeout.connect(root.queue_free)

static func spawn_bone_shatter(parent: Node3D, pos: Vector3) -> void:
	var root := Node3D.new()
	root.name = "BoneShatterVFX"
	parent.add_child(root)
	var ring := torus(root, "ShatterRing", pos, Vector3.ONE * 0.14, Color("#fff4d8"), 0.62, 2.8)
	_fade_free(ring, 0.28, Vector3.ONE * 1.15)
	for i in range(10):
		var a := TAU * float(i) / 10.0
		var tip := pos + Vector3(cos(a) * 1.25, 0.18 + float(i % 3) * 0.28, sin(a) * 1.25)
		var shard := cylinder(root, "BoneShard", pos, tip, 0.035, Color("#f4ead4"), 0.92, 1.8)
		_fade_free(shard, 0.30 + float(i % 2) * 0.06, Vector3.ONE * 0.08)
	parent.get_tree().create_timer(0.42).timeout.connect(root.queue_free)

static func spawn_kaka_charge(parent: Node3D, pos: Vector3, direction: Vector3) -> void:
	var root := Node3D.new()
	root.name = "KakaChargeVFX"
	parent.add_child(root)
	for side in [-1.0, 1.0]:
		var start: Vector3 = pos + Vector3.UP * 0.65 + Vector3.RIGHT.rotated(Vector3.UP, atan2(direction.x, direction.z)) * float(side) * 0.42
		var end: Vector3 = start + direction * 2.8
		var rail := cylinder(root, "ChargeRail", start, end, 0.09, Color("#f4ead4"), 0.58, 2.2)
		_fade_free(rail, 0.34, Vector3.ONE * 0.16)
	parent.get_tree().create_timer(0.42).timeout.connect(root.queue_free)

static func spawn_hammer_slam(parent: Node3D, origin: Vector3, impact: Vector3, stage: int) -> void:
	var root := Node3D.new()
	root.name = "BoneHammerImpact32"
	parent.add_child(root)
	var bone := Color("#fff1d6")
	var hot := Color("#ffb45e")
	var trail := cylinder(root, "HammerArc", origin, impact, 0.08 + float(stage) * 0.035, bone, 0.82, 2.1 + float(stage) * 0.7)
	_fade_free(trail, 0.13 + float(stage) * 0.025, Vector3(0.18, 1.0, 0.18))
	for ring_index in range(stage):
		var ring := torus(root, "HammerShockRing", impact, Vector3.ONE * (0.12 + float(ring_index) * 0.045), hot if ring_index % 2 == 0 else bone, 0.54, 2.8)
		var tw := parent.create_tween()
		tw.tween_interval(float(ring_index) * 0.035)
		tw.tween_property(ring, "scale", Vector3.ONE * (0.75 + float(stage) * 0.32 + float(ring_index) * 0.22), 0.18)
		tw.tween_property(ring, "scale", Vector3.ZERO, 0.08)
	for i in range(4 + stage * 3):
		var a := TAU * float(i) / float(4 + stage * 3)
		var tip := impact + Vector3(cos(a) * (0.45 + stage * 0.18), 0.18 + float(i % 3) * 0.18, sin(a) * (0.45 + stage * 0.18))
		var shard := cylinder(root, "HammerBoneShard", impact, tip, 0.025 + stage * 0.008, bone, 0.88, 1.7)
		_fade_free(shard, 0.24, Vector3.ONE * 0.06)
	parent.get_tree().create_timer(0.42).timeout.connect(root.queue_free)

static func spawn_hook_chain(parent: Node3D, origin: Vector3, target: Vector3, power: float, hit: bool) -> void:
	var root := Node3D.new()
	root.name = "AimedBoneHook32"
	parent.add_child(root)
	var links := 7 + int(power * 7.0)
	for i in range(links):
		var a := float(i) / float(links)
		var b := float(i + 1) / float(links)
		var pa := origin.lerp(target, a) + Vector3.UP * sin(a * PI) * 0.18
		var pb := origin.lerp(target, b) + Vector3.UP * sin(b * PI) * 0.18
		cylinder(root, "BoneChainLink", pa, pb, 0.035 + power * 0.018, Color("#f4ead4"), 0.88, 1.5 + power)
	var hook := torus(root, "HookJaw", target, Vector3.ONE * (0.13 + power * 0.07), Color("#fff8e7") if hit else Color("#cbbca8"), 0.92, 2.4)
	hook.rotation.x = PI * 0.5
	var tw := parent.create_tween()
	tw.tween_interval(0.06 if hit else 0.12)
	tw.tween_property(root, "scale", Vector3.ONE * 0.05, 0.16)
	tw.tween_callback(root.queue_free)

static func spawn_bone_wall(parent: Node3D, pos: Vector3, yaw: float, preview: bool) -> StaticBody3D:
	var wall := StaticBody3D.new()
	wall.name = "BoneWallPreview32" if preview else "BoneWall32"
	parent.add_child(wall)
	wall.global_position = pos
	wall.rotation.y = yaw
	for x in range(-3, 4):
		var height := 1.75 + (1.0 - absf(float(x)) / 4.0) * 0.75
		var pillar := cylinder(wall, "WallRib", Vector3(float(x) * 0.38, 0.05, 0), Vector3(float(x) * 0.38, height, 0), 0.15, Color("#d9cdb9") if preview else Color("#f4ead4"), 0.28 if preview else 1.0, 0.55 if preview else 1.2)
		pillar.rotation.z = sin(float(x) * 1.7) * 0.035
	for y in [0.55, 1.25, 1.90]:
		cylinder(wall, "WallSpine", Vector3(-1.35, y, 0.04), Vector3(1.35, y, 0.04), 0.085, Color("#ffca7a") if not preview else Color("#ead8bf"), 0.30 if preview else 0.96, 0.8)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(3.0, 2.55, 0.38)
	collision.shape = shape
	collision.position.y = 1.27
	collision.disabled = preview
	wall.add_child(collision)
	wall.set_meta("preview", preview)
	wall.set_meta("ttl", 5.0)
	return wall

static func spawn_bone_armor(parent: Node3D, pos: Vector3) -> void:
	var root := Node3D.new()
	root.name = "BoneArmorBurst32"
	parent.add_child(root)
	for i in range(8):
		var a := TAU * float(i) / 8.0
		var plate := sphere(root, "ArmorPlate", pos + Vector3(cos(a) * 0.65, 0.45 + float(i % 2) * 0.42, sin(a) * 0.65), Vector3(0.22, 0.34, 0.09), Color("#f4ead4"), 0.82, 1.7)
		_fade_free(plate, 0.65, Vector3.ONE * 0.35)
	parent.get_tree().create_timer(0.72).timeout.connect(root.queue_free)

static func spawn_wall_explosion(parent: Node3D, pos: Vector3, radius: float) -> void:
	var root := Node3D.new()
	root.name = "BoneWallExplosion32"
	parent.add_child(root)
	for r in range(3):
		var ring := torus(root, "WallBlastRing", pos + Vector3.UP * 0.12, Vector3.ONE * (0.15 + r * 0.05), Color("#ffad55") if r == 1 else Color("#fff0d2"), 0.62, 3.3)
		_fade_free(ring, 0.30 + r * 0.04, Vector3.ONE * radius * (0.75 + r * 0.12))
	for i in range(18):
		var a := TAU * float(i) / 18.0
		var tip := pos + Vector3(cos(a) * radius * 0.72, 0.15 + float(i % 4) * 0.32, sin(a) * radius * 0.72)
		var shard := cylinder(root, "ExplodingRib", pos + Vector3.UP * 0.5, tip, 0.045, Color("#fff2da"), 0.94, 2.2)
		_fade_free(shard, 0.36, Vector3.ONE * 0.07)
	parent.get_tree().create_timer(0.52).timeout.connect(root.queue_free)

# GODOT_PHASE32_KAKA_VFX
static func spawn_bubble_roll(parent: Node3D, pos: Vector3, power: float) -> void:
	var root := Node3D.new()
	root.name = "BubbleRollVFX"
	parent.add_child(root)
	var ring := torus(root, "RollRing", pos + Vector3.UP * 0.12, Vector3.ONE * 0.18, Color("#63dcff"), 0.55, 3.0)
	ring.rotation.x = PI * 0.5
	_fade_free(ring, 0.32, Vector3.ONE * (1.2 + power))
	for i in range(8):
		var a := TAU * float(i) / 8.0
		var drop := sphere(root, "RollDrop", pos + Vector3(cos(a)*0.35,0.15,sin(a)*0.35), Vector3(0.10,0.07,0.13), Color("#8be8ff"), 0.68, 2.6)
		_fade_free(drop, 0.28, Vector3.ONE * (0.22 + power * 0.12))
	parent.get_tree().create_timer(0.38).timeout.connect(root.queue_free)

static func spawn_bubble_sling(parent: Node3D, pos: Vector3, direction: Vector3, power: float) -> void:
	var root := Node3D.new()
	root.name = "BubbleSlingVFX"
	parent.add_child(root)
	var start_ring := torus(root, "SlingCompression", pos + Vector3.UP * 0.08, Vector3.ONE * 0.22, Color("#63dcff"), 0.62, 3.4)
	start_ring.rotation.x = PI * 0.5
	_fade_free(start_ring, 0.28, Vector3(1.6 + power, 0.25, 1.6 + power))
	for i in range(5):
		var trail_pos := pos - direction * float(i) * 0.26 + Vector3.UP * (0.22 + float(i%2)*0.12)
		var drop := sphere(root, "SlingDrop", trail_pos, Vector3.ONE * (0.08 + power*0.035), Color("#89ebff"), 0.72, 3.0)
		_fade_free(drop, 0.30 + float(i)*0.04, Vector3.ZERO)
	parent.get_tree().create_timer(0.52).timeout.connect(root.queue_free)
static func spawn_bubble_sling_land(parent: Node3D, pos: Vector3, radius: float) -> void:
	var root := Node3D.new()
	root.name = "BubbleLandingVFX"
	parent.add_child(root)
	for i in range(2):
		var ring := torus(root, "SplashRing", pos + Vector3.UP * (0.06+float(i)*0.10), Vector3.ONE*0.20, Color("#63dcff"), 0.50, 3.2)
		var tw := parent.create_tween()
		tw.tween_property(ring, "scale", Vector3.ONE * radius * (0.75+float(i)*0.18), 0.26+float(i)*0.05)
		tw.tween_property(ring, "scale", Vector3.ZERO, 0.10)
	for i in range(12):
		var a := TAU*float(i)/12.0
		var drop := sphere(root, "LandingDrop", pos+Vector3.UP*0.08, Vector3(0.12,0.18,0.12), Color("#87eaff"), 0.72, 3.0)
		var tw := parent.create_tween()
		tw.set_parallel(true)
		tw.tween_property(drop, "position", pos+Vector3(cos(a)*radius*0.72,0.18+float(i%3)*0.22,sin(a)*radius*0.72), 0.32)
		tw.tween_property(drop, "scale", Vector3.ZERO, 0.40)
	parent.get_tree().create_timer(0.48).timeout.connect(root.queue_free)

static func spawn_bubble_decoy(parent: Node3D, pos: Vector3) -> Node3D:
	var root := RigidBody3D.new()
	root.name = "BubbleSplitDecoy"
	root.mass = 0.32
	root.linear_damp = 1.4
	root.angular_damp = 1.0
	root.collision_layer = 4
	root.collision_mask = 1
	parent.add_child(root)
	root.global_position = pos
	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.52
	collision.shape = shape
	collision.position.y = 0.45
	root.add_child(collision)
	sphere(root, "DecoyBody", Vector3.UP*0.45, Vector3(0.62,0.72,0.62), Color("#63dcff"), 0.58, 2.6)
	sphere(root, "DecoyEyeL", Vector3(-0.18,0.55,-0.52), Vector3.ONE*0.07, Color("#fff7e7"), 0.98, 0.0)
	sphere(root, "DecoyEyeR", Vector3(0.18,0.55,-0.52), Vector3.ONE*0.07, Color("#fff7e7"), 0.98, 0.0)
	return root
static func spawn_bubble_burst(parent: Node3D, pos: Vector3, power: float) -> void:
	var root := Node3D.new()
	root.name = "BubbleBurstVFX"
	parent.add_child(root)
	var ring := torus(root, "BubbleBurstRing", pos+Vector3.UP*0.08, Vector3.ONE*0.14, Color("#63dcff"), 0.34, 2.0)
	_fade_free(ring, 0.28, Vector3.ONE*power*0.28)
	for i in range(8):
		var a := TAU*float(i)/8.0
		var drop := sphere(root, "BurstDrop", pos+Vector3.UP*0.18, Vector3.ONE*0.09, Color("#8cecff"), 0.70, 2.8)
		var tw := parent.create_tween()
		tw.set_parallel(true)
		tw.tween_property(drop,"position",pos+Vector3(cos(a)*power*0.55,0.18+float(i%2)*0.22,sin(a)*power*0.55),0.26)
		tw.tween_property(drop,"scale",Vector3.ZERO,0.34)
	parent.get_tree().create_timer(0.40).timeout.connect(root.queue_free)

static func spawn_spore_shot(parent: Node3D, origin: Vector3, target: Vector3) -> void:
	var root := Node3D.new()
	root.name = "SporeShotVFX"
	parent.add_child(root)
	cylinder(root, "SporeTrail", origin, target, 0.035, Color("#b989ff"), 0.42, 2.8)
	for i in range(4):
		var t := float(i+1)/5.0
		var bead := sphere(root, "SporeBead", origin.lerp(target,t)+Vector3.UP*sin(t*PI)*0.28, Vector3.ONE*0.075, Color("#cda4ff"), 0.82, 3.2)
		_fade_free(bead,0.22,Vector3.ONE*0.14)
	parent.get_tree().create_timer(0.26).timeout.connect(root.queue_free)
static func spawn_spore_bloom(parent: Node3D, pos: Vector3, radius: float) -> void:
	var root := Node3D.new()
	root.name = "SporeBloomVFX"
	parent.add_child(root)
	for i in range(10):
		var a := TAU*float(i)/10.0
		var spore := sphere(root,"BloomSpore",pos+Vector3.UP*0.18,Vector3.ONE*(0.08+float(i%3)*0.025),Color("#b989ff") if i%2==0 else Color("#8dec95"),0.76,2.8)
		var tw := parent.create_tween()
		tw.set_parallel(true)
		tw.tween_property(spore,"position",pos+Vector3(cos(a)*radius*0.72,0.25+float(i%3)*0.24,sin(a)*radius*0.72),0.38)
		tw.tween_property(spore,"scale",Vector3.ZERO,0.48)
	var ring := torus(root,"BloomRing",pos+Vector3.UP*0.06,Vector3.ONE*0.18,Color("#a88aff"),0.45,2.6)
	_fade_free(ring,0.42,Vector3.ONE*radius)
	parent.get_tree().create_timer(0.55).timeout.connect(root.queue_free)

static func spawn_puppet_thread(parent: Node3D, origin: Vector3, target: Vector3) -> void:
	var root := Node3D.new()
	root.name = "PuppetThreadVFX"
	parent.add_child(root)
	for offset in [-0.08,0.08]:
		var start := origin+Vector3(offset,0,0)
		var finish := target+Vector3(offset,0,0)
		var thread := cylinder(root,"FungalThread",start,finish,0.026,Color("#c99bff"),0.72,3.6)
		_fade_free(thread,0.48,Vector3.ONE*0.10)
	var knot := sphere(root,"PuppetKnot",target,Vector3.ONE*0.16,Color("#8dec95"),0.76,3.0)
	_fade_free(knot,0.50,Vector3.ONE*0.34)
	parent.get_tree().create_timer(0.55).timeout.connect(root.queue_free)
