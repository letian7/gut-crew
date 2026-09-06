extends RefCounted
## The old nodes remain animation anchors. New meshes own all visible anatomy.
const PATHS := ["spark", "kaka", "bubble", "shroom"]
static var surface_noise: NoiseTexture2D
static var material_cache: Dictionary = {}

static func clay_material(source: StandardMaterial3D) -> StandardMaterial3D:
	var key := source.get_instance_id()
	if material_cache.has(key): return material_cache[key]
	if surface_noise == null:
		var noise := FastNoiseLite.new()
		noise.seed = 18092
		noise.frequency = 0.065
		noise.fractal_octaves = 3
		surface_noise = NoiseTexture2D.new()
		surface_noise.width = 128
		surface_noise.height = 128
		surface_noise.seamless = true
		surface_noise.noise = noise
		surface_noise.as_normal_map = true
		surface_noise.bump_strength = 0.65
	var result := source.duplicate() as StandardMaterial3D
	result.normal_enabled = true
	result.normal_texture = surface_noise
	result.normal_scale = 0.20
	result.uv1_triplanar = true
	result.uv1_scale = Vector3(2.8, 2.8, 2.8)
	result.metallic_specular = 0.26
	result.emission_enabled = false
	material_cache[key] = result
	return result

static func attach(root: Node3D, role: int) -> void:
	var packed := load("res://assets/art18/" + PATHS[role] + "_art18.glb") as PackedScene
	assert(packed != null, "ART18 role import unavailable")
	var art := packed.instantiate() as Node3D
	art.name = "Art18Model"
	var legacy_count := root.get_child_count()
	for child in root.get_children():
		if child is MeshInstance3D: child.visible = false
	root.add_child(art)
	var bindings: Array[Dictionary] = []
	for group in art.find_children("*", "Node3D", true, false):
		var anchor := root.get_node_or_null(NodePath(String(group.name))) as Node3D
		if anchor == null: continue
		bindings.append({"art":group,"anchor":anchor,"base_scale":anchor.scale,"offset":group.position-anchor.position})
	for child in art.find_children("*", "MeshInstance3D", true, false):
		var mesh := child as MeshInstance3D
		for surface in range(mesh.mesh.get_surface_count()):
			var source := mesh.mesh.surface_get_material(surface) as StandardMaterial3D
			if source: mesh.set_surface_override_material(surface, clay_material(source))
	root.set_meta("art18_bindings", bindings)
	root.set_meta("art18_legacy_count", legacy_count)
	root.set_meta("art18_revision", 18)
	root.set_meta("art18_source", PATHS[role] + "_art18.glb")
	root.set_meta("art18_visible_meshes", art.find_children("*", "MeshInstance3D", true, false).size())
	sync(root, role)

static func sync(root: Node3D, role: int) -> void:
	if not root.has_meta("art18_bindings"): return
	var head := root.get_node_or_null(["SparkHead","KakaHead","BubbleHead","ShroomFace"][role]) as Node3D
	var head_delta := Basis.from_euler(head.rotation) if head else Basis.IDENTITY
	var bindings: Array = root.get_meta("art18_bindings")
	for binding: Dictionary in bindings:
		var anchor: Node3D = binding["anchor"]
		var model: Node3D = binding["art"]
		var base: Vector3 = binding["base_scale"]
		var offset: Vector3 = binding["offset"]
		model.position = anchor.position + offset
		model.rotation = anchor.rotation
		model.scale = anchor.scale / base
		var name_text := String(anchor.name)
		if head and ("Mouth" in name_text or "Brow" in name_text):
			model.position = head.position + head_delta * (model.position - head.position)
			model.basis = head_delta * model.basis
