const CreatureArt = preload("res://scripts/art19_creatures.gd")

static func clay(color: Color, alpha: float = 1.0, glow: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(color.r, color.g, color.b, alpha)
	m.roughness = 0.96
	if alpha < 0.999:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if glow > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = glow
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
	mi.material_override = clay(color, alpha, glow)
	root.add_child(mi, true)
	return mi

static func box(root: Node3D, name: String, pos: Vector3, scale_v: Vector3, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE
	mi.mesh = mesh
	mi.position = pos
	mi.scale = scale_v
	mi.material_override = clay(color)
	root.add_child(mi, true)
	return mi

static func cylinder(root: Node3D, name: String, pos: Vector3, scale_v: Vector3, color: Color, rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.5
	mesh.bottom_radius = 0.5
	mesh.height = 1.0
	mi.mesh = mesh
	mi.position = pos
	mi.scale = scale_v
	mi.rotation = rot
	mi.material_override = clay(color)
	root.add_child(mi, true)
	return mi

static func torus(root: Node3D, name: String, pos: Vector3, scale_v: Vector3, color: Color, rot := Vector3.ZERO, glow := 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.58
	mesh.outer_radius = 1.0
	mi.mesh = mesh
	mi.position = pos
	mi.scale = scale_v
	mi.rotation = rot
	mi.material_override = clay(color, 1.0, glow)
	root.add_child(mi, true)
	return mi
static func build(parent: Node3D, kind: String) -> Dictionary:
	var root := Node3D.new()
	root.name = "EnemyVisual"
	parent.add_child(root)
	var main: MeshInstance3D
	match kind:
		"HAIRBALL": main = _hairball(root)
		"PLATELET": main = _platelet(root)
		"TOY_MOUSE": main = _toy_mouse(root)
		_: main = _parasite(root)
	root.scale = Vector3.ONE * (1.20 if kind == "HAIRBALL" else (1.12 if kind == "PLATELET" else (1.0 if kind == "TOY_MOUSE" else 1.18)))
	root.set_meta("base_scale", root.scale)
	for child in root.get_children():
		if child is MeshInstance3D:
			var mat := child.material_override as StandardMaterial3D
			if mat: child.set_meta("base_albedo", mat.albedo_color)
	CreatureArt.attach(root, kind)
	return {"visual": root, "main_mesh": main}

static func _eyes(root: Node3D, y: float, z: float, gap: float, scale_v: Vector3) -> void:
	for sx in [-1.0, 1.0]:
		sphere(root, "EyeWhite", Vector3(gap * sx, y, z), scale_v, Color("#fff7df"))
		sphere(root, "Pupil", Vector3(gap * sx, y, z - 0.055), scale_v * Vector3(0.42,0.58,0.45), Color("#261c2b"))

static func _hairball(root: Node3D) -> MeshInstance3D:
	var purple := Color("#725080")
	var light := Color("#9b70aa")
	var pink := Color("#f48eaf")
	var body := sphere(root, "HairballBody", Vector3(0,0.70,0), Vector3(1.12,1.04,1.04), purple)
	for i in range(16):
		var a := TAU * float(i) / 16.0
		var y := 0.70 + sin(float(i) * 1.7) * 0.34
		var r := 0.52 + float(i % 3) * 0.05
		var p := Vector3(cos(a)*r, y, sin(a)*r*0.78)
		sphere(root,"FuzzTuft",p,Vector3(0.30,0.25,0.30),light if i%2==0 else purple)
	_eyes(root,0.82,-0.50,0.22,Vector3(0.18,0.23,0.10))
	sphere(root,"Tongue",Vector3(0,0.47,-0.56),Vector3(0.25,0.15,0.20),pink,1.0,0.12)
	return body
static func _platelet(root: Node3D) -> MeshInstance3D:
	var red := Color("#e86372")
	var pink := Color("#f58b94")
	var yellow := Color("#f2cf4f")
	var dark := Color("#5b3441")
	var body := sphere(root,"PlateletBody",Vector3(0,0.68,0),Vector3(0.94,0.72,0.82),red)
	_eyes(root,0.77,-0.40,0.18,Vector3(0.14,0.17,0.08))
	box(root,"PlateletMouth",Vector3(0,0.55,-0.45),Vector3(0.16,0.04,0.04),dark)
	var helmet := sphere(root,"HelmetDome",Vector3(0,1.20,0),Vector3(0.76,0.34,0.70),yellow,1.0,0.32)
	helmet.scale.y = 0.48
	box(root,"HelmetBrim",Vector3(0,1.04,-0.12),Vector3(0.86,0.10,0.68),yellow)
	box(root,"Vest",Vector3(0,0.66,-0.43),Vector3(0.66,0.28,0.08),pink)
	for sx in [-1.0,1.0]:
		cylinder(root,"PlateletArm",Vector3(0.55*sx,0.67,0),Vector3(0.10,0.42,0.10),red,Vector3(0,0,sx*0.28))
		cylinder(root,"PlateletLeg",Vector3(0.28*sx,0.18,0),Vector3(0.11,0.34,0.11),dark)
	return body

static func _parasite(root: Node3D) -> MeshInstance3D:
	var green := Color("#6ecb88")
	var lime := Color("#9cdd68")
	var dark := Color("#39543f")
	var cream := Color("#f4e7cc")
	var body := sphere(root,"ParasiteHead",Vector3(0,0.82,-0.30),Vector3(0.78,0.76,0.72),green,1.0,0.22)
	for i in range(5):
		var z := 0.18 + float(i)*0.36
		sphere(root,"ParasiteSegment",Vector3(0,0.66,z),Vector3(0.68-i*0.045,0.56,0.54),green if i%2==0 else lime,1.0,0.16)
	var mouth := torus(root,"ParasiteMouth",Vector3(0,0.82,-0.72),Vector3(0.36,0.36,0.14),dark,Vector3(PI*0.5,0,0),0.12)
	mouth.rotation.x = PI*0.5
	for i in range(8):
		var a := TAU*float(i)/8.0
		var tooth := box(root,"ParasiteTooth",Vector3(cos(a)*0.22,0.82+sin(a)*0.22,-0.82),Vector3(0.06,0.12,0.05),cream)
		tooth.rotation.z = -a
	_eyes(root,1.08,-0.56,0.24,Vector3(0.13,0.15,0.075))
	return body
static func _toy_mouse(root: Node3D) -> MeshInstance3D:
	var lime := Color("#9cf26b")
	var mint := Color("#c9ff9d")
	var pink := Color("#f3a3c5")
	var dark := Color("#3d2940")
	var metal := Color("#d9e0d2")
	var body := sphere(root,"MouseShell",Vector3(0,0.60,0.02),Vector3(0.86,0.52,1.12),lime,1.0,0.52)
	sphere(root,"MouseSnout",Vector3(0,0.58,-0.72),Vector3(0.48,0.34,0.54),mint,1.0,0.32)
	box(root,"MouseTopPanel",Vector3(0,0.91,0.08),Vector3(0.68,0.08,0.78),mint)
	for sx in [-1.0,1.0]:
		sphere(root,"MouseEar",Vector3(0.34*sx,1.02,-0.30),Vector3(0.28,0.34,0.18),pink,1.0,0.18)
		sphere(root,"MouseEye",Vector3(0.18*sx,0.73,-0.91),Vector3(0.10,0.12,0.07),Color("#fff7df"))
		sphere(root,"MousePupil",Vector3(0.18*sx,0.73,-0.96),Vector3(0.045,0.065,0.035),dark)
		for z in [-0.35,0.42]: cylinder(root,"MouseWheel",Vector3(0.52*sx,0.30,z),Vector3(0.18,0.12,0.18),dark,Vector3(0,0,PI*0.5))
	sphere(root,"MouseLEDNose",Vector3(0,0.57,-1.05),Vector3(0.14,0.12,0.12),Color("#ff5777"),1.0,1.6)
	box(root,"MouseBatteryDoor",Vector3(0,0.54,0.91),Vector3(0.48,0.24,0.07),metal)
	for sx in [-1.0,1.0]: sphere(root,"MouseScrew",Vector3(0.18*sx,0.61,0.96),Vector3.ONE*0.045,dark)
	for i in range(5): sphere(root,"MouseTailBead",Vector3(0.08*sin(i*0.8),0.48,1.10+float(i)*0.22),Vector3.ONE*(0.10-float(i)*0.008),pink,1.0,0.12)
	return body

static func animate(root: Node3D, kind: String, time: float, velocity: Vector3, stunned: bool, pinned: bool, attack: float = 0.0) -> void:
	if not is_instance_valid(root): return
	var speed := Vector2(velocity.x,velocity.z).length()
	var bob := sin(time*(3.2+speed*0.35))*0.045
	root.position.y = bob
	var base_scale: Vector3 = root.get_meta("base_scale", root.scale)
	root.scale = base_scale * Vector3(1.0 + attack * 0.08, 1.0 - attack * 0.05, 1.0 + attack * 0.10)
	if velocity.length_squared() > 0.04:
		root.rotation.y = lerp_angle(root.rotation.y, atan2(-velocity.x,-velocity.z), 0.18)
	if stunned:
		root.rotation.z = sin(time*24.0)*0.12
	elif pinned:
		root.rotation.z = 0.10
	else:
		root.rotation.z = sin(time*4.5)*0.025
	match kind:
		"HAIRBALL":
			for child in root.get_children():
				if child.name.begins_with("FuzzTuft"):
					child.scale *= 1.0 + sin(time*6.0 + child.position.x*4.0)*0.002
			var tongue := root.get_node_or_null("Tongue") as Node3D
			if tongue:
				tongue.rotation.x = sin(time*5.0)*0.16
				tongue.position.z = -0.56 - attack * 0.18
				tongue.scale = Vector3(0.25,0.15 + attack * 0.10,0.20)
		"PLATELET":
			var helmet := root.get_node_or_null("HelmetDome") as Node3D
			if helmet: helmet.rotation.z = sin(time*5.2)*0.05 - attack * 0.08
			for child in root.get_children():
				if child.name.begins_with("PlateletArm"): child.rotation.x = -attack * 1.05
		"PARASITE":
			var mouth := root.get_node_or_null("ParasiteMouth") as Node3D
			if mouth: mouth.scale = Vector3(0.36,0.36,0.14) * (1.0 + attack * 0.42)
			var idx := 0
			for child in root.get_children():
				if child.name.begins_with("ParasiteSegment"):
					child.position.x = sin(time*5.5 + float(idx)*0.8)*0.08
					idx += 1
		"TOY_MOUSE":
			for child in root.get_children():
				if child.name.begins_with("MouseWheel"): child.rotation.x += speed * 0.018
				elif child.name.begins_with("MouseTailBead"):
					var ti: float = child.position.z * 3.0
					child.position.x = sin(time * 7.0 + ti) * 0.12
			var led := root.get_node_or_null("MouseLEDNose") as MeshInstance3D
			if led:
				var lm := led.material_override as StandardMaterial3D
				if lm: lm.emission_energy_multiplier = 1.2 + absf(sin(time * 6.0)) * 1.4

	CreatureArt.sync(root)

# GODOT_ENEMY_MODELS_V1
static func _death_bead(parent: Node3D, pos: Vector3, color: Color, dir: Vector3, size: float) -> void:
	var bead := sphere(parent,"EnemyDeathChunk",pos,Vector3.ONE*size,color)
	var tw := parent.create_tween()
	tw.set_parallel(true)
	tw.tween_property(bead,"position",pos+dir,0.34)
	tw.tween_property(bead,"scale",Vector3.ZERO,0.34)
	tw.chain().tween_callback(bead.queue_free)

static func spawn_death(parent: Node3D, kind: String, pos: Vector3) -> void:
	var primary := Color("#725080") if kind == "HAIRBALL" else (Color("#e86372") if kind == "PLATELET" else Color("#6ecb88"))
	var accent := Color("#9b70aa") if kind == "HAIRBALL" else (Color("#f2cf4f") if kind == "PLATELET" else Color("#9cdd68"))
	var count := 12 if kind == "HAIRBALL" else 9
	for i in range(count):
		var a := TAU*float(i)/float(count)
		var dir := Vector3(cos(a)*(0.7+float(i%3)*0.18),0.35+float(i%4)*0.13,sin(a)*(0.7+float(i%2)*0.2))
		_death_bead(parent,pos+Vector3.UP*0.6,accent if i%3==0 else primary,dir,0.12+float(i%3)*0.025)

# GODOT_ENEMY_DEATH_VFX_V1
static func set_hit_flash(root: Node3D, active: bool) -> void:
	if not is_instance_valid(root): return
	CreatureArt.set_hit_flash(root, active)
	for child in root.get_children():
		if not (child is MeshInstance3D): continue
		var mi := child as MeshInstance3D
		var m := mi.material_override as StandardMaterial3D
		if not m: continue
		var base: Color = mi.get_meta("base_albedo", m.albedo_color)
		m.albedo_color = Color(1.0,1.0,1.0,base.a) if active else base

# GODOT_ENEMY_FULLBODY_HIT_FLASH
# GODOT_ENEMY_MODELS_V2

# GODOT_PHASE5_ENEMIES_MOUSE

static func _attack_color(kind: String) -> Color:
	if kind == "HAIRBALL": return Color("#d58cff")
	if kind == "PLATELET": return Color("#ffd35a")
	return Color("#9df06d")

static func spawn_attack_telegraph(parent: Node3D, kind: String, pos: Vector3) -> void:
	var col: Color = _attack_color(kind)
	var ring := torus(parent,"EnemyAttackTell",pos + Vector3.UP * 0.06,Vector3.ONE * 0.22,col,Vector3.ZERO,2.4)
	var tw := parent.create_tween()
	tw.tween_property(ring,"scale",Vector3.ONE * 1.35,0.27)
	tw.tween_property(ring,"scale",Vector3.ZERO,0.09)
	tw.tween_callback(ring.queue_free)
	for i in range(4):
		var a: float = TAU * float(i) / 4.0
		var bead := sphere(parent,"AttackTellBead",pos + Vector3(cos(a)*0.9,0.18,sin(a)*0.9),Vector3.ONE*0.10,col,0.82,2.8)
		var bt := parent.create_tween()
		bt.tween_property(bead,"position",pos + Vector3.UP*0.18,0.30)
		bt.tween_property(bead,"scale",Vector3.ZERO,0.06)
		bt.tween_callback(bead.queue_free)

static func spawn_attack_hit(parent: Node3D, kind: String, pos: Vector3) -> void:
	var col: Color = _attack_color(kind)
	var core := sphere(parent,"EnemyAttackHit",pos,Vector3.ONE*0.22,col,0.72,3.4)
	var tw := parent.create_tween()
	tw.tween_property(core,"scale",Vector3.ONE*1.35,0.10)
	tw.tween_property(core,"scale",Vector3.ZERO,0.12)
	tw.tween_callback(core.queue_free)
	for i in range(7):
		var a: float = TAU * float(i) / 7.0
		_death_bead(parent,pos,col,Vector3(cos(a)*0.75,0.25+float(i%2)*0.16,sin(a)*0.75),0.08)

static func spawn_mouse_burst(parent: Node3D, pos: Vector3) -> void:
	var lime := Color("#a9ff71")
	var pink := Color("#ff9fc9")
	for i in range(8):
		var a: float = TAU * float(i) / 8.0
		var col: Color = lime if i % 2 == 0 else pink
		_death_bead(parent,pos + Vector3.UP*0.25,col,Vector3(cos(a)*0.55,0.10,sin(a)*0.55),0.07)
	var ring := torus(parent,"MouseTurboRing",pos + Vector3.UP*0.08,Vector3.ONE*0.16,lime,Vector3.ZERO,1.8)
	var tw := parent.create_tween()
	tw.tween_property(ring,"scale",Vector3.ONE*0.95,0.18)
	tw.tween_property(ring,"scale",Vector3.ZERO,0.08)
	tw.tween_callback(ring.queue_free)

# GODOT_PHASE6_ENEMY_ATTACK_MOUSE_V3

static func apply_control_pose(root: Node3D, stun: float, pinned: float, slow: float) -> void:
	if not is_instance_valid(root): return
	var base: Vector3 = root.get_meta("base_scale", root.scale)
	if pinned > 0.0:
		root.scale = base * Vector3(1.16,0.62,1.10)
		root.rotation.x = 0.16
	elif stun > 0.0:
		root.scale = base * Vector3(1.10,0.88,1.08)
		root.rotation.z += sin(stun * 31.0) * 0.10
	elif slow < 0.99:
		root.scale = base * Vector3(1.04,0.93,1.04)

static func apply_mouse_bump(root: Node3D, bump: float) -> void:
	if not is_instance_valid(root) or bump <= 0.0: return
	var base: Vector3 = root.get_meta("base_scale", root.scale)
	var t: float = clampf(bump / 0.22,0.0,1.0)
	root.scale = base * Vector3(1.20-0.12*t,0.76+0.18*t,1.12)

static func spawn_mouse_bump(parent: Node3D, pos: Vector3) -> void:
	var col := Color("#fff0a2")
	for i in range(6):
		var a: float = TAU * float(i) / 6.0
		_death_bead(parent,pos+Vector3.UP*0.45,col,Vector3(cos(a)*0.42,0.24,sin(a)*0.42),0.08)

# GODOT_PHASE7_CONTROL_POSES
