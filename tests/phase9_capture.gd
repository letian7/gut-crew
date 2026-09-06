extends SceneTree

func _shot(path: String) -> void:
	await create_timer(0.06).timeout
	await RenderingServer.frame_post_draw
	var image := root.get_viewport().get_texture().get_image()
	image.save_png(path)

func _init() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.role_selected = true
	game.role_panel.visible = false
	game.yaw = 0.0
	game.player.rotation.y = 0.0
	game.player.global_position = Vector3(0, 1.15, 5.5)
	var enemy: CharacterBody3D = game.enemies[0]
	enemy.set_meta("dead", false)
	enemy.set_meta("hp", 100.0)
	enemy.global_position = Vector3(0, 1.15, 2.0)
	game._set_role(0)
	game.secondary_attack_cd = 0.0
	game._secondary_attack()
	await _shot("res://GUT_CREW_QA_SHOTS/phase9_blink.png")
	for other in game.enemies:
		other.set_meta("dead", true)
	var puppet: CharacterBody3D = game.enemies[0]
	var victim: CharacterBody3D = game.enemies[1]
	for actor in [puppet, victim]:
		actor.set_meta("dead", false)
		actor.set_meta("hp", 100.0)
		actor.set_meta("controlled", 0.0)
	puppet.global_position = Vector3(0, 1.15, 0.0)
	victim.global_position = Vector3(0, 1.15, -1.1)
	game.player.global_position = Vector3(0, 1.15, 2.8)
	game._set_role(3)
	game.secondary_attack_cd = 0.0
	game._secondary_attack()
	game._tick_enemies(0.1)
	game._update_hud()
	await _shot("res://GUT_CREW_QA_SHOTS/phase9_puppet.png")
	print("GODOT_PHASE9_CAPTURE_OK")
	quit(0)
