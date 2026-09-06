extends SceneTree
var game
func shot(label: String) -> void:
	for i in range(12): await process_frame
	RenderingServer.force_draw()
	assert(root.get_texture().get_image().save_png("res://GUT_CREW_QA_SHOTS/"+label+".png") == OK)
	print("PHASE23_CAPTURE ",label)
func _init() -> void:
	create_timer(40).timeout.connect(func():printerr("PHASE23_CAPTURE_TIMEOUT");quit(1))
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0,false)
	game.set_process(false)
	game.set_physics_process(false)
	game.combat_hud.set_process(false)
	game.story_label.visible = false
	game.player.position = Vector3(0,0.2,-1.0)
	for enemy in game.enemies: enemy.visible = false
	game._spawn_enemy("HAIRBALL",Vector3(0,0.35,-3.8),Color.WHITE,120.0,0.0)
	game.enemies[-1].set_meta("hp",66.0)
	game.enemies[-1].set_meta("stun",2.4)
	game.combat_hud.tick(0)
	await shot("phase23_health_enemy")
	game.hp = 24
	game.acid_umbrella_time = 8.4
	game.plasma_soda_time = 4.8
	game.skill_q_cd = 3.2
	game.skill_e_cd = 6.1
	game.combat_hud.tick(0.05)
	await shot("phase23_hurt_status")
	game.hp = 0
	game.ko_time = 0.65
	game.combat_hud.tick(0.05)
	await shot("phase23_ko_status")
	print("GODOT_PHASE23_CAPTURE_OK")
	quit(0)
