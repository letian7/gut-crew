extends Node3D
# Phase17: continuous collision shell, organ chambers and walkable tissue links.
const Art = preload("res://scripts/organ_world_factory.gd")
const EXTENT := Vector2(26.0,18.0)
const ROOMS = [
	{"id":"forest","title":"胃底毛球滤区 / FUNDUS FILTER","rect":Rect2(9.8,5.4,10.4,8.0),"door":14.5,"north":true,"color":Color("#755c70"),"center":Vector3(14.5,0,9.2),"half":Vector2(4.0,2.6),"height":0.555},
	{"id":"gut","title":"十二指肠弯道 / DUODENAL LOOP","rect":Rect2(12.8,-13.3,10.7,8.8),"door":18.0,"north":false,"color":Color("#915179"),"center":Vector3(18,0,-8.7),"half":Vector2(4.1,3.4),"height":0.48},
	{"id":"lung","title":"贲门黏膜室 / CARDIA CHAMBER","rect":Rect2(-23.7,4.9,11.3,8.4),"door":-18.0,"north":true,"color":Color("#735e8c"),"center":Vector3(-18,0,8.8),"half":Vector2(4,3.2),"height":0.44},
	{"id":"nerve","title":"幽门窦 / PYLORIC ANTRUM","rect":Rect2(-8.9,-15.1,17.8,7.7),"door":0.0,"north":false,"color":Color("#534167"),"center":Vector3(0,0,-11.2),"half":Vector2(7.9,2.4),"height":0.40}
]
const LINKS = [
	{"id":"forest","a":Vector3(14.5,0.32,3.0),"b":Vector3(14.5,0.59,8.0),"color":Color("#a69b77")},
	{"id":"gut","a":Vector3(18,0.32,-2.0),"b":Vector3(18,0.53,-7.5),"color":Color("#bf80aa")},
	{"id":"lung","a":Vector3(-18,0.30,2.6),"b":Vector3(-18,0.49,7.3),"color":Color("#9ba4c8")},
	{"id":"nerve","a":Vector3(0,0.82,-5.3),"b":Vector3(0,0.43,-9.8),"color":Color("#8f90bc")}
]
var game
var material: StandardMaterial3D
var zone_label: Label
var overlay: ColorRect
var transition_label: Label
var current_zone := ""
var zone_time := 0.0
var transition_time := 0.0
var last_safe := Vector3(0,1.15,5.5)
var mesh_count := 0

func build(host) -> void:
	game = host
	material = Art.mat(Color.WHITE)
	material.vertex_color_use_as_albedo = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.roughness = 0.91
	material.metallic_specular = 0.22
	_build_outer_shell()
	for room in ROOMS:
		_build_chamber(room)
	for link in LINKS:
		_build_link(link)
	_ramp("NerveApproach",Vector3(0,0.035,-3.2),Vector3(0,0.825,-5.3),5.2,Color("#a46a85"))
	_align_existing_wall_details()
	_build_ui()
	set_meta("closed_boundary",true)
	set_meta("chamber_count",ROOMS.size())
	set_meta("walkable_links",LINKS.size())
	set_meta("visual_parts",mesh_count)

func _mesh(part_name: String, points: Array[Vector3], colors: Array[Color], indices: Array[int], solid := true) -> MeshInstance3D:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(0)
	for index in indices:
		surface.set_color(colors[index])
		surface.set_uv(Vector2(points[index].x,points[index].z)*0.2)
		surface.add_vertex(points[index])
	surface.generate_normals()
	surface.index()
	var item := MeshInstance3D.new()
	item.name = part_name
	item.mesh = surface.commit()
	item.material_override = material
	add_child(item)
	if solid:
		var body := StaticBody3D.new()
		body.name = "TerrainCollision"
		body.collision_layer = 5
		body.collision_mask = 0
		var shape := CollisionShape3D.new()
		var trimesh := item.mesh.create_trimesh_shape()
		trimesh.backface_collision = true
		shape.shape = trimesh
		body.add_child(shape)
		item.add_child(body)
	mesh_count += 1
	return item

func _indices(rows: int, cols: int) -> Array[int]:
	var result: Array[int] = []
	for row in range(rows):
		for col in range(cols):
			var a := row*(cols+1)+col
			var b := a+1
			var c := a+cols+1
			result.append_array([a,c,b,b,c,c+1])
	return result

func _edge(angle: float, v: float) -> Vector3:
	var cx := cos(angle)
	var sz := sin(angle)
	var bulge := 1.0+sin(v*PI)*0.022
	return Vector3(signf(cx)*sqrt(absf(cx))*EXTENT.x*bulge,
		lerpf(-0.25,11.2+sin(angle*3.0)*0.25,v),
		signf(sz)*sqrt(absf(sz))*EXTENT.y*bulge)

func _build_outer_shell() -> void:
	var points: Array[Vector3] = []
	var colors: Array[Color] = []
	for row in range(9):
		var v := float(row)/8.0
		for col in range(97):
			var a := TAU*float(col)/96.0
			var p := _edge(a,v)
			# Fine clay creases alter the silhouette without intruding on routes.
			p.x *= 1.0+sin(a*24.0)*sin(v*PI)*0.004
			p.z *= 1.0+sin(a*24.0)*sin(v*PI)*0.004
			points.append(p)
			colors.append(Color("#713b59").lerp(Color("#a7657b"),v*0.35+0.12*sin(a*24.0)))
	_mesh("ContinuousInnerWall",points,colors,_indices(8,96))
	for top in [false,true]:
		points = [Vector3(0,13.8 if top else -0.25,0)]
		colors = [Color("#703d59") if top else Color("#99516d")]
		var triangles: Array[int] = []
		for i in range(97):
			points.append(_edge(TAU*float(i)/96.0,1.0 if top else 0.0))
			colors.append(Color("#77435e") if top else Color("#944d69"))
			if i < 96: triangles.append_array([0,i+1,i+2])
		_mesh("ClosedVault" if top else "SealedUnderfloor",points,colors,triangles)
	for i in range(32):
		var a := TAU*float(i)/32.0
		var p := _edge(a,0.3)
		p.x *= 0.991
		p.z *= 0.991
		var crease := Art.capsule(self,"OuterMuscleFold",p,Vector3(0.28,3.7,0.28),Color("#ae7285"),Vector3(0,0,sin(a*3.0)*0.14))
		crease.set_meta("terrain_detail",true)

func _wall(part_name: String, a: Vector3, b: Vector3, bottom: float, top: float, color: Color) -> void:
	var points: Array[Vector3] = []
	var colors: Array[Color] = []
	var tangent := (b-a).normalized()
	var normal := Vector3(-tangent.z,0,tangent.x)
	for row in range(7):
		var v := float(row)/6.0
		for col in range(17):
			var t := float(col)/16.0
			var p := a.lerp(b,t)
			p.y = lerpf(bottom,top,v)
			p += normal*sin(PI*t)*sin(PI*v)*(0.48+0.22*sin(t*TAU*4.0))
			points.append(p)
			colors.append(color.lightened(0.035+sin(t*TAU*4.0)*0.035+v*0.045))
	_mesh(part_name,points,colors,_indices(6,16))

func _build_chamber(room: Dictionary) -> void:
	var r: Rect2 = room["rect"]
	var x0 := r.position.x
	var x1 := r.end.x
	var z0 := r.position.y
	var z1 := r.end.y
	var tag: String = room["id"]
	var color: Color = room["color"]
	_wall(tag+"WestWall",Vector3(x0,0,z0),Vector3(x0,0,z1),-0.25,7.8,color)
	_wall(tag+"EastWall",Vector3(x1,0,z1),Vector3(x1,0,z0),-0.25,7.8,color)
	var front := z0 if room["north"] else z1
	var back := z1 if room["north"] else z0
	var door: float = room["door"]
	_wall(tag+"BackWall",Vector3(x0,0,back),Vector3(x1,0,back),-0.25,7.8,color)
	_wall(tag+"DoorLeft",Vector3(x0,0,front),Vector3(door-2.7,0,front),-0.25,7.8,color)
	_wall(tag+"DoorRight",Vector3(door+2.7,0,front),Vector3(x1,0,front),-0.25,7.8,color)
	_wall(tag+"DoorLintel",Vector3(door-2.7,0,front),Vector3(door+2.7,0,front),5.85,7.8,color)
	var points: Array[Vector3] = []
	var colors: Array[Color] = []
	for row in range(9):
		var v := float(row)/8.0
		for col in range(13):
			var u := float(col)/12.0
			points.append(Vector3(lerpf(x0,x1,u),7.8+1.6*sin(u*PI)*sin(v*PI),lerpf(z0,z1,v)))
			colors.append(color.darkened(0.10))
	_mesh(tag+"ChamberVault",points,colors,_indices(8,12))
	for corner in [Vector3(x0,3.75,z0),Vector3(x1,3.75,z0),Vector3(x0,3.75,z1),Vector3(x1,3.75,z1)]:
		Art.sphere(self,tag+"RoundedTissueSeam",corner,Vector3(1.05,8.2,1.05),color.lightened(0.025))
	_skirt(tag,room["center"],room["half"],room["height"],color)
	var portal_label := Art.zone_label(self,room["title"],Vector3(door,4.2,front),color.lightened(0.55))
	portal_label.font_size = 27
	portal_label.pixel_size = 0.007
	for i in range(7):
		var t := (float(i)+0.5)/7.0
		Art.capsule(self,tag+"WallCrease",Vector3(lerpf(x0+0.5,x1-0.5,t),3.0,back+(0.10 if room["north"] else -0.10)),Vector3(0.14,2.8,0.12),color.lightened(0.16),Vector3(0,0,sin(t*TAU)*0.13))

func _skirt(tag: String, center: Vector3, half: Vector2, height: float, color: Color) -> void:
	var corners: Array[Vector2] = [Vector2(-1,-1),Vector2(1,-1),Vector2(1,1),Vector2(-1,1)]
	var points: Array[Vector3] = []
	var colors: Array[Color] = []
	var ids: Array[int] = []
	for c in corners:
		points.append(center+Vector3(c.x*half.x,height+0.008,c.y*half.y))
		colors.append(color.lightened(0.12))
		points.append(center+Vector3(c.x*(half.x+0.9),0.015,c.y*(half.y+0.9)))
		colors.append(Color("#99516d"))
	for i in range(4):
		var a := i*2
		var b := ((i+1)%4)*2
		ids.append_array([a,b,a+1,b,b+1,a+1])
	_mesh(tag+"SoftShelfSlope",points,colors,ids)

func _ramp(tag: String, a: Vector3, b: Vector3, width: float, color: Color) -> void:
	var forward := (b-a).normalized()
	var side := Vector3(-forward.z,0,forward.x).normalized()
	var points: Array[Vector3] = []
	var colors: Array[Color] = []
	for row in range(13):
		var t := float(row)/12.0
		for col in range(5):
			var u := float(col)/4.0
			points.append(a.lerp(b,t)+side*(u-0.5)*width)
			colors.append(Color("#a85f7b").lerp(color,t).lightened(sin(u*PI)*0.035))
	_mesh(tag+"WalkableFloor",points,colors,_indices(12,4))

func _build_link(link: Dictionary) -> void:
	var a: Vector3 = link["a"]
	var b: Vector3 = link["b"]
	var color: Color = link["color"]
	var tag: String = link["id"]
	var direction := (b-a).normalized()
	var side := Vector3(-direction.z,0,direction.x).normalized()
	_ramp(tag+"Link",a,b,5.2,color)
	var points: Array[Vector3] = []
	var colors: Array[Color] = []
	for row in range(13):
		var t := float(row)/12.0
		for col in range(25):
			var angle := float(col)/24.0*PI
			var radius := 2.6+sin(t*PI)*0.16
			var p := a.lerp(b,t)+side*cos(angle)*radius
			p.y += sin(angle)*5.15
			points.append(p)
			colors.append(Color("#a65e7c").lerp(color,t).darkened(0.10+0.04*sin(t*TAU*3.0)))
	_mesh(tag+"OrganicPassage",points,colors,_indices(12,24))
	# Cross-section ridges stop at the floor edge, never across the walking lane.
	for rib in range(4):
		var t := float(rib)/3.0
		points = []
		colors = []
		for row in range(2):
			for col in range(25):
				var angle := float(col)/24.0*PI
				var p := a.lerp(b,t)+direction*(float(row)-0.5)*0.13+side*cos(angle)*2.58
				p.y += sin(angle)*5.10
				points.append(p)
				colors.append(color.lightened(0.14))
		_mesh(tag+"PassageRib",points,colors,_indices(1,24),false)
	for i in range(5):
		var t := float(i)/4.0
		var p := a.lerp(b,t)+side*2.0+Vector3.UP*0.08
		Art.sphere(self,tag+"TrailBead",p,Vector3(0.16,0.06,0.26),color.lightened(0.3),0.9,0.3)

func _align_existing_wall_details() -> void:
	for detail in game.map_visual_root.get_children():
		if not (detail is MeshInstance3D): continue
		var n := String(detail.name)
		if n.begins_with("BackFold") or n.begins_with("ClayWallPrint"):
			detail.position.z = _back_wall_z(detail.position.x,detail.position.y)-0.18
		elif n.begins_with("RugaFold"):
			var z: float = detail.position.z
			detail.position.x = signf(detail.position.x)*(26.0*pow(maxf(0.01,1.0-pow(absf(z)/18.0,4.0)),0.25)-0.10)
	for detail in game.stomach_anatomy_root.get_children():
		if not (detail is MeshInstance3D): continue
		var n := String(detail.name)
		for prefix in ["CorpusMucosa","WallRuga","GastricPit","GlandGlow","MucusThread","MucusDrop"]:
			if n.begins_with(prefix):
				detail.position.z = _back_wall_z(detail.position.x,detail.position.y)-0.12
				break
		if n.begins_with("FundusLobe"):
			var z: float = detail.position.z
			detail.position.x = -(26.0*pow(maxf(0.01,1.0-pow(absf(z)/18.0,4.0)),0.25)-0.10)

func _back_wall_z(x: float, y: float) -> float:
	var bulge := 1.0+sin(clampf(y/11.2,0.0,1.0)*PI)*0.022
	return 18.0*bulge*pow(maxf(0.01,1.0-pow(absf(x)/(26.0*bulge),4.0)),0.25)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 25
	add_child(layer)
	zone_label = Label.new()
	zone_label.position = Vector2(270,252)
	zone_label.size = Vector2(740,38)
	zone_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	zone_label.add_theme_font_size_override("font_size",23)
	zone_label.add_theme_color_override("font_outline_color",Color("#291d33"))
	zone_label.add_theme_constant_override("outline_size",6)
	zone_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(zone_label)
	overlay = ColorRect.new()
	overlay.color = Color("#171321")
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.visible = false
	layer.add_child(overlay)
	transition_label = Label.new()
	transition_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	transition_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	transition_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	transition_label.add_theme_font_size_override("font_size",27)
	overlay.add_child(transition_label)

func enter_clinic() -> void:
	transition_time = 1.6
	overlay.modulate.a = 1.0
	overlay.visible = true
	transition_label.text = "胶囊返航 · 诊疗室\nCAPSULE RETURN / FINAL RESCUE"
	zone_label.visible = false

func zone_at(point: Vector3) -> String:
	point = game.authored_point(point)
	if is_instance_valid(game.mouth_intro) and game.mouth_intro.active:
		return "猫口腔 · 舌背" if point.z > 50 else "咽部 · 食道下行通道"
	for room in ROOMS:
		var rect: Rect2 = room["rect"]
		if rect.has_point(Vector2(point.x,point.z)):
			return room["title"]
	return "胃体救治中枢 / GASTRIC BODY"

func tick(delta: float) -> void:
	if not game.role_selected or game.game_paused: return
	if transition_time > 0.0:
		transition_time = maxf(0.0,transition_time-delta)
		overlay.modulate.a = clampf(transition_time/0.75,0.0,1.0)
		overlay.visible = transition_time > 0.0
	if game.mission_phase in ["host_boss","ending","win"]:
		zone_label.visible = false
		return
	var next_zone := zone_at(game.player.global_position)
	if next_zone != current_zone:
		current_zone = next_zone
		zone_time = 2.6
		zone_label.text = next_zone
	zone_time = maxf(0.0,zone_time-delta)
	zone_label.visible = zone_time > 0.0

func constrain_point(point: Vector3) -> Vector3:
	if is_instance_valid(game.mouth_intro) and game.mouth_intro.active: return game.mouth_intro.constrain(point)
	point = game.authored_point(point)
	var value := pow(absf(point.x)/24.9,4.0)+pow(absf(point.z)/16.9,4.0)
	if value > 1.0:
		var ratio := pow(value,-0.25)
		point.x *= ratio
		point.z *= ratio
	point.y = minf(point.y,10.0)
	return game.world_point(point)

func keep_inside() -> void:
	if is_instance_valid(game.mouth_intro) and game.mouth_intro.active:
		game.mouth_intro.keep_inside()
		return
	var p: Vector3 = game.player.global_position
	if p.y < -2.0:
		game.player.global_position = last_safe
		game.player.velocity = Vector3.ZERO
		return
	game.player.global_position = constrain_point(p)
	if game.player.is_on_floor():
		last_safe = game.player.global_position+Vector3.UP*0.15
