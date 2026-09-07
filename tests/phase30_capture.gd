extends SceneTree
var game

func shot(label: String) -> void:
	for i in range(12): await process_frame
	RenderingServer.force_draw()
	var path := "res://GUT_CREW_QA_SHOTS/" + label + ".png"
	assert(root.get_texture().get_image().save_png(path) == OK)

func _init() -> void:
	create_timer(50).timeout.connect(func(): printerr("PHASE30_CAPTURE_TIMEOUT"); quit(1))
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await physics_frame
	game._select_role(0, false)
	game.set_process(false)
	game.set_physics_process(false)
	game.story_label.visible = false
	game.toast_label.visible = false
	game.mouth_intro.active = false
	game.player.global_position = game.world_point(Vector3(-12.0, 1.2, 7.0))
	game.yaw = -0.55
	game.pitch = -0.13
	game.player.rotation.y = game.yaw
	game.camera_pivot.rotation.x = game.pitch
	game.first_person_viewmodel.refresh_visibility()
	await shot("phase30_first_person_spark")
	game._set_role(2)
	game.first_person_viewmodel.refresh_visibility()
	await shot("phase30_first_person_bubble")
	game.credits = 96
	game.acid_umbrella_time = 14.0
	game.plasma_soda_time = 9.0
	game.clinic_system.bag.append({"name":"胃酸珍珠", "value":45})
	game.inventory_ui.open_inventory()
	game.inventory_ui.refresh()
	await shot("phase30_inventory")
	game.inventory_ui.close_inventory()
	game.hp = 28.0
	game._player_hurt_feedback(22.0, game.player.global_position + Vector3.RIGHT * 3.0, true)
	game.impact_feedback.tick(0.01)
	await shot("phase30_damage_feedback")
	print("GODOT_PHASE30_CAPTURE_OK shots=4")
	game.queue_free()
	await process_frame
	quit()
