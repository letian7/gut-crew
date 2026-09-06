extends RefCounted
const CharacterArt = preload("res://scripts/art18_character.gd")
const Terrain = preload("res://scripts/terrain_world.gd")
const OrganicShell = preload("res://scripts/art18_organic_shell.gd")

static func apply(game) -> void:
	var world := Node3D.new()
	world.name = "Art18Environment"
	game.add_child(world)
	var packed := load("res://assets/art18/rugae_passage_art18.glb") as PackedScene
	assert(packed != null)
	for link in Terrain.LINKS:
		var a: Vector3 = link["a"]
		var b: Vector3 = link["b"]
		var direction := (b-a).normalized()
		var side := Vector3.UP.cross(direction).normalized()
		var up := direction.cross(side).normalized()
		var passage := packed.instantiate() as Node3D
		passage.name = String(link["id"]) + "SculptedPassage"
		world.add_child(passage)
		passage.transform = Transform3D(Basis(side,up,direction), (a+b)*0.5)
		passage.scale = Vector3(0.83,0.95,a.distance_to(b)/8.0)
		for mesh in passage.find_children("*","MeshInstance3D",true,false):
			for index in range(mesh.mesh.get_surface_count()):
				var mat := mesh.mesh.surface_get_material(index) as StandardMaterial3D
				if mat: mesh.set_surface_override_material(index, CharacterArt.clay_material(mat))
		for old in game.terrain_world.get_children():
			var old_name := String(old.name)
			if old_name.begins_with(String(link["id"])+"OrganicPassage") or old_name.begins_with(String(link["id"])+"PassageRib") or old_name.begins_with(String(link["id"])+"TrailBead"):
				old.visible = false
		var lamp := OmniLight3D.new()
		lamp.position = (a+b)*0.5 + Vector3.UP*2.9
		lamp.light_color = Color("eac9a2")
		lamp.light_energy = 1.3
		lamp.omni_range = 7.0
		world.add_child(lamp)
	# Keep all existing static bodies and camera blockers. Only replace materials.
	for group in [game.terrain_world, game.map_visual_root, game.stomach_anatomy_root, game.world_expansion_root, game.organ_world_root]:
		for item in group.find_children("*", "MeshInstance3D", true, false):
			var old := item.material_override as StandardMaterial3D
			if old == null: continue
			var mat := CharacterArt.clay_material(old).duplicate() as StandardMaterial3D
			var color := old.albedo_color
			color = color.lerp(Color(color.v,color.v,color.v,color.a),0.15)
			mat.albedo_color = color
			if old.emission_enabled:
				mat.emission_enabled = true
				mat.emission = old.emission
				mat.emission_energy_multiplier = minf(old.emission_energy_multiplier,0.28)
			item.material_override = mat
		for label in group.find_children("*","Label3D",true,false):
			label.visibility_range_end = 12.0
			label.modulate = Color("dfd8cd")
	for node in game.get_children():
		if node is WorldEnvironment:
			node.environment.ambient_light_color = Color("b9b0aa")
			node.environment.ambient_light_energy = 0.72
		elif node is DirectionalLight3D:
			node.light_color = Color("ffdfb5")
			node.light_energy = 1.25
		elif node is OmniLight3D:
			node.light_color = Color("e9c0aa")
			node.light_energy = 2.2
	if game.acid_mesh:
		var acid := game.acid_mesh.material_override as StandardMaterial3D
		acid.albedo_color = Color(0.36,0.46,0.13,0.92)
		acid.emission = Color("819d48")
		acid.emission_energy_multiplier = 0.3
		acid.roughness = 0.40
		acid.normal_enabled = true
		acid.normal_texture = CharacterArt.surface_noise
		acid.normal_scale = 0.22
	for room in Terrain.ROOMS:
		var lamp := OmniLight3D.new()
		lamp.position = room["center"] + Vector3.UP*4.8
		lamp.light_color = [Color("d9bf8e"),Color("c8a3b7"),Color("b6cddd"),Color("b9b0d0")][Terrain.ROOMS.find(room)]
		lamp.light_energy = 2.0
		lamp.omni_range = 11.0
		world.add_child(lamp)
	world.set_meta("visual_only",true)
	world.set_meta("sculpted_passages",4)
	game.set_meta("art18_world",world)
	OrganicShell.apply(game,world)
	for group in [game.map_visual_root, game.world_expansion_root, game.stomach_anatomy_root, game.organ_world_root]:
		for lamp in group.find_children("*","OmniLight3D",true,false):
			lamp.light_color = lamp.light_color.lerp(Color("dfc1ad"),0.72)
			lamp.light_energy = minf(lamp.light_energy,0.85)
	for mesh in game.get_children():
		if mesh is MeshInstance3D and mesh.mesh is SphereMesh:
			var old := mesh.material_override as StandardMaterial3D
			if old:
				var material := CharacterArt.clay_material(old).duplicate() as StandardMaterial3D
				material.albedo_color = old.albedo_color.lerp(Color("987681"),0.4)
				mesh.material_override = material
	game.set_meta("art19_light_balance",true)
