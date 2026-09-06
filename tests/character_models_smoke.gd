extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	var keys: Array[String] = ["SparkProngL", "KakaToolL", "BubbleCore", "ShroomCap"]
	var counts: Array[int] = []
	for i in range(4):
		game._set_role(i)
		await process_frame
		counts.append(game.character_visual.get_child_count())
		assert(game.character_visual.get_node_or_null(keys[i]) != null)
		assert(game.body_mesh != null and game.head_mesh != null)
	assert(counts.min() >= 10)
	game._set_role(2)
	game.ferment_time = 0.0
	game._animate_role_model(0.0)
	var base_scale: Vector3 = game.character_visual.scale
	game.ferment_time = 2.0
	game._animate_role_model(0.0)
	assert(game.character_visual.scale.distance_to(base_scale * 1.24) < 0.001)
	game.first_person = false
	game._toggle_view()
	assert(game.first_person and not game.character_visual.visible)
	print("GODOT_CHARACTER_MODELS_OK counts=", counts)
	quit(0)
