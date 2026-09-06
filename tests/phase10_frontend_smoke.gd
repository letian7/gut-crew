extends SceneTree

func _init() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	assert(not game.role_selected)
	assert(not game.role_panel.visible)
	assert(game.front_ui["root"].visible)
	assert(game.front_ui["main"].visible)
	assert(game.current_front_screen == "main")

	game._menu_show_levels()
	assert(game.front_ui["levels"].visible)
	assert(not game.front_ui["main"].visible)
	game._begin_selected_level("cat_stomach")
	assert(game.selected_level_id == "cat_stomach")
	assert(game.role_panel.visible)
	assert(not game.front_ui["root"].visible)
	game._select_role(2, false)
	assert(game.role_selected)
	assert(not game.role_panel.visible)
	var escape := InputEventKey.new()
	escape.physical_keycode = KEY_ESCAPE
	escape.pressed = true
	game._unhandled_input(escape)
	assert(game.game_paused)
	assert(game.current_front_screen == "pause")
	assert(game.front_ui["pause"].visible)
	assert(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE)

	game._open_settings(true)
	assert(game.current_front_screen == "settings")
	game._on_volume_changed(35.0)
	game._on_sensitivity_changed(135.0)
	game._on_fov_changed(76.0)
	assert(game.front_ui["volume_value"].text == "35%")
	assert(is_equal_approx(game.mouse_sensitivity, 1.35))
	assert(is_equal_approx(game.camera_3p.fov, 76.0))
	assert(game.front_ui["fov_value"].text == "76°")
	game._settings_back()
	assert(game.current_front_screen == "pause")
	game._resume_game()
	assert(not game.game_paused)
	assert(not game.front_ui["root"].visible)
	assert(game.help_label.text.find("Esc menu") >= 0)

	game._open_pause()
	var frozen_position: Vector3 = game.player.global_position
	game._physics_process(0.16)
	assert(game.player.global_position == frozen_position)
	game._resume_game()
	print("GODOT_PHASE10_FRONTEND_OK screen=", game.current_front_screen, " sensitivity=", game.mouse_sensitivity, " fov=", game.camera_3p.fov)
	quit(0)
