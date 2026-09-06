extends SceneTree

func _shot(path: String) -> void:
	await create_timer(0.24).timeout
	await RenderingServer.frame_post_draw
	var image := root.get_viewport().get_texture().get_image()
	image.save_png(path)

func _pose(game, pos: Vector3, look_yaw: float, pitch := -0.13) -> void:
	game.player.global_position = pos
	game.player.velocity = Vector3.ZERO
	game.yaw = look_yaw
	game.player.rotation.y = look_yaw
	game.camera_pivot.rotation.x = pitch
	game.story_label.visible = false
	game.danger_label.visible = false
	game._update_hud()

func _init() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0, false)
	game.front_ui["root"].visible = false
	_pose(game, Vector3(14.5, 1.15, 4.5), PI)
	await _shot("res://GUT_CREW_QA_SHOTS/phase15_hairball_forest.png")
	_pose(game, Vector3(12.4, 1.15, -8.7), -PI * 0.5)
	await _shot("res://GUT_CREW_QA_SHOTS/phase15_intestinal_maze.png")
	_pose(game, Vector3(-12.2, 1.15, 8.8), PI * 0.5)
	await _shot("res://GUT_CREW_QA_SHOTS/phase15_lung_chamber.png")
	_pose(game, Vector3(0.0, 1.15, -6.2), 0.0)
	await _shot("res://GUT_CREW_QA_SHOTS/phase15_nerve_highway.png")
	print("GODOT_PHASE15_CAPTURE_OK")
	quit(0)
