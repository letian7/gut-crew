extends SceneTree

func _shot(path: String) -> void:
	await create_timer(0.12).timeout
	await RenderingServer.frame_post_draw
	var image := root.get_viewport().get_texture().get_image()
	image.save_png(path)

func _init() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await _shot("res://GUT_CREW_QA_SHOTS/phase10_main_menu.png")
	game._menu_show_levels()
	await _shot("res://GUT_CREW_QA_SHOTS/phase10_level_select.png")
	game._show_front("main")
	game._open_settings(false)
	await _shot("res://GUT_CREW_QA_SHOTS/phase10_settings.png")
	game._begin_selected_level("cat_stomach")
	game._select_role(0, false)
	game._open_pause()
	await _shot("res://GUT_CREW_QA_SHOTS/phase10_pause.png")
	print("GODOT_PHASE10_CAPTURE_OK")
	quit(0)
