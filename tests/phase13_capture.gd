extends SceneTree

func _shot(path: String) -> void:
	await create_timer(0.18).timeout
	await RenderingServer.frame_post_draw
	var image := root.get_viewport().get_texture().get_image()
	image.save_png(path)

func _pose(game, pos: Vector3, look_yaw: float) -> void:
	game.player.global_position = pos
	game.player.velocity = Vector3.ZERO
	game.yaw = look_yaw
	game.player.rotation.y = look_yaw
	game.camera_pivot.rotation.x = -0.16
	game.story_label.visible = false
	game._update_hud()

func _init() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0, false)
	game.front_ui["root"].visible = false
	_pose(game, Vector3(-14.2, 1.15, -0.5), -PI * 0.5)
	await _shot("res://GUT_CREW_QA_SHOTS/phase13_graveyard.png")
	_pose(game, Vector3(14.0, 1.15, -0.2), PI * 0.5)
	await _shot("res://GUT_CREW_QA_SHOTS/phase13_checkpoint.png")
	_pose(game, Vector3(0.0, 1.15, -7.5), 0.0)
	await _shot("res://GUT_CREW_QA_SHOTS/phase13_nerve_choir.png")
	game._show_front("main")
	await _shot("res://GUT_CREW_QA_SHOTS/phase13_story_frontend.png")
	game.front_ui["root"].visible = false
	for i in range(3):
		game._complete_clue(i)
	game._catch_mouse()
	preload("res://tests/host_boss_test_helper.gd").finish(game)
	await _shot("res://GUT_CREW_QA_SHOTS/phase13_last_goodnight_ending.png")
	print("GODOT_PHASE13_CAPTURE_OK")
	quit(0)
