extends SceneTree

func _shot(path: String) -> void:
	await create_timer(0.08).timeout
	await RenderingServer.frame_post_draw
	var image := root.get_viewport().get_texture().get_image()
	image.save_png(path)

func _reset_enemy(enemy: CharacterBody3D, pos: Vector3) -> void:
	enemy.set_meta("dead", false)
	enemy.set_meta("hp", 180.0)
	enemy.set_meta("max_hp", 180.0)
	enemy.set_meta("stun", 0.0)
	enemy.set_meta("pinned", 0.0)
	enemy.set_meta("controlled", 0.0)
	enemy.set_meta("spore_stacks", 0)
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
	_reset_enemy(e0, Vector3(0, 1.15, 1.7))
	game.skill_q_cd = 0.0
	game._cast_skill(0)
	game.skill_e_cd = 0.0
	game._cast_skill(1)
	game._update_hud()
	await _shot("res://GUT_CREW_QA_SHOTS/phase11_spark.png")
	await create_timer(0.55).timeout

	game._set_role(1)
	game.player.global_position = Vector3(0, 1.15, 5.5)
	_reset_enemy(e0, Vector3(0, 1.15, 1.8))
	game.primary_attack_cd = 0.0
	game._primary_pressed()
	game._tick_phase11(1.55)
	game._update_hud()
	await _shot("res://GUT_CREW_QA_SHOTS/phase11_kaka_charge.png")
	game._primary_released()
	await create_timer(0.45).timeout
	game._set_role(2)
	game.player.global_position = Vector3(0, 1.15, 5.5)
	game.primary_attack_cd = 0.0
	game._primary_pressed()
	game._tick_phase11(1.45)
	game._animate_role_model(0.0)
	game._update_hud()
	await _shot("res://GUT_CREW_QA_SHOTS/phase11_bubble_grow.png")
	game._primary_released()
	await create_timer(0.45).timeout
	game.secondary_attack_cd = 0.0
	game._secondary_pressed()
	game._tick_phase11(1.0)
	game._secondary_released()
	game.player.global_position = Vector3(0, 1.15, 3.0)
	game._bubble_land()
	await _shot("res://GUT_CREW_QA_SHOTS/phase11_bubble_land.png")
	await create_timer(0.55).timeout

	game._set_role(3)
	game.player.global_position = Vector3(0, 1.15, 5.5)
	_reset_enemy(e0, Vector3(-0.8, 1.15, 2.3))
	_reset_enemy(e1, Vector3(1.0, 1.15, 1.7))
	game.secondary_attack_cd = 0.0
	game._shroom_puppet_thread()
	var corpse: CharacterBody3D = game.register_clay_corpse(1, Vector3(0.7, 1.15, 3.8))
	game.secondary_attack_cd = 0.0
	game._shroom_puppet_thread()
	game._update_hud()
	await _shot("res://GUT_CREW_QA_SHOTS/phase11_shroom_puppets.png")
	print("GODOT_PHASE11_CAPTURE_OK")
	quit(0)
