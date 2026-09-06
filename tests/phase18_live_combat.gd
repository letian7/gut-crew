extends SceneTree
func _init() -> void:
	call_deferred("_run")
func _run() -> void:
	create_timer(70.0).timeout.connect(func(): printerr("LIVE_COMBAT_TIMEOUT"); quit(1))
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0, false)
	game.player.global_position = Vector3(0,0.8,0)
	var frames := 0
	var start := Time.get_ticks_msec()
	for role in range(4):
		game._set_role(role)
		game.hp = 100.0
		game.primary_attack_cd = 0.0
		game.skill_q_cd = 0.0
		game.skill_e_cd = 0.0
		game._primary_pressed()
		for i in range(90):
			await process_frame
			frames += 1
		game._primary_released()
		game._cast_skill(0)
		game._cast_skill(1)
		for i in range(150):
			await process_frame
			frames += 1
		assert(is_instance_valid(game.character_visual.get_node("Art18Model")))
		print("LIVE_ROLE_OK role=",role," frames=",frames," round_time=",game.round_time)
	assert(game.round_time > 3.0)
	RenderingServer.force_draw()
	assert(root.get_texture().get_image().save_png("res://GUT_CREW_QA_SHOTS/phase18_live_combat.png") == OK)
	print("GODOT_PHASE18_LIVE_COMBAT_OK frames=",frames," elapsed_ms=",Time.get_ticks_msec()-start," round_time=",game.round_time," hp=",game.hp)
	quit(0)
