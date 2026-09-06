extends SceneTree
const Boss = preload("res://scripts/host_boss.gd")

func _init() -> void:
	create_timer(25.0).timeout.connect(func(): printerr("PHASE16_TIMEOUT"); quit(1))
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0, false)
	game.set_process(false)
	game.set_physics_process(false)
	game.mission_phase = "return"
	var credits_before: int = game.credits
	game._win_round()
	assert(game.mission_phase == "return" and game.credits == credits_before)
	game._spawn_fungus_patch()
	game._begin_host_boss()
	var boss = game.host_boss
	assert(game.mission_phase == "host_boss")
	assert(boss.cat.get_meta("host_species") == "cat")
	assert(boss.cat.get_meta("rescue_target"))
	assert(game.player.position.y > 40.0)
	assert(game.fungus_patches.is_empty())
	game._begin_host_boss()
	assert(game.host_boss == boss)
	var timer_before: float = boss.state_time
	game.game_paused = true
	boss.tick(1.0)
	assert(boss.state_time == timer_before)
	game.game_paused = false

	# Each telegraph has a hit case and an avoid case.
	for kind in range(2):
		game.player.global_position = boss.respawn_point()
		game.hp = 100.0
		game.invuln = 0.0
		boss.attack_index = kind
		boss._begin_attack()
		assert(boss.marker != null and boss.state == "windup")
		boss._resolve_attack()
		assert(game.hp == (80.0 if kind == 0 else 75.0))
		assert(boss.state == "recover")
		game.hp = 100.0
		game.invuln = 0.0
		boss.attack_index = kind
		boss._begin_attack()
		game.player.position.x += 4.0
		boss._resolve_attack()
		assert(game.hp == 100.0)
	game.player.global_position = boss.respawn_point()
	game.invuln = 0.5
	boss.attack_index = 0
	boss._begin_attack()
	boss._resolve_attack()
	assert(game.hp == 100.0)
	game.invuln = 0.0
	boss.attack_index = 2
	boss._begin_attack()
	boss._resolve_attack()
	assert(boss.state == "wave")
	game.player.position = Boss.ORIGIN + Vector3(0,0.75,0.3)
	boss.tick(0.1)
	assert(game.hp == 86.0)
	game.hp = 100.0
	game.invuln = 0.0
	game.player.position = Boss.ORIGIN + Vector3(0,2.0,1.6)
	boss.tick(0.1)
	assert(game.hp == 100.0)

	boss.state = "wait"
	boss.panic = Boss.MAX_PANIC
	boss.apply_hit(10.0,0.0,0)
	assert(is_equal_approx(boss.panic,317.0))
	boss.state = "recover"
	boss.apply_hit(10.0,0.0,0)
	assert(is_equal_approx(boss.panic,307.0))
	boss.attack_index = 0
	boss._begin_attack()
	timer_before = boss.state_time
	boss.apply_hit(1.0,0.9,0)
	assert(is_equal_approx(boss.state_time,timer_before+0.45))
	boss.apply_hit(1.0,0.9,0)
	assert(is_equal_approx(boss.state_time,timer_before+0.45))
	boss.panic = 150.0
	boss._begin_attack()
	assert(is_equal_approx(boss.state_time,0.95))

	# Use real role abilities through the existing enemy-damage adapter.
	boss.retry()
	boss.state = "recover"
	game.player.position = Boss.ORIGIN + Vector3(0,0.75,2.0)
	game.yaw = 0.0
	game._set_role(0)
	var before_hit: float = boss.panic
	game.primary_attack_cd = 0.0
	game._primary_attack()
	assert(boss.panic < before_hit)
	game._skill_spark(0)
	game._skill_spark(0)
	assert(game.player.position.y > 39.0)
	game.player.position = Boss.ORIGIN + Vector3(0,0.75,2.0)
	game._set_role(1)
	game.primary_attack_cd = 0.0
	before_hit = boss.panic
	game._primary_attack()
	for step in range(8):
		game._tick_bone_projectiles(0.03)
	assert(boss.panic < before_hit)
	assert(int(boss.target.get_meta("bone_pins",0)) > 0)
	before_hit = boss.panic
	game._kaka_bone_hook()
	assert(boss.panic < before_hit)
	assert(boss.target.position.distance_to(Boss.ORIGIN+Vector3(0,0.35,-1.5)) < 0.01)
	game.player.position = Boss.ORIGIN + Vector3(0,0.75,2.0)
	game._set_role(2)
	before_hit = boss.panic
	game._bubble_regurgitate()
	assert(boss.panic < before_hit)
	assert(not is_instance_valid(game.bubble_payload))
	assert(not boss.target.get_meta("engulfed",false))
	game._set_role(3)
	before_hit = boss.panic
	game._shroom_puppet_thread()
	assert(boss.panic < before_hit)
	assert(float(boss.target.get_meta("controlled",0.0)) == 0.0)
	game._spawn_fungus_patch()
	game.player.position = game.fungus_patches[-1].position
	game.hp = 70.0
	game._process(0.1)
	assert(game.hp > 70.0)
	game.hp = 0.0
	game._tick_enemies(0.01)
	assert(game.ko_time > 0.0)
	game._physics_process(10.0)
	assert(game.hp == 100.0 and boss.panic == Boss.MAX_PANIC)
	assert(game.player.position.distance_to(boss.respawn_point()) < 0.01)

	boss.state = "recover"
	game._damage_enemy(boss.target,10000.0)
	assert(game.mission_phase == "ending" and not game.win_panel.visible)
	assert(is_instance_valid(boss.cat) and boss.cat.visible)
	assert(boss.target.collision_layer == 0)
	assert(game.credits == credits_before)
	boss.advance_story()
	assert(boss.story_index == 0)
	game._open_pause()
	boss.story_elapsed = 1.1
	boss.advance_story()
	assert(boss.story_index == 0)
	game._resume_game()
	assert(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE)
	for page in range(4):
		assert(boss.story_index == page and boss.story_panel.visible)
		boss.story_elapsed = 1.1
		boss.advance_story()
	assert(game.mission_phase == "win" and boss.rescued)
	assert(game.credits == credits_before+20)
	game._win_round()
	assert(game.credits == credits_before+20)
	print("GODOT_PHASE16_HOST_BOSS_OK attacks=3 story_pages=4 rescue=true")
	quit(0)
