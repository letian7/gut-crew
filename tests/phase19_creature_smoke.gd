extends SceneTree
const Enemies = preload("res://scripts/enemy_factory.gd")
const Art = preload("res://scripts/art19_creatures.gd")

func check_model(visual: Node3D, binding_count: int) -> void:
	assert(visual.get_meta("art19_revision",0) == 19)
	assert(visual.get_meta("art19_bindings",[]).size() == binding_count)
	var triangle_count := 0
	var model := visual.get_node("Art19Model")
	for mesh in model.find_children("*","MeshInstance3D",true,false):
		assert(mesh.visible and mesh.mesh is ArrayMesh)
		for surface in range(mesh.mesh.get_surface_count()):
			triangle_count += mesh.mesh.surface_get_array_index_len(surface) / 3
			var material = mesh.get_surface_override_material(surface)
			assert(material.normal_enabled and material.normal_texture != null)
	assert(triangle_count > 10000 and triangle_count < 60000)
	for old in visual.find_children("*","MeshInstance3D",true,false):
		if not model.is_ancestor_of(old):
			# Phase22 adds an explicit expression mesh; legacy primitive meshes must still be hidden.
			if old.get_meta("art22_detail_kind","") == "expression_brow":
				assert(old.name == "AngryEyebrows" and old.mesh is ArrayMesh)
				assert(old.material_override is StandardMaterial3D and old.material_override.normal_enabled)
			else:
				assert(not old.visible)
	for binding in visual.get_meta("art19_bindings"):
		var expected: Transform3D = binding.anchor.transform * binding.rest_inverse * binding.model_rest
		assert(binding.art.transform.is_equal_approx(expected))
	print("ART19_MODEL_OK ",visual.name," triangles=",triangle_count," bindings=",binding_count)

func _init() -> void:
	create_timer(45.0).timeout.connect(func(): printerr("PHASE19_TIMEOUT"); quit(1))
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0, false)
	game.set_process(false)
	game.set_physics_process(false)
	check_model(game.entrance,0)
	var counts := [1,3,1]
	var kinds := ["HAIRBALL","PLATELET","PARASITE"]
	for index in range(3):
		var first: Node3D = Enemies.build(game,kinds[index]).visual
		var second: Node3D = Enemies.build(game,kinds[index]).visual
		check_model(first,counts[index])
		var original: Array = []
		for binding in first.get_meta("art19_bindings"): original.append(binding.art.transform)
		Enemies.animate(first,kinds[index],1.0,Vector3.ONE,false,false,1.0)
		check_model(first,counts[index])
		var changed := false
		for i in range(original.size()):
			if not original[i].is_equal_approx(first.get_meta("art19_bindings")[i].art.transform): changed = true
		assert(changed)
		Enemies.set_hit_flash(first,true)
		for entry in first.get_meta("art19_materials"): assert(entry.material.albedo_color == Color.WHITE)
		for entry in second.get_meta("art19_materials"): assert(entry.material.albedo_color == entry.base)
		Enemies.set_hit_flash(first,false)
		for entry in first.get_meta("art19_materials"): assert(entry.material.albedo_color == entry.base)
		first.queue_free()
		second.queue_free()
	game.mission_phase = "return"
	game._begin_host_boss()
	var boss = game.host_boss
	check_model(boss.cat,3)
	check_model(boss.hand,0)
	assert(game.get_meta("art19_light_balance",false))
	boss.attack_index = 0
	boss._begin_attack()
	boss.tick(0.1)
	check_model(boss.cat,3)
	assert(boss.paw_right.position.y > 1.5)
	boss._resolve_attack()
	boss.tick(0.01)
	check_model(boss.cat,3)
	assert(boss.paw_right.position.z > 4.0)
	boss.state = "recover"
	game._damage_enemy(boss.target,10000.0)
	assert(game.mission_phase == "ending")
	boss.tick(0.1)
	check_model(boss.cat,3)
	for page in range(4):
		boss.tick(0.01)
		check_model(boss.cat,3)
		boss.story_elapsed = 1.1
		boss.advance_story()
	assert(game.mission_phase == "win" and boss.rescued)
	print("GODOT_PHASE19_CREATURES_OK enemies=3 boss=cat flash=isolated animations=bound ending=win")
	quit(0)
