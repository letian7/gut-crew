extends SceneTree
const EnemyFactory = preload("res://scripts/enemy_factory.gd")

func _init() -> void:
	var required := {
		"HAIRBALL": ["HairballBody","FuzzTuft","Tongue"],
		"PLATELET": ["PlateletBody","HelmetDome","HelmetBrim","Vest"],
		"PARASITE": ["ParasiteHead","ParasiteSegment","ParasiteMouth","ParasiteTooth"]
	}
	for kind in required.keys():
		var holder := Node3D.new()
		root.add_child(holder)
		var built: Dictionary = EnemyFactory.build(holder, kind)
		var visual := built["visual"] as Node3D
		var main := built["main_mesh"] as MeshInstance3D
		assert(visual != null and main != null)
		for part_name in required[kind]: assert(visual.get_node_or_null(part_name) != null)
		assert(visual.scale.x > 1.0)
		EnemyFactory.animate(visual, kind, 1.2, Vector3(2,0,-1), false, false)
		assert(absf(visual.rotation.y) > 0.01)
		var base := (main.material_override as StandardMaterial3D).albedo_color
		EnemyFactory.set_hit_flash(visual,true)
		assert((main.material_override as StandardMaterial3D).albedo_color.r > 0.95)
		EnemyFactory.set_hit_flash(visual,false)
		assert((main.material_override as StandardMaterial3D).albedo_color.is_equal_approx(base))
		holder.queue_free()
	var death_holder := Node3D.new()
	root.add_child(death_holder)
	EnemyFactory.spawn_death(death_holder,"HAIRBALL",Vector3.ZERO)
	assert(death_holder.get_child_count() >= 10)
	var packed: PackedScene = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	assert(game.enemies.size() >= 4)
	for e in game.enemies:
		assert(e.get_meta("visual") != null)
	print("GODOT_ENEMY_MODELS_V2_OK enemies=", game.enemies.size())
	quit(0)
