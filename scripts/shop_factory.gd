extends RefCounted

const ITEM_NAMES := ["ACID UMBRELLA", "PLASMA SODA", "CATNIP BEACON", "MYSTERY CAPSULE"]
const ITEM_DISPLAY_NAMES := ["胃酸伞", "血浆汽水", "猫薄荷诱饵", "神秘胶囊"]
const ITEM_DESCRIPTIONS := ["18秒抗胃酸，水流推力降低", "16秒加速、超级跳与冷却恢复", "投掷后吸引附近怪物14秒", "随机治疗、刷新、返现或酸液事故"]
const ITEM_COSTS := [24, 20, 28, 18]
const ITEM_COLORS := [Color("#ffe36b"), Color("#64e5ff"), Color("#d985ff"), Color("#ff91bb")]
const SHOP_JOKES := ["欢迎光临！不退货，只退烧。", "本菌持证经营——证被胃酸泡了。", "猫薄荷别自己闻，上次客人追了尾巴三圈。", "神秘胶囊很安全，大概。"]

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

static func solid_box(parent: Node3D, name: String, pos: Vector3, size: Vector3, color: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = name
	body.position = pos
	parent.add_child(body)
	box(body,"Visual",Vector3.ZERO,size,color)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	return body

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
	root.position = Vector3(-4.5,0.0,-4.3)
	parent.add_child(root)
	box(root,"ShopFloor",Vector3(0,0.08,0.4),Vector3(8.4,0.16,6.4),Color("#7f5264"))
	solid_box(root,"BackWall",Vector3(0,1.55,-2.65),Vector3(8.4,3.1,0.32),Color("#b85e72"))
	solid_box(root,"LeftWall",Vector3(-4.05,1.55,0.35),Vector3(0.32,3.1,5.7),Color("#aa536d"))
	solid_box(root,"RightWall",Vector3(4.05,1.55,0.35),Vector3(0.32,3.1,5.7),Color("#aa536d"))
	box(root,"StripedCanopy",Vector3(0,3.12,0.15),Vector3(8.7,0.28,6.1),Color("#e98b88"))
	var roof := cylinder(root,"ShopHat",Vector3(0,3.35,-0.2),Vector3(4.6,0.18,3.3),Color("#ffd34f"))
	roof.set_meta("base_y",roof.position.y)
	solid_box(root,"ShopCounter",Vector3(0,0.78,0.15),Vector3(7.0,1.35,0.72),Color("#e77984"))
	var sign := Label3D.new()
	sign.name = "ShopSign"
	sign.text = "BODY MART\n体 内 小 卖 部"
	sign.position = Vector3(0,4.15,0.5)
	sign.font_size = 34
	sign.pixel_size = 0.009
	sign.outline_size = 9
	sign.modulate = Color("#fff0a8")
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	root.add_child(sign)
	var merchant := Node3D.new()
	merchant.name = "BacteriaMerchant"
	merchant.position = Vector3(0,1.15,-0.85)
	root.add_child(merchant)
	sphere(merchant,"BacteriaBody",Vector3.ZERO,Vector3(0.70,0.82,0.58),Color("#9edb68"))
	for side in [-1.0,1.0]:
		var suffix := "L" if side<0 else "R"
		sphere(merchant,"Eye"+suffix,Vector3(0.25*side,0.20,-0.52),Vector3(0.16,0.19,0.09),Color.WHITE)
		sphere(merchant,"Pupil"+suffix,Vector3(0.25*side,0.20,-0.61),Vector3(0.07,0.09,0.04),Color("#25342b"))
		var arm := cylinder(merchant,"Arm"+suffix,Vector3(0.68*side,-0.05,0),Vector3(0.10,0.70,0.10),Color("#82c45b"))
		arm.rotation.z = -0.72*side
	box(merchant,"Apron",Vector3(0,-0.28,-0.54),Vector3(0.72,0.62,0.10),Color("#fff0c2"))
	cylinder(merchant,"Mouth",Vector3(0,-0.05,-0.61),Vector3(0.18,0.05,0.05),Color("#733f54"))
	var talk := Label3D.new()
	talk.name = "MerchantTalk"
	talk.text = SHOP_JOKES[0]
	talk.position = Vector3(0,1.62,0)
	talk.font_size = 22
	talk.pixel_size = 0.0065
	talk.outline_size = 7
	talk.modulate = Color("#eaffc9")
	talk.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	merchant.add_child(talk)
	var pads: Array[Node3D] = []
	for i in range(4):
		var pad := Node3D.new()
		pad.name = "ShopPad%d" % i
		pad.position = Vector3(-2.7+float(i)*1.8,0.18,2.0)
		pad.set_meta("item_index",i)
		pad.set_meta("base_y",pad.position.y)
		pad.set_meta("phase",float(i)*0.9)
		root.add_child(pad)
		var plate := cylinder(pad,"Pad",Vector3.ZERO,Vector3(0.70,0.10,0.70),ITEM_COLORS[i])
		plate.material_override = mat(ITEM_COLORS[i],0.45)
		match i:
			0:
				sphere(pad,"UmbrellaIcon",Vector3(0,0.48,0),Vector3(0.44,0.12,0.44),ITEM_COLORS[i],0.35)
				cylinder(pad,"UmbrellaStick",Vector3(0,0.24,0),Vector3(0.06,0.48,0.06),Color("#6b4053"))
			1: cylinder(pad,"SodaCan",Vector3(0,0.45,0),Vector3(0.32,0.74,0.32),ITEM_COLORS[i])
			2: sphere(pad,"Catnip",Vector3(0,0.45,0),Vector3(0.42,0.42,0.42),ITEM_COLORS[i],0.6)
			3: sphere(pad,"Mystery",Vector3(0,0.45,0),Vector3(0.40,0.55,0.40),ITEM_COLORS[i],0.6)
		var lab := Label3D.new()
		lab.name = "ItemLabel"
		lab.text = "%s  %d C\n%s" % [ITEM_DISPLAY_NAMES[i],ITEM_COSTS[i],ITEM_DESCRIPTIONS[i]]
		lab.position = Vector3(0,1.30,0)
		lab.font_size = 18
		lab.pixel_size = 0.006
		lab.outline_size = 6
		lab.modulate = ITEM_COLORS[i].lightened(0.22)
		lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		pad.add_child(lab)
		pads.append(pad)
	return {"root":root,"pads":pads,"merchant":merchant}
static func animate(root: Node3D, time: float) -> void:
	if not is_instance_valid(root): return
	var roof := root.get_node_or_null("ShopHat") as Node3D
	if roof: roof.rotation.y = sin(time*0.7)*0.04
	var merchant := root.get_node_or_null("BacteriaMerchant") as Node3D
	if merchant:
		merchant.position.y = 1.15+sin(time*2.2)*0.07
		merchant.rotation.y = sin(time*1.4)*0.10
		var talk := merchant.get_node_or_null("MerchantTalk") as Label3D
		if talk: talk.text = SHOP_JOKES[int(time/6.0)%SHOP_JOKES.size()]
		var blink := 0.18 if fposmod(time,4.2)>4.02 else 1.0
		for eye in merchant.find_children("Eye*","MeshInstance3D",false,false): eye.scale.y = 0.19*blink
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
