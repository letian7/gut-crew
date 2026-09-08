extends RefCounted
## Shared handcrafted surfaces and continuous sculpted tubes, bounded for integrated GPUs.
static var bump: NoiseTexture2D

static func material(color: Color, roughness: float = 0.72) -> StandardMaterial3D:
	if bump == null:
		var noise := FastNoiseLite.new()
		noise.seed = 3401
		noise.frequency = 0.075
		bump = NoiseTexture2D.new()
		bump.width = 128
		bump.height = 128
		bump.noise = noise
		bump.seamless = true
		bump.as_normal_map = true
		bump.bump_strength = 0.7
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	m.normal_enabled = true
	m.normal_texture = bump
	m.normal_scale = 0.24
	m.uv1_scale = Vector3(2, 3, 1)
	return m

static func tube(parent: Node3D, label: String, points: PackedVector3Array, radius: float, color: Color, taper: bool = false) -> MeshInstance3D:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	var sides := 12
	for i in range(points.size()):
		var t := float(i) / float(points.size()-1)
		var tangent := (points[mini(i+1,points.size()-1)]-points[maxi(0,i-1)]).normalized()
		var reference := Vector3.UP if absf(tangent.y)<0.90 else Vector3.RIGHT
		var normal := tangent.cross(reference).normalized()
		var binormal := tangent.cross(normal).normalized()
		var width := radius * (0.88 + 0.12*cos(t*TAU*2.0))
		if taper: width *= lerpf(1.0,0.07,pow(t,2.5))
		for j in range(sides+1):
			var a := TAU*float(j)/float(sides)
			var radial := normal*cos(a)+binormal*sin(a)
			vertices.append(points[i]+radial*width)
			normals.append(radial)
			uvs.append(Vector2(float(j)/sides,t))
			if i < points.size()-1 and j < sides:
				var k := i*(sides+1)+j
				indices.append_array(PackedInt32Array([k,k+sides+1,k+1,k+1,k+sides+1,k+sides+2]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX]=vertices
	arrays[Mesh.ARRAY_NORMAL]=normals
	arrays[Mesh.ARRAY_TEX_UV]=uvs
	arrays[Mesh.ARRAY_INDEX]=indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	var part := MeshInstance3D.new()
	part.name=label
	part.mesh=mesh
	var surface := material(color)
	surface.cull_mode=BaseMaterial3D.CULL_DISABLED
	if color.a<0.999: surface.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
	part.material_override=surface
	parent.add_child(part)
	return part

static func bezier(a: Vector3,b: Vector3,c: Vector3,d: Vector3) -> PackedVector3Array:
	var points := PackedVector3Array()
	for i in range(25):
		var t := float(i)/24.0
		points.append(a*pow(1.0-t,3)+b*3.0*pow(1.0-t,2)*t+c*3.0*(1.0-t)*t*t+d*t*t*t)
	return points

static func hook(parent: Node3D, label: String, center: Vector3, size: float) -> MeshInstance3D:
	var points := PackedVector3Array()
	for i in range(33):
		var a := lerpf(-0.85,4.3,float(i)/32.0)
		points.append(center+Vector3(cos(a)*size,sin(a)*size,0.035*sin(a*2.0)))
	return tube(parent,label,points,size*0.25,Color("#e5cdaa"),true)

static func debris(parent: Node3D, pos: Vector3, radius: float) -> void:
	var cloud := Node3D.new()
	cloud.name="PhysicalBoneDebris34"
	parent.add_child(cloud)
	for i in range(16):
		var body := RigidBody3D.new()
		body.name="RibFragment"
		body.collision_layer=0
		body.collision_mask=1
		body.mass=0.12
		body.linear_damp=0.5
		var physics := PhysicsMaterial.new()
		physics.bounce=0.35
		physics.friction=0.8
		body.physics_material_override=physics
		cloud.add_child(body)
		body.global_position=pos+Vector3(0,0.5+float(i%4)*0.35,0)
		var visual := MeshInstance3D.new()
		var bone := CapsuleMesh.new()
		bone.radius=0.065
		bone.height=0.25+float(i%3)*0.11
		visual.mesh=bone
		visual.material_override=material(Color("#dbc6a4"))
		body.add_child(visual)
		var collision := CollisionShape3D.new()
		var shape := CapsuleShape3D.new()
		shape.radius=bone.radius
		shape.height=bone.height
		collision.shape=shape
		body.add_child(collision)
		var angle := TAU*float(i)/16.0
		body.linear_velocity=Vector3(cos(angle)*radius,3.2+float(i%4)*0.7,sin(angle)*radius)
		body.angular_velocity=Vector3(3.0,float(i%5)*1.7,4.0)
	parent.get_tree().create_timer(2.4).timeout.connect(cloud.queue_free)
