extends SceneTree
const SkillVFX = preload("res://scripts/skill_vfx.gd")
const EnemyFactory = preload("res://scripts/enemy_factory.gd")

func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	game.role_selected = true
	game.role_panel.visible = false
	var enemy: CharacterBody3D = game.enemies[0]
	enemy.set_meta("speed", 0.0)
	enemy.global_position = game.player.global_position + Vector3(0,0,-1.0)
	game.invuln = 0.0
	var hp0: float = game.hp
	game._tick_enemies(0.01)
	assert(float(enemy.get_meta("attack_windup")) > 0.0)
	var attack_label := enemy.get_meta("hp_label") as Label3D
	assert(attack_label.text.contains("WINDUP!"))
	assert(is_equal_approx(game.hp, hp0))
	enemy.set_meta("attack_windup", 0.01)
	game._tick_enemies(0.02)
	assert(game.hp < hp0)
	assert(game.get_node_or_null("EnemyAttackHit") != null)
	game.mission_phase = "chase"
	game._spawn_mission_mouse()
	var mouse: CharacterBody3D = game.mouse_target
	mouse.global_position = game.player.global_position + Vector3(0,0,-3.2)
	mouse.set_meta("burst_cd", 0.0)
	game.living_time = 1.0
	game._tick_mission_mouse(mouse, 0.02)
	assert(float(mouse.get_meta("burst_time")) > 0.0 or float(mouse.get_meta("fake_stop")) > 0.0)
	SkillVFX.spawn_landing(game,Vector3.ZERO,Color("#ffd83f"))
	assert(game.get_node_or_null("LandingClayRing") != null)
	var pairs := [[0,1],[0,2],[0,3],[1,2],[1,3],[2,3]]
	for p in pairs:
		SkillVFX.spawn_sync_pair(game,Vector3.ZERO,3,p[0],p[1],game.ROLE_COLORS[p[0]],game.ROLE_COLORS[p[1]])
	await process_frame
	assert(game.get_node_or_null("SyncBoneLightning") != null)
	assert(game.get_node_or_null("SyncPlasmaSpark") != null)
	assert(game.get_node_or_null("SyncElectricSpore") != null)
	assert(game.get_node_or_null("SyncBonePlasmaRail") != null)
	assert(game.get_node_or_null("SyncFungusBone") != null)
	assert(game.get_node_or_null("SyncPlasmaFungusDome") != null)
	game.hp = 0.0
	game._tick_enemies(0.0)
	assert(game.ko_time > 0.0)
	assert(game.get_node_or_null("KOPuddle") != null)
	game._physics_process(0.9)
	assert(game.ko_time <= 0.0 and game.hp == 100.0)
	assert(game.anim_reassemble_time > 0.0)
	print("GODOT_PHASE6_OK attack_hp=",hp0," rebuilt=",game.hp," mouse_burst=",mouse.get_meta("burst_time")," fake=",mouse.get_meta("fake_stop"))
	quit(0)
