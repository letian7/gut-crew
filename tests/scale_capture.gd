extends SceneTree

func shot(path: String) -> void:
	await create_timer(0.10).timeout
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(path)

func _init() -> void:
	var out := "C:/Users/EDY/Desktop/新建文件夹/GUT_CREW_GODOT/GUT_CREW_QA_SHOTS"
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.role_selected = true
	game.role_panel.visible = false
	game.player.position = Vector3(0,1.15,4.2)
	game._set_role(0)
	await shot(out + "/scale_v1_spark.png")
	game._set_role(3)
	await shot(out + "/scale_v1_shroom.png")
	print("GODOT_SCALE_CAPTURE_OK")
	quit(0)
