extends Node
# Authoring coordinates remain compact; only the environment is expanded.
# Actors, interaction reach, combat ranges, UI and the final combat arena stay 1:1.
var game
var factor := 5.0
var guide: Label
var baked_shapes := 0

func point(p: Vector3) -> Vector3:
	return p * Vector3(factor,1.0,factor)

func authored(p: Vector3) -> Vector3:
	return p / Vector3(factor,1.0,factor)

func build(host) -> void:
	game = host
	# Explicit compatibility fixture for old coordinate-based automated tests only.
	# Normal launches always use the five-times layout.
	if DisplayServer.get_name() == "headless" and OS.get_environment("GUT_CREW_QA_LEGACY_LAYOUT") == "1":
		factor = 1.0
	game.world_scale = factor
	if factor == 1.0: return
	var polish = preload("res://scripts/world_polish.gd")
	var sculptures: Array = polish.capture(game)
	var keep: Array[Node3D] = [game.player,game.entrance,game.acid_valve,game.shop_root]
	for clue in game.clue_nodes: keep.append(clue)
	for enemy in game.enemies: keep.append(enemy)
	var prop_bases: Array[Basis] = []
	for prop in game.organ_props: prop_bases.append(prop.global_basis)
	var labels: Array = []
	for label in game.find_children("*","Label3D",true,false):
		labels.append({"node":label,"basis":label.global_basis})
	var stretch := Basis.from_scale(Vector3(factor,1.0,factor))
	for node in game.get_children():
		if not node is Node3D: continue
		if node in keep:
			node.position = point(node.position)
		elif not node is DirectionalLight3D:
			node.transform = Transform3D(stretch*node.basis,point(node.position))
	for i in range(game.organ_props.size()):
		game.organ_props[i].global_basis = prop_bases[i]
	for entry in labels:
		entry.node.global_basis = entry.basis
		entry.node.visibility_range_end = 32.0
	for enemy in game.enemies:
		enemy.set_meta("home",point(enemy.get_meta("home")))
		# No level-wide beeline to spawn in an enlarged world.
		enemy.set_meta("wild_spawn",true)
	for mound in game.mounds: mound.set_meta("base_scale",mound.scale)
	game.terrain_world.last_safe = point(game.terrain_world.last_safe)
	for light in game.find_children("*","OmniLight3D",true,false):
		if game.player.is_ancestor_of(light): continue
		light.omni_range = minf(95.0,light.omni_range*3.0)
	for light in game.find_children("*","SpotLight3D",true,false):
		if game.player.is_ancestor_of(light): continue
		light.spot_range *= factor
	# Bake world-space faces, never leave non-uniform physics-body scaling.
	for body in game.find_children("*","StaticBody3D",true,false):
		_bake_body(body)
	polish.apply(game,sculptures)
	_build_guide()
	game.set_meta("world_extent",Vector2(260,180))
	game.set_meta("horizontal_expansion",factor)
	game.set_meta("scaled_static_shapes",baked_shapes)

func _faces(shape: Shape3D) -> PackedVector3Array:
	if shape is ConcavePolygonShape3D: return shape.get_faces()
	var mesh: PrimitiveMesh
	if shape is BoxShape3D:
		mesh = BoxMesh.new()
		mesh.size = shape.size
	elif shape is SphereShape3D:
		mesh = SphereMesh.new()
		mesh.radius = shape.radius
		mesh.height = shape.radius*2.0
	elif shape is CapsuleShape3D:
		mesh = CapsuleMesh.new()
		mesh.radius = shape.radius
		mesh.height = shape.height
	elif shape is CylinderShape3D:
		mesh = CylinderMesh.new()
		mesh.top_radius = shape.radius
		mesh.bottom_radius = shape.radius
		mesh.height = shape.height
	else:
		push_error("Unsupported expanded collision shape: "+shape.get_class())
		return PackedVector3Array()
	return mesh.get_faces()

func _bake_body(body: StaticBody3D) -> void:
	var shapes: Array = []
	var children: Array = []
	for child in body.get_children():
		if child is Node3D: children.append({"node":child,"transform":child.global_transform})
		if child is CollisionShape3D:
			var faces := _faces(child.shape)
			for i in range(faces.size()): faces[i] = child.global_transform*faces[i]
			shapes.append({"node":child,"faces":faces})
	body.global_transform = Transform3D.IDENTITY
	for entry in children: entry.node.global_transform = entry.transform
	for entry in shapes:
		var shape := ConcavePolygonShape3D.new()
		shape.set_faces(entry.faces)
		shape.backface_collision = true
		entry.node.transform = Transform3D.IDENTITY
		entry.node.shape = shape
		baked_shapes += 1

func _build_guide() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 13
	add_child(layer)
	guide = Label.new()
	guide.position = Vector2(310,208)
	guide.size = Vector2(660,28)
	guide.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	guide.add_theme_font_size_override("font_size",16)
	guide.add_theme_color_override("font_color",Color("e4dcc0"))
	guide.add_theme_color_override("font_outline_color",Color("261d2b"))
	guide.add_theme_constant_override("outline_size",5)
	guide.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(guide)

func _process(_delta: float) -> void:
	if not is_instance_valid(guide): return
	guide.visible = game.role_selected and not game.game_paused and game.mission_phase in ["mouth","diagnose","chase","return"]
	if not guide.visible: return
	var target: Vector3
	var title := ""
	if game.mouth_intro.active:
		target = point(Vector3(0,8.8,35))
		title = "咽喉入口 · 沿舌面下行"
	elif game.mission_phase == "diagnose":
		var nearest := INF
		for i in range(game.clue_nodes.size()):
			if game.clue_done[i]: continue
			var distance: float = game.player.position.distance_to(game.clue_nodes[i].position)
			if distance < nearest:
				nearest = distance
				target = game.clue_nodes[i].position
				title = ["第一关 · 贲门黏膜室","第二关 · 幽门窦","第三关 · 十二指肠弯道"][i]
	elif game.mission_phase == "chase" and is_instance_valid(game.mouse_target):
		target = game.mouse_target.position
		title = "电子老鼠 · 靠近后使用控制技能"
	else:
		target = game.entrance.position
		title = "返航胶囊 · 护送电子老鼠"
	var offset: Vector3 = target-game.player.position
	var angle := wrapf(atan2(-offset.x,-offset.z)-game.yaw,-PI,PI)
	var direction := "前方" if absf(angle)<0.45 else ("后方" if absf(angle)>2.4 else ("左侧" if angle>0 else "右侧"))
	guide.text = "%s  |  %s · %.0f m" % [title,direction,Vector2(offset.x,offset.z).length()]
