extends SceneTree
func _init() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.role_selected = true
	game.role_panel.visible = false
	game._set_role(0)
	game.player.position = Vector3(-4.5,1.15,0.4)
	game.yaw = 0.0
	game.player.rotation.y = 0.0
	game.camera_pivot.rotation.x = -0.12
	game.credits = 88
	game._update_hud()
	await create_timer(0.15).timeout
	await RenderingServer.frame_post_draw
	var img := root.get_viewport().get_texture().get_image()
	img.save_png("res://GUT_CREW_QA_SHOTS/phase8_shop.png")
	game._buy_item(0)
	game._tick_fun_items(0.0)
	await create_timer(0.12).timeout
	await RenderingServer.frame_post_draw
	img = root.get_viewport().get_texture().get_image()
	img.save_png("res://GUT_CREW_QA_SHOTS/phase8_umbrella.png")
	print("GODOT_PHASE8_CAPTURE_OK")
	quit(0)
