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
	game._set_role(1)
	enemy.global_position = game.player.global_position + game._forward() * 1.0
	game._skill_kaka(1)
	game._tick_kaka_rush_contacts()
	var hp2 = float(enemy.get_meta("hp"))
	assert(hp1 < hp0)
	assert(hp2 < hp1 - 20.0)
	assert(game.synergies >= 1)
	assert(game.combo_best >= 2)

	game.acid_tide_time = 5.0
	game.acid_next = 0.2
	game._use_acid_valve()
	assert(game.acid_tide_time == 0.0)
	assert(game.acid_next >= 13.0)
	assert(game.valve_cooldown > 0.0)

	game.hp = 100.0
	game.player.position = Vector3(0, 1.1, 4.8)
	game.acid_tide_time = 5.0
	game._update_living_events(0.1)
	assert(game.hp == 100.0)
	game.player.position.y = 0.2
	game._update_living_events(0.1)
	assert(game.hp < 100.0)

	game._spawn_swallowed_prop()
	assert(game.swallowed_props.size() == 1)
	assert(is_instance_valid(game.acid_valve))

	var sync0 = game.synergies
	game._set_role(3)
	game._spawn_fungus_patch()
	game._set_role(1)
	game._spawn_bone_bridge()
	assert(game.synergies > sync0)
	assert(game.bone_structures.size() >= 1)
	var sync1 = game.synergies
	game._set_role(2)
	game._spawn_surf_lane()
	assert(game.synergies > sync1)
	var sync2 = game.synergies
	game._set_role(3)
	game._spawn_fungus_patch()
	assert(game.synergies > sync2)
	var sync3 = game.synergies
	game._set_role(0)
	game._skill_spark(1)
	assert(game.synergies > sync3)
	print("GODOT_PHASE4_SMOKE_OK combo=", game.combo_best, " sync=", game.synergies, " hp=", hp0, "->", hp2)
	quit(0)
