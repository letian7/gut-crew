extends SceneTree

func _shot(path: String) -> void:
	await create_timer(0.22).timeout
	await RenderingServer.frame_post_draw
	var image := root.get_viewport().get_texture().get_image()
	image.save_png(path)

func _pose(game, pos: Vector3, look_yaw: float, pitch: float = -0.12) -> void:
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
	_pose(game, Vector3(0.0, 1.15, 2.0), PI, -0.10)
	await _shot("res://GUT_CREW_QA_SHOTS/phase14_corpus.png")
	_pose(game, Vector3(-7.0, 1.15, 1.0), -PI * 0.5, -0.14)
	await _shot("res://GUT_CREW_QA_SHOTS/phase14_fundus.png")
	_pose(game, Vector3(7.2, 1.15, 0.0), PI * 0.5, -0.12)
	await _shot("res://GUT_CREW_QA_SHOTS/phase14_pylorus.png")

	game.spring_arm.spring_length = 3.35
	var names: Array[String] = ["spark", "kaka", "bubble", "shroom"]
	for role in range(4):
		game._set_role(role)
		_pose(game, Vector3(0.0, 1.15, 3.4), 0.0, -0.06)
		game.character_visual.rotation.y = PI
		game.character_visual.scale *= 1.10
		await _shot("res://GUT_CREW_QA_SHOTS/phase14_" + names[role] + "_front.png")
	print("GODOT_PHASE14_CAPTURE_OK")
	quit(0)
