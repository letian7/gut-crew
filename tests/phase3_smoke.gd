extends SceneTree

func _init() -> void:
	var packed = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0, false)
	assert(game.mission_phase == "diagnose")
	for i in range(3):
		game.player.global_position = game.clue_nodes[i].global_position
		game.interact_down = true
		game._update_mission(0.5)
		game.interact_down = false
		game._update_mission(0.01)
	assert(game._clue_count() == 3)
	assert(game.mission_phase == "chase")
	assert(is_instance_valid(game.mouse_target))
	game.player.global_position = game.mouse_target.global_position + Vector3(0, 0, 1.4)
	game.yaw = 0.0
	game._skill_spark(0)
	assert(float(game.mouse_target.get_meta("stun")) > 0.0)
	game.interact_down = true
	game._update_mission(0.8)
	game.interact_down = false
	game._update_mission(0.01)
	assert(game.mission_phase == "return")
	assert(game.mouse_caught)
	game.player.global_position = game.entrance.global_position
	game.interact_down = true
	game._update_mission(0.6)
	game.interact_down = false
	game._update_mission(0.01)
	assert(game.mission_phase == "escape")
	for step in range(86): game.escape_finale.tick(0.1)
	assert(game.mission_phase == "host_boss" and game.host_boss.provoked)
	game.host_boss.tick(3.3)
	preload("res://tests/host_boss_test_helper.gd").finish(game)
	assert(game.mission_phase == "win")
	assert(game.win_panel.visible)
	print("GODOT_PHASE3_FULL_ROUND_OK clues=", game._clue_count(), " phase=", game.mission_phase)
	quit(0)
