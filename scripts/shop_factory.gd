extends RefCounted

const ITEM_NAMES := ["ACID UMBRELLA", "PLASMA SODA", "CATNIP BEACON", "MYSTERY CAPSULE"]
const ITEM_DISPLAY_NAMES := ["ACID UMBRELLA", "PLASMA SODA", "CATNIP", "MYSTERY"]
const ITEM_COSTS := [24, 20, 28, 18]
const ITEM_COLORS := [Color("#ffe36b"), Color("#64e5ff"), Color("#d985ff"), Color("#ff91bb")]

static func mat(color: Color, glow := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.62
	if glow > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = glow
	return m

static func box(parent: Node3D, name: String, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = mat(color)
	parent.add_child(mi)
	return mi
static func sphere(parent: Node3D, name: String, pos: Vector3, scale_v: Vector3, color: Color, glow := 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 2.0
	mi.mesh = mesh
	mi.position = pos
	mi.scale = scale_v
	mi.material_override = mat(color, glow)
	parent.add_child(mi)
	return mi

static func cylinder(parent: Node3D, name: String, pos: Vector3, scale_v: Vector3, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.5
	mesh.bottom_radius = 0.5
	mesh.height = 1.0
	mi.mesh = mesh
	mi.position = pos
	mi.scale = scale_v
	mi.material_override = mat(color)
	parent.add_child(mi)
	return mi
static func build(parent: Node3D) -> Dictionary:
	var root := Node3D.new()
	root.name = "PlateletShop"
	root.position = Vector3(-4.5, 0.0, -4.3)
	parent.add_child(root)
	box(root, "ShopBody", Vector3(0,0.7,0), Vector3(3.2,1.4,1.5), Color("#c84f68"))
	box(root, "ShopCounter", Vector3(0,1.05,0.9), Vector3(3.8,0.32,0.7), Color("#f07a87"))
	var roof := cylinder(root, "ShopHat", Vector3(0,1.72,0), Vector3(2.15,0.26,2.15), Color("#ffd34f"))
	roof.set_meta("base_y", roof.position.y)
	var sign := Label3D.new()
	sign.name = "ShopSign"
	sign.text = "BODY MART"
	sign.position = Vector3(0,3.25,0)
	sign.font_size = 34
	sign.pixel_size = 0.010
	sign.outline_size = 8
	sign.modulate = Color("#fff0a8")
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	root.add_child(sign)
	var pads: Array[Node3D] = []
	for i in range(4):
		var pad := Node3D.new()
		pad.name = "ShopPad%d" % i
		pad.position = Vector3(-2.4 + float(i)*1.6, 0.0, 2.0)
		pad.set_meta("item_index", i)
		pad.set_meta("base_y", pad.position.y)
		pad.set_meta("phase", float(i)*0.9)
		root.add_child(pad)
		var plate := cylinder(pad,"Pad",Vector3.ZERO,Vector3(0.72,0.10,0.72),ITEM_COLORS[i])
		plate.material_override = mat(ITEM_COLORS[i],0.45)
		match i:
			0:
				sphere(pad,"UmbrellaIcon",Vector3(0,0.48,0),Vector3(0.44,0.12,0.44),ITEM_COLORS[i],0.35)
				cylinder(pad,"UmbrellaStick",Vector3(0,0.24,0),Vector3(0.06,0.48,0.06),Color("#6b4053"))
			1:
				cylinder(pad,"SodaCan",Vector3(0,0.45,0),Vector3(0.32,0.74,0.32),ITEM_COLORS[i])
			2:
				sphere(pad,"Catnip",Vector3(0,0.45,0),Vector3(0.42,0.42,0.42),ITEM_COLORS[i],0.6)
			3:
				sphere(pad,"Mystery",Vector3(0,0.45,0),Vector3(0.40,0.55,0.40),ITEM_COLORS[i],0.6)
		var lab := Label3D.new()
		lab.name = "ItemLabel"
		lab.text = "%s\n%d C" % [ITEM_DISPLAY_NAMES[i], ITEM_COSTS[i]]
		lab.position = Vector3(0,1.25,0)
		lab.font_size = 22
		lab.pixel_size = 0.007
		lab.outline_size = 6
		lab.modulate = ITEM_COLORS[i].lightened(0.22)
		lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		pad.add_child(lab)
		pads.append(pad)
	return {"root":root,"pads":pads}
static func animate(root: Node3D, time: float) -> void:
	if not is_instance_valid(root): return
	var roof := root.get_node_or_null("ShopHat") as Node3D
	if roof: roof.rotation.y = sin(time*0.7)*0.04
	for i in range(4):
		var pad := root.get_node_or_null("ShopPad%d" % i) as Node3D
		if not pad: continue
		var base_y: float = float(pad.get_meta("base_y",0.0))
		var phase: float = float(pad.get_meta("phase",0.0))
		pad.position.y = base_y + sin(time*2.6+phase)*0.05
static func set_umbrella(character: Node3D, active: bool) -> void:
	if not is_instance_valid(character): return
	var old := character.get_node_or_null("AcidUmbrella")
	if old and not active:
		old.queue_free()
		return
	if old or not active: return
	var root := Node3D.new()
	root.name = "AcidUmbrella"
	root.position = Vector3(0,3.0,0)
	character.add_child(root)
	cylinder(root,"Handle",Vector3(0,-0.55,0),Vector3(0.055,1.1,0.055),Color("#795365"))
	sphere(root,"Canopy",Vector3.ZERO,Vector3(0.78,0.14,0.78),Color("#ffe36b"),0.25)
static func spawn_catnip(parent: Node3D, pos: Vector3) -> Node3D:
	var root := Node3D.new()
	root.name = "CatnipBeacon"
	root.position = pos
	parent.add_child(root)
	sphere(root,"Pom",Vector3(0,0.48,0),Vector3(0.48,0.48,0.48),Color("#d985ff"),0.8)
	for i in range(3):
		var bead := sphere(root,"Scent",Vector3(0,0.8+float(i)*0.26,0),Vector3(0.12,0.08,0.12),Color("#9df78d"),0.6)
		bead.set_meta("phase",float(i)*0.8)
	var lab := Label3D.new()
	lab.text = "CATNIP!"
	lab.position = Vector3(0,1.65,0)
	lab.font_size = 22
	lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	root.add_child(lab)
	return root

static func animate_catnip(root: Node3D, time: float) -> void:
	if not is_instance_valid(root): return
	root.rotation.y = time*0.9
	root.scale = Vector3.ONE * (1.0 + sin(time*4.0)*0.05)
