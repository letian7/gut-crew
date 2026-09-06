extends SceneTree

func _shot(path: String) -> void:
	await create_timer(0.25).timeout
	await RenderingServer.frame_post_draw
	var shot := root.get_viewport().get_texture().get_image()
	assert(shot.save_png(path) == OK)

func _init() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0, false)
	game.mission_phase = "return"
	game._begin_host_boss()
	game.set_process(false)
	game.set_physics_process(false)
	var boss = game.host_boss
	game.terrain_world.tick(2.0)
	boss.tick(0.01)
	await _shot("res://GUT_CREW_QA_SHOTS/phase16_mochi_boss.png")
	boss.attack_index = 0
	boss._begin_attack()
	boss.tick(0.01)
	await _shot("res://GUT_CREW_QA_SHOTS/phase16_paw_warning.png")
	boss.state = "recover"
	game._damage_enemy(boss.target,10000.0)
	await _shot("res://GUT_CREW_QA_SHOTS/phase16_story_opening.png")
	for page in range(3):
		boss.story_elapsed = 1.1
		boss.advance_story()
	await _shot("res://GUT_CREW_QA_SHOTS/phase16_story_reunion.png")
	print("GODOT_PHASE16_CAPTURE_OK")
	quit(0)
