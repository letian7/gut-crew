extends SceneTree
var game

func reset_enemy(enemy: CharacterBody3D, pos: Vector3) -> void:
	enemy.set_meta("dead", false)
	enemy.set_meta("hp", 260.0)
	enemy.set_meta("max_hp", 260.0)
	enemy.set_meta("stun", 0.0)
	enemy.visible = true
	enemy.global_position = pos

func _init() -> void:
	create_timer(45).timeout.connect(func(): printerr("PHASE33_TIMEOUT"); quit(1))
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await physics_frame
	game._select_role(1, false)
	game.set_process(false)
	game.set_physics_process(false)
	game.story_label.visible = false
	for enemy in game.enemies: enemy.set_meta("dead", true)
	var target: CharacterBody3D = game.enemies[0]
	game.player.global_position = Vector3(0, 1.15, 5.5)
	game.yaw = 0.0
	reset_enemy(target, Vector3(0, 1.15, -4.0))

	# Hands sit outside the central sightline.
	var left_arm := game.first_person_viewmodel.get_node("LeftClayArm") as Node3D
	var right_arm := game.first_person_viewmodel.get_node("RightClayArm") as Node3D
	assert(left_arm.position.x <= -0.52 and right_arm.position.x >= 0.52)
	assert(game.first_person_viewmodel.base_position.y <= -0.54)

	# Releasing RMB creates a travelling hook; the victim cannot teleport on release.
	game.secondary_attack_cd = 0.0
	game._secondary_pressed()
	game._tick_phase11(0.92)
	var before_release := target.global_position
	game._secondary_released()
	assert(game.kaka_hook_phase == "outgoing")
	assert(target.global_position.distance_to(before_release) < 0.01)
	assert(game.kaka_hook_projectile.find_children("PhysicalChainLink*", "MeshInstance3D", false, false).size() >= 16)
	game._tick_kaka_hook_projectile(0.16)
	assert(game.kaka_hook_flight > 0.2 and game.kaka_hook_flight < 1.0)
	for i in range(90):
		game._tick_kaka_hook_projectile(0.025)
		if game.kaka_hook_phase.is_empty(): break
	assert(game.kaka_hook_phase.is_empty())
	assert(float(target.get_meta("hooked_close", 0.0)) > 1.0)

	# A detailed wall moves across a real path and only explodes at the E endpoint.
	game.skill_q_cd = 0.0
	game._cast_skill(0)
	game._cast_skill(0)
	var wall: StaticBody3D = game.kaka_walls[0]
	assert(int(wall.get_meta("model_parts", 0)) >= 89)
	var start := wall.global_position
	game.skill_e_cd = 0.0
	game._cast_skill(1)
	game._tick_kaka_rush_contacts()
	var finish: Vector3 = wall.get_meta("push_end")
	assert(finish.distance_to(start) >= 4.4)
	assert(game.kaka_wall_detonations == 0)
	await create_timer(0.20).timeout
	assert(wall.global_position.distance_to(start) > 0.2)
	assert(wall.global_position.distance_to(finish) > 0.2)
	await create_timer(0.26).timeout
	assert(game.kaka_wall_detonations == 1)
	assert(game.get_node_or_null("BoneWallExplosion32") != null)

	print("GODOT_PHASE33_KAKA_PHYSICS_OK hands=wide hook=flight+bite+reel wall=89part_ribcage+push+endpoint_shatter")
	game.queue_free()
	await process_frame
	quit()
