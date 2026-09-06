extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	game.role_selected = true
	game.set_physics_process(false)
	game.role_panel.visible = false
	game.spring_arm.spring_length = 3.4
	game.camera_3p.fov = 62.0
	game.player.position = Vector3(0,1.15,4.2)
	var ui_nodes := [game.status_label,game.view_label,game.help_label,game.danger_label,game.target_label,game.toast_label,game.mission_label,game.interact_label,game.crosshair]
	for n in ui_nodes:
		if n: n.visible = false
	var out_dir := "C:/Users/EDY/Desktop/GUT_CREW_PHASE5_SHOTS"
	DirAccess.make_dir_recursive_absolute(out_dir)
	for role in range(4):
		game._set_role(role)
		game.anim_cast_time = 0.21
		game.anim_cast_slot = 0
		game._animate_role_model(0.0)
		game.character_visual.rotation.y = PI
		await RenderingServer.frame_post_draw
		root.get_viewport().get_texture().get_image().save_png(out_dir + "/role_%d_expression.png" % role)
	game._set_role(0)
	game.character_visual.visible = false
	game.mission_phase = "chase"
	game._spawn_mission_mouse()
	game.mouse_target.global_position = game.player.global_position + Vector3(0,0,-2.4)
	var mv := game.mouse_target.get_meta("visual") as Node3D
	mv.rotation.y = PI
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(out_dir + "/mouse_v2.png")
	print("GODOT_PHASE5_CAPTURE_OK")
	quit(0)
