extends RefCounted
const Clay = preload("res://scripts/art18_character.gd")
const PATHS = {"HAIRBALL":"hairball", "PLATELET":"platelet", "PARASITE":"parasite", "MOCHI":"mochi", "HAND":"hand", "CAPSULE":"capsule"}

static func attach(root: Node3D, kind: String) -> void:
	if not PATHS.has(kind) or root.has_node("Art19Model"): return
	var anchors := {}
	for old in root.find_children("*", "Node3D", true, false):
		anchors[String(old.name)] = old
		if old is MeshInstance3D: old.visible = false
	var packed := load("res://assets/art19/%s_art19.glb" % PATHS[kind]) as PackedScene
	var art := packed.instantiate() as Node3D
	art.name = "Art19Model"
	root.add_child(art)
	var bindings: Array = []
	var materials: Array = []
	for part in art.find_children("*", "Node3D", true, false):
		if anchors.has(String(part.name)) and not part is MeshInstance3D:
			var anchor: Node3D = anchors[String(part.name)]
			bindings.append({"art":part,"anchor":anchor,"rest_inverse":anchor.transform.affine_inverse(),"model_rest":part.transform})
		if part is MeshInstance3D:
			for surface in range(part.mesh.get_surface_count()):
				var source := part.mesh.surface_get_material(surface) as StandardMaterial3D
				if source == null: continue
				var material := Clay.clay_material(source).duplicate() as StandardMaterial3D
				part.set_surface_override_material(surface, material)
				materials.append({"material":material,"base":material.albedo_color})
	root.set_meta("art19_revision",19)
	root.set_meta("art19_bindings",bindings)
	root.set_meta("art19_materials",materials)
	sync(root)

static func sync(root: Node3D) -> void:
	for binding in root.get_meta("art19_bindings",[]):
		if is_instance_valid(binding.anchor) and is_instance_valid(binding.art):
			binding.art.transform = binding.anchor.transform * binding.rest_inverse * binding.model_rest

static func set_hit_flash(root: Node3D, active: bool) -> void:
	for entry in root.get_meta("art19_materials",[]):
		entry.material.albedo_color = Color(1,1,1,entry.base.a) if active else entry.base
