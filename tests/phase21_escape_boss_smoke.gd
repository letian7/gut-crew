extends SceneTree
const Boss = preload("res://scripts/host_boss.gd")

func _init() -> void:
	create_timer(35.0).timeout.connect(func(): printerr("PHASE21_TIMEOUT");quit(1))
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0)
	game.set_process(false)
	game.set_physics_process(false)
	var mouth_position: Vector3 = game.player.position
	for role in [1,2,3,0]:
		game._select_role(role)
		assert(game.player.position == mouth_position and game.mission_phase == "mouth")
	game._bubble_sling_instant(0.55)
	assert(game.player.position.z > 50 and game.player.position.y > 15)
	game.mouth_intro.finish()
	for i in range(3):
		game.player.global_position = game.clue_nodes[i].global_position
		game.interact_down = true
		game._update_mission(0.5)
		game.interact_down = false
		game._update_mission(0.01)
	assert(game._clue_count() == 3 and game.mission_phase == "chase")
	game.player.global_position = game.mouse_target.global_position+Vector3(0,0,1.4)
	game.yaw = 0.0
	game._skill_spark(0)
	game.interact_down = true
	game._update_mission(0.8)
	game.interact_down = false
	game._update_mission(0.01)
	assert(game.mouse_caught and game.mission_phase == "return")
	game.player.global_position = game.entrance.global_position
	game.interact_down = true
	game._update_mission(0.6)
	assert(game.mission_phase == "escape" and not is_instance_valid(game.host_boss))
	var escape = game.escape_finale
	assert(escape.get_meta("exit_route") == "terminal_gut_to_litter_tray")
	game.game_paused = true
	escape.tick(1.0)
	assert(escape.elapsed == 0.0)
	game.game_paused = false
	var before: Vector3 = game.player.position
	game._physics_process(0.2)
	assert(game.player.position == before)
	game.skill_q_cd = 0.0
	game._cast_skill(0)
	assert(game.skill_q_cd == 0.0)
	for step in range(86): escape.tick(0.1)
	assert(escape.completed and game.get_meta("exited_via_rear"))
	assert(game.mission_phase == "host_boss" and game.host_boss.provoked)
	var boss = game.host_boss
	assert(boss.state == "toy_intro")
	game._physics_process(0.2)
	assert(game.player.velocity == Vector3.ZERO)
	boss.tick(3.3)
	assert(boss.state == "wait")
	print("PHASE21_MOUTH_DIAGNOSE_CAPTURE_REAR_EXIT_TOY_PROVOCATION_OK")
	# Tail: stationary hit, jump avoidance, and stepping out of the locked strip.
	for avoid in range(3):
		game.player.position = boss.respawn_point()
		game.hp = 100
		game.invuln = 0.0
		boss.attack_index = 3
		boss._begin_attack()
		assert(boss.marker.name == "TailWarning")
		if avoid == 1: game.player.position.y += 2.0
		if avoid == 2: game.player.position.z -= 4.0
		boss._resolve_attack()
		assert(game.hp == (82.0 if avoid == 0 else 100.0))
	# Charge: the warning locks its lane; moving sideways really avoids damage.
	for avoid in range(3):
		game.player.position = boss.respawn_point()
		game.hp = 100
		game.invuln = 0.0
		boss.attack_index = 4
		boss._begin_attack()
		assert(boss.marker.name == "ToyChargeWarning")
		var locked: Vector3 = boss.charge_end
		if avoid == 1: game.player.position.x += 6.0
		if avoid == 2: game.invuln = 0.5
		boss._resolve_attack()
		assert(boss.charge_end == locked)
		assert(game.hp == (72.0 if avoid == 0 else 100.0))
	# The toy is an actual interactable lure, with cooldown and extra recovery.
	boss.state = "recover"
	game.player.position = boss.toy.position+Vector3.UP*0.5
	assert(boss.squeak_toy())
	assert(not boss.squeak_toy() and boss.toy_cooldown == 10.0)
	game.player.position = Boss.ORIGIN+Vector3(8,0.75,7)
	boss._begin_attack()
	assert(boss.attack_kind == 4 and boss.attack_lured and boss.toy_lure_time == 0.0)
	assert(absf(boss.attack_pos.x-boss.toy.position.x)<0.01)
	boss._resolve_attack()
	assert(boss.state_time > 4.0)
	boss.retry()
	assert(boss.toy_cooldown == 0.0 and boss.state == "wait")
	preload("res://tests/host_boss_test_helper.gd").finish(game)
	assert(game.mission_phase == "win" and boss.rescued)
	print("GODOT_PHASE21_ESCAPE_BOSS_OK route=rear attacks=5 lure=interactive story=4 phase=win")
	quit(0)
