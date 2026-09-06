extends RefCounted
# Preserve sculpture proportions independently of the five-times ground layout.
static func capture(game) -> Array:
	var result: Array = []
	var prefixes := ["UpperTooth","LowerTooth","UpperGum","Gum","TonguePapilla","TangledHair","HairBridge","HairNest","HairCocoon","GutLoop","SqueezeGate","Alveolus","SynapseNode","HiddenFurItem","StaticArc","PerimeterGland","TissueNodule"]
	for group in [game.mouth_intro,game.organ_world_root,game.map_visual_root,game.world_expansion_root]:
		for child in group.get_children():
			if not child is MeshInstance3D: continue
			# Godot anonymizes duplicate names; use geometry metadata, not display names.
			if group == game.mouth_intro and (child.get_meta("sculpted_tooth",false) or child.mesh is SphereMesh):
				result.append({"node":child,"transform":child.global_transform,"size":1.6})
				continue
			for prefix in prefixes:
				if String(child.name).begins_with(prefix):
					var size := 1.6 if group == game.mouth_intro else 2.0
					result.append({"node":child,"transform":child.global_transform,"size":size})
					break
	return result

static func apply(game, items: Array) -> void:
	for entry in items:
		var node: MeshInstance3D = entry.node
		var old: Transform3D = entry.transform
		# Top-level transform keeps animation rotations free of parent shear.
		# Visibility still follows the organ/mouth parent for cinematic transitions.
		node.top_level = true
		node.global_transform = Transform3D(old.basis*entry.size,game.world_point(old.origin))
		node.set_meta("base_scale",node.scale)
		node.set_meta("base_rotation",node.rotation)
		node.set_meta("sculpture_proportion25",true)
		node.visibility_range_end = 65.0
		node.visibility_range_end_margin = 8.0
	# Geometry remains continuous; small distant decorations need not all draw.
	var culled := 0
	for group in [game.map_visual_root,game.stomach_anatomy_root,game.organ_world_root,game.world_expansion_root]:
		for mesh in group.find_children("*","MeshInstance3D",true,false):
			if mesh.mesh.get_aabb().size.length()*mesh.global_basis.get_scale().length() > 32.0: continue
			if not mesh.find_children("*","StaticBody3D",true,false).is_empty(): continue
			mesh.visibility_range_end = 65.0
			mesh.visibility_range_end_margin = 8.0
			culled += 1
	for node in game.get_children():
		if node is WorldEnvironment: node.environment.ambient_light_energy = 0.48
	# Soft personal fill keeps the clay silhouette readable without a fullbright scene.
	var fill := OmniLight3D.new()
	fill.name = "CrewSoftFill25"
	fill.position = Vector3(0,2.6,2.0)
	fill.light_color = Color("ffe6c9")
	fill.light_energy = 0.85
	fill.omni_range = 7.5
	fill.omni_attenuation = 1.5
	fill.shadow_enabled = false
	game.player.add_child(fill)
	game.set_meta("proportion_fixed25",items.size())
	game.set_meta("distance_details25",culled)
