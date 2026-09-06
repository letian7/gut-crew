extends SceneTree

func _init() -> void:
	create_timer(45.0).timeout.connect(func(): push_error("ART18 watchdog expired"); quit(1))
	call_deferred("_run")

func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0, false)
	game.set_process(false)
	game.set_physics_process(false)
	var counts: Array[int] = []
	for role in range(4):
		game._set_role(role)
		await process_frame
		var visual: Node3D = game.character_visual
		assert(int(visual.get_meta("art18_revision",0)) == 18)
		var art := visual.get_node("Art18Model") as Node3D
		var meshes := art.find_children("*","MeshInstance3D",true,false)
		assert(meshes.size() >= 10)
		var triangles := 0
		for mesh in meshes:
			assert(mesh.visible and mesh.mesh is ArrayMesh)
			for surface in range(mesh.mesh.get_surface_count()):
				triangles += int(mesh.mesh.surface_get_array_index_len(surface)/3)
				var mat := mesh.get_surface_override_material(surface) as StandardMaterial3D
				assert(mat != null and mat.normal_enabled and mat.normal_texture != null)
		assert(triangles > 10000 and triangles < 60000)
		counts.append(triangles)
		for child in visual.get_children():
			if child is MeshInstance3D: assert(not child.visible)
		game.anim_cast_time = 0.23
		game.anim_cast_slot = 1
		game._animate_role_model(0.016)
		var bindings: Array = visual.get_meta("art18_bindings")
		print("ART18_BINDINGS role=",role," count=",bindings.size())
		assert(bindings.size() == [13,11,8,8][role])
		for binding: Dictionary in bindings:
			var model: Node3D = binding["art"]
			assert(model.scale.is_finite() and model.scale.length() < 4.0)
		game.anim_cast_time = 0.0
		game._animate_role_model(0.016)
		var head := visual.get_node(["SparkHead","KakaHead","BubbleHead","ShroomFace"][role]) as Node3D
		assert(absf(head.rotation.x) < 0.001)
		if role == 0:
			assert(is_equal_approx(visual.get_node("SparkProngL").scale.y,0.52))
		game.ko_time = 1.0
		game._animate_role_model(0.016)
		assert(visual.scale.y < 0.15)
		game.ko_time = 0.0
		game.anim_reassemble_time = 0.5
		game._animate_role_model(0.016)
		assert(visual.scale.y > 0.15 and visual.scale.y < 0.9)
		game.anim_reassemble_time = 0.0
	game.first_person = false
	game._toggle_view()
	assert(not game.character_visual.visible)
	game._toggle_view()
	assert(game.character_visual.visible)
	var world: Node3D = game.get_meta("art18_world")
	assert(int(world.get_meta("sculpted_passages",0)) == 4)
	assert(int(world.get_meta("rounded_chambers",0)) == 4)
	assert(world.get_node("SculptedOuterWall").visible)
	assert(not game.terrain_world.get_node("ContinuousInnerWall").visible)
	for tag in ["forest","gut","lung","nerve"]:
		assert(world.get_node(tag+"RoundedChamber").visible)
		assert(world.get_node(tag+"DomedRoof").visible)
	for part in game.map_visual_root.get_children():
		if part.has_meta("art_part"):
			var original_name: String = part.get_meta("art_part")
			assert(String(part.name).begins_with(original_name))
			if original_name in ["BackFold","RugaFold","GlandPore","GlandGlow","MucusDrop","MucusStrand","ClayWallPrint","CeilingBulge"]:
				assert(not part.visible)
	assert(world.find_children("*","StaticBody3D",true,false).is_empty())
	assert(game.terrain_world.get_meta("closed_boundary"))
	var expired := Node3D.new()
	game.add_child(expired)
	game.bone_structures.append(expired)
	game.surf_lanes.append(expired)
	game.fungus_patches.append(expired)
	game.bone_projectiles.append(expired)
	expired.free()
	game._near_bone(Vector3.ZERO, 5.0)
	game._tick_zones(0.01)
	game._tick_bone_projectiles(0.01)
	assert(game.bone_structures.is_empty() and game.surf_lanes.is_empty())
	assert(game.fungus_patches.is_empty() and game.bone_projectiles.is_empty())
	print("GODOT_PHASE18_ART_OK triangles=",counts," links=4 normal_maps=shared animations=restored")
	quit(0)
