extends RefCounted
const Clay = preload("res://scripts/art18_character.gd")

static func _mesh(parent: Node3D, name_text: String, points: Array[Vector3], indices: Array[int], tint: Color) -> MeshInstance3D:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(0)
	for index in indices:
		var p := points[index]
		var variation := sin(p.x*2.1+p.y*0.8)*sin(p.z*1.3-p.y)*0.026
		surface.set_color(tint.lightened(variation))
		surface.add_vertex(p)
	surface.generate_normals()
	surface.index()
	var node := MeshInstance3D.new()
	node.name = name_text
	node.mesh = surface.commit()
	var base := StandardMaterial3D.new()
	base.vertex_color_use_as_albedo = true
	base.roughness = 0.87
	base.cull_mode = BaseMaterial3D.CULL_DISABLED
	node.material_override = Clay.clay_material(base)
	parent.add_child(node)
	return node

static func chamber(parent: Node3D, room: Dictionary) -> void:
	var rect: Rect2 = room["rect"]
	var radius := 1.15
	var centers: Array[Vector2] = [Vector2(rect.end.x-radius,rect.position.y+radius),Vector2(rect.end.x-radius,rect.end.y-radius),Vector2(rect.position.x+radius,rect.end.y-radius),Vector2(rect.position.x+radius,rect.position.y+radius)]
	var contour: Array[Vector2] = []
	for corner in range(4):
		var first_angle := -PI*0.5+float(corner)*PI*0.5
		for j in range(13):
			var angle := first_angle+float(j)/12.0*PI*0.5
			contour.append(centers[corner]+Vector2(cos(angle),sin(angle))*radius)
		var end: Vector2 = contour[-1]
		var next_angle := first_angle+PI*0.5
		var next_point := centers[(corner+1)%4]+Vector2(cos(next_angle),sin(next_angle))*radius
		var samples := maxi(2,int(end.distance_to(next_point)/0.24))
		for j in range(1,samples): contour.append(end.lerp(next_point,float(j)/float(samples)))
	var n := contour.size()
	var center := rect.get_center()
	var points: Array[Vector3] = []
	var heights: Array[float] = [-0.25,0.0,1.0,2.5,4.0,5.65,6.6,7.8]
	for row in range(heights.size()):
		var y := heights[row]
		for i in range(n):
			var v := contour[i]-center
			var inset := 1.0-0.028*sin(clampf(y/7.8,0.0,1.0)*PI)
			var fold := sin(float(i)/float(n)*TAU*18.0+y*0.23)*sin(clampf(y/7.8,0.0,1.0)*PI)*0.026
			var point := center+v*inset-v.normalized()*fold
			points.append(Vector3(point.x,y,point.y))
	var indices: Array[int] = []
	var front: float = rect.position.y if room["north"] else rect.end.y
	for row in range(heights.size()-1):
		for j in range(n):
			var next := (j+1)%n
			var mid := (contour[j]+contour[next])*0.5
			if row < 5 and absf(mid.y-front)<0.02 and absf(mid.x-float(room["door"]))<3.04: continue
			var a := row*n+j
			var b := row*n+next
			indices.append_array([a,b,a+n,b,b+n,a+n])
	_mesh(parent,String(room["id"])+"RoundedChamber",points,indices,(room["color"] as Color).lerp(Color("a18481"),0.35))
	points.clear()
	indices.clear()
	var scales: Array[float] = [1.0,0.84,0.61,0.32,0.01]
	var ys: Array[float] = [7.8,8.55,9.05,9.38,9.5]
	for row in range(scales.size()):
		for c in contour:
			var p := center+(c-center)*scales[row]
			points.append(Vector3(p.x,ys[row],p.y))
	for row in range(scales.size()-1):
		for j in range(n):
			var a := row*n+j
			var b := row*n+(j+1)%n
			indices.append_array([a,b,a+n,b,b+n,a+n])
	points.append(Vector3(center.x,9.5,center.y))
	for j in range(n): indices.append_array([points.size()-1,4*n+j,4*n+(j+1)%n])
	_mesh(parent,String(room["id"])+"DomedRoof",points,indices,(room["color"] as Color).lerp(Color("846f77"),0.35))

static func rounded_box(size: Vector3) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half := size*0.5
	var r := minf(0.16,minf(half.x,minf(half.y,half.z))*0.42)
	var inner := half-Vector3.ONE*r
	for axis in range(3):
		for sign_value in [-1.0,1.0]:
			var normal := Vector3.ZERO
			normal[axis] = sign_value
			var tangent := Vector3.ZERO
			tangent[(axis+1)%3] = 1
			var bitangent := normal.cross(tangent)
			var grid: Array[Vector3] = []
			var normals: Array[Vector3] = []
			for row in range(9):
				for col in range(9):
					var unit := normal+tangent*(float(col)/4.0-1)+bitangent*(float(row)/4.0-1)
					var p := unit*half
					var nearest := p.clamp(-inner,inner)
					var n := (p-nearest).normalized()
					grid.append(nearest+n*r)
					normals.append(n)
			for row in range(8):
				for col in range(8):
					var a := row*9+col
					for index in [a,a+9,a+1,a+1,a+9,a+10]:
						surface.set_normal(normals[index])
						surface.add_vertex(grid[index])
	surface.index()
	return surface.commit()

static func apply(game, world: Node3D) -> void:
	outer_wall(game, world)
	for room in game.terrain_world.ROOMS:
		chamber(world,room)
		for old in game.terrain_world.get_children():
			var n := String(old.name)
			if n.begins_with(String(room["id"])) and ("Wall" in n or "Door" in n or "ChamberVault" in n or "RoundedTissueSeam" in n or "WallCrease" in n):
				old.visible = false
	for group in [game.map_visual_root,game.stomach_anatomy_root]:
		for child in group.get_children():
			var n := String(child.name)
			for prefix in ["GlandPore","GlandGlow","MucusStrand","MucusDrop","CorpusMucosa","ClayWallPrint","CeilingBulge","BackFold","RugaFold","WallRuga","MucusThread","GastricPit","HangingFold","PyloricCollar","CardiaRosette","MuscleFiber","SideFiber","CardiaGateModel","PyloricGateModel","CardiaPetal","PyloricPetal"]:
				if n.begins_with(prefix): child.visible = false
	for node in game.find_children("*","StaticBody3D",true,false):
		if node is StaticBody3D:
			for visual in node.get_children():
				if visual is MeshInstance3D and visual.mesh is BoxMesh:
					var size: Vector3 = visual.mesh.size
					visual.mesh = rounded_box(size)
					var source := visual.material_override as StandardMaterial3D
					if source:
						var mat := Clay.clay_material(source).duplicate() as StandardMaterial3D
						mat.albedo_color = source.albedo_color.lerp(Color("967879"),0.48)
						visual.material_override = mat
	for node in game.get_children():
		if node is WorldEnvironment:
			node.environment.ambient_light_energy = 0.36
		elif node is DirectionalLight3D:
			node.light_energy = 0.8
	var key := SpotLight3D.new()
	key.name = "WarmInnerKey"
	key.position = Vector3(-5,8.6,-2)
	key.light_color = Color("f6d4b1")
	key.light_energy = 3.6
	key.spot_range = 27
	key.spot_angle = 76
	key.shadow_enabled = true
	key.shadow_bias = 0.25
	key.shadow_normal_bias = 4.0
	world.add_child(key)
	key.look_at(Vector3(0,0,3))
	world.set_meta("rounded_chambers",4)

static func outer_wall(game, parent: Node3D) -> void:
	var points: Array[Vector3] = []
	var indices: Array[int] = []
	for row in range(33):
		var v := float(row)/32.0
		for col in range(193):
			var a := TAU*float(col)/192.0
			var p: Vector3 = game.terrain_world._edge(a,v)
			var inward := (0.5+0.5*sin(a*22.0+sin(v*PI)*0.45))*sin(v*PI)*0.52
			var radial := Vector3(p.x,0,p.z).normalized()
			p -= radial*inward
			points.append(p)
	for row in range(32):
		for col in range(192):
			var a := row*193+col
			indices.append_array([a,a+1,a+193,a+1,a+194,a+193])
	_mesh(parent,"SculptedOuterWall",points,indices,Color("9b717b"))
	game.terrain_world.get_node("ContinuousInnerWall").visible = false
