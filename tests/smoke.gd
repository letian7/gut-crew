extends SceneTree

func _init() -> void:
	var packed = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0, false)
	var enemy = game.enemies[0]
	game.player.position = enemy.position + Vector3(0, 0, 3)
	game.yaw = 0.0
	var hp0 = float(enemy.get_meta("hp"))
	game._skill_spark(0)
	var hp1 = float(enemy.get_meta("hp"))
	assert(hp1 < hp0)
	game._set_role(1)
	enemy.global_position = game.player.global_position + game._forward() * 1.0
	game._skill_kaka(1)
	game._tick_kaka_rush_contacts()
	assert(game.kaka_rush_time > 0.0)
	assert(float(enemy.get_meta("hp")) < hp1)
	game._set_role(2)
	game._skill_bubble(0)
	assert(is_instance_valid(game.bubble_decoy))
	game._skill_bubble(1)
	assert(is_instance_valid(game.bubble_payload))
	game._set_role(3)
	game._skill_shroom(0)
	assert(game.fungus_patches.size() == 1)
	game.acid_next = 0.1
	game._update_living_events(0.2)
	assert(game.acid_tide_time > 0.0)
	print("GODOT_PHASE2_SMOKE_OK hp=", hp0, "->", hp1)
	quit(0)
