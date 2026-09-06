extends SceneTree

func _init() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	assert(is_instance_valid(game.world_expansion_root))
	assert(int(game.world_expansion_root.get_meta("region_count", 0)) == 3)
	var parts := int(game.world_expansion_root.get_meta("visual_parts", 0))
	assert(parts >= 90)
	assert(game.world_expansion_root.get_node_or_null("ForeignBodyGraveyard") != null)
	assert(game.world_expansion_root.get_node_or_null("PlateletCheckpoint") != null)
	assert(game.world_expansion_root.get_node_or_null("NerveChoir") != null)
	assert(game.world_expansion_root.get_node_or_null("WestForeignBodyShelf") is StaticBody3D)
	assert(game.world_expansion_root.get_node_or_null("EastPlateletShelf") is StaticBody3D)
	assert(game.world_expansion_root.get_node_or_null("NorthNerveShelf") is StaticBody3D)

	assert(game.enemies.size() >= 10)
	var wild_count := 0
	var territories: Dictionary = {}
	var leash_enemy: CharacterBody3D
	for enemy in game.enemies:
		if bool(enemy.get_meta("wild_spawn", false)):
			wild_count += 1
			territories[String(enemy.get_meta("territory", ""))] = true
			assert(enemy.has_meta("home"))
			if leash_enemy == null:
				leash_enemy = enemy
	assert(wild_count >= 6)
	assert(territories.size() >= 3)
	assert(territories.has("FOREIGN BODY GRAVEYARD"))
	assert(territories.has("PLATELET CHECKPOINT"))
	assert(territories.has("NERVE CHOIR"))
	game._select_role(0, false)
	assert(game.story_label.visible)
	assert(game.story_label.text.find("THE LAST GOODNIGHT") >= 0)
	assert(game.clue_nodes.size() == 3)
	assert(game.clue_nodes[0].global_position.x < -15.0)
	assert(game.clue_nodes[1].global_position.z < -9.0)
	assert(game.clue_nodes[2].global_position.x > 15.0)
	assert(game.mucus_routes.size() >= 5)

	var home: Vector3 = leash_enemy.get_meta("home")
	leash_enemy.global_position = home + Vector3(3.0, 1.0, 0.0)
	leash_enemy.velocity = Vector3.ZERO
	game.player.global_position = Vector3(0.0, 1.15, 0.0)
	game._tick_enemies(0.1)
	var home_direction := home - leash_enemy.global_position
	home_direction.y = 0.0
	assert(leash_enemy.velocity.dot(home_direction) > 0.0)

	game._complete_clue(0)
	assert(game.story_label.text.find("NO CHEW MARKS") >= 0)
	game._complete_clue(1)
	assert(game.story_label.text.find("CHILD'S RECORDING") >= 0)
	game._complete_clue(2)
	assert(game.mission_phase == "chase")
	assert(game.story_chapter == 4)
	assert(game.story_label.text.find("NEVER ATTACKING MOCHI") >= 0)
	assert(is_instance_valid(game.mouse_target))
	assert(game.mouse_target.global_position.x > 15.0)
	game._catch_mouse()
	assert(game.mission_phase == "return")
	assert(game.story_chapter == 5)
	assert(game.danger_label.text.find("MEMORY SECURED") >= 0)
	preload("res://tests/host_boss_test_helper.gd").finish(game)
	assert(game.mission_phase == "win")
	assert(game.win_label.text.find("little girl's hand") >= 0)
	assert(game.win_label.text.find("hidden a promise") >= 0)
	print("GODOT_PHASE13_WORLD_STORY_OK regions=3 parts=", parts, " enemies=", game.enemies.size(), " wild=", wild_count)
	quit(0)
