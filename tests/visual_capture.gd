extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	game.role_selected = true
	game.set_physics_process(false)
	game.role_panel.visible = false
	game.acid_next = 999.0
	game.spasm_next = 999.0
	game.drink_next = 999.0
	game.player.position = Vector3(0,1.15,4.2)
	game.spring_arm.spring_length = 5.2
	game.camera_3p.fov = 70.0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var ui_nodes := [game.status_label,game.view_label,game.help_label,game.danger_label,game.target_label,game.toast_label,game.mission_label,game.interact_label,game.crosshair]
	for n in ui_nodes:
		if n: n.visible = false
	var out_dir := "C:/Users/EDY/Desktop/GUT_CREW_QA_SHOTS"
	DirAccess.make_dir_recursive_absolute(out_dir)
	for role in range(4):
		game._set_role(role)
		await process_frame
		for slot in range(2):
			game._spawn_skill_visual(slot)
			await create_timer(0.12).timeout
			await RenderingServer.frame_post_draw
			var img := root.get_viewport().get_texture().get_image()
			img.save_png(out_dir + "/role_%d_skill_%d.png" % [role,slot])
			await create_timer(0.55).timeout
	print("GODOT_VISUAL_CAPTURE_OK")
	quit(0)
