extends SceneTree

func _shot(path: String) -> void:
	await create_timer(0.10).timeout
	await RenderingServer.frame_post_draw
	var image := root.get_viewport().get_texture().get_image()
	image.save_png(path)

func _reset_enemy(enemy: CharacterBody3D, pos: Vector3) -> void:
	enemy.set_meta("dead", false)
	enemy.set_meta("hp", 180.0)
	enemy.set_meta("max_hp", 180.0)
	enemy.set_meta("stun", 0.0)
	enemy.set_meta("pinned", 0.0)
	enemy.set_meta("goo_slow", 0.0)
	enemy.set_meta("controlled", 0.0)
	enemy.set_meta("control_attack_cd", 0.0)
	enemy.set_meta("bone_pins", 0)
	enemy.set_meta("big", 0.0)
	enemy.set_meta("combo_t", 0.0)
	enemy.set_meta("combo_role", -1)
	enemy.set_meta("combo_count", 0)
	enemy.set_meta("engulfed", false)
	enemy.visible = true
	enemy.collision_layer = 1
	enemy.collision_mask = 1
	enemy.global_position = pos
func _init() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.role_selected = true
	game.role_panel.visible = false
	game.front_ui["root"].visible = false
	game.player.global_position = Vector3(0, 1.15, 5.5)
	game.yaw = 0.0
	game.player.rotation.y = 0.0
	for enemy in game.enemies:
		enemy.set_meta("dead", true)
	var e0: CharacterBody3D = game.enemies[0]
	var e1: CharacterBody3D = game.enemies[1]

	game._set_role(0)
	_reset_enemy(e0, Vector3(0, 1.15, 2.3))
	_reset_enemy(e1, Vector3(1.5, 1.15, 2.4))
	game.skill_q_cd = 0.0
	game._cast_skill(0)
	game.primary_attack_cd = 0.0
	game._spark_arc_shot()
	game._update_hud()
	await _shot("res://GUT_CREW_QA_SHOTS/phase12_spark_chain.png")
	game._clear_spark_mark()
	await create_timer(0.55).timeout
	game._set_role(1)
	game.player.global_position = Vector3(0, 1.15, 5.5)
	_reset_enemy(e0, Vector3(0, 1.15, 4.35))
	e0.set_meta("bone_pins", 3)
	for i in range(3):
		var nail := Node3D.new()
		nail.set_meta("stuck", true)
		nail.set_meta("stuck_enemy", e0)
		game.add_child(nail)
		game.bone_projectiles.append(nail)
	game._start_kaka_charge()
	game._tick_kaka_rush_contacts()
	game._update_hud()
	await _shot("res://GUT_CREW_QA_SHOTS/phase12_kaka_shatter.png")
	await create_timer(0.55).timeout

	game._set_role(2)
	game.player.global_position = Vector3(0, 1.15, 5.5)
	_reset_enemy(e0, Vector3(0, 1.15, 2.9))
	_reset_enemy(e1, Vector3(1.1, 1.15, 3.0))
	game._spawn_bubble_decoy()
	game.bubble_roll_power = 1.0
	game.bubble_roll_time = 1.0
	game._tick_bubble_roll_contacts()
	game.bubble_roll_time = 0.0
	game.player.velocity = Vector3.ZERO
	var decoy_body := game.bubble_decoy as RigidBody3D
	decoy_body.global_position = e0.global_position
	decoy_body.linear_velocity = Vector3(0, 0, -8.0)
	game._tick_bubble_decoy_impact()
	game._update_hud()
	await _shot("res://GUT_CREW_QA_SHOTS/phase12_bubble_pinball.png")
	await create_timer(0.55).timeout

	game._set_role(3)
	game.player.global_position = Vector3(0, 1.15, 5.5)
	_reset_enemy(e0, Vector3(0, 1.15, 3.0))
	_reset_enemy(e1, Vector3(0.8, 1.15, 3.0))
	e0.set_meta("controlled", 6.0)
	e0.set_meta("big", 4.0)
	e0.set_meta("control_attack_cd", 0.0)
	game._tick_enemies(0.05)
	game._update_hud()
	await _shot("res://GUT_CREW_QA_SHOTS/phase12_shroom_overdrive.png")
	print("GODOT_PHASE12_CAPTURE_OK")
	quit(0)
