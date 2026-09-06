extends SceneTree
var game
var clinic
func shot(label: String) -> void:
	game.combat_hud.tick(0)
	game.tactical_map.refresh = 0
	game.tactical_map.tick(0)
	for i in range(12): await process_frame
	RenderingServer.force_draw()
	assert(root.get_texture().get_image().save_png("res://GUT_CREW_QA_SHOTS/"+label+".png")==OK)
func _init() -> void:
	create_timer(60).timeout.connect(func():printerr("PHASE27_CAPTURE_TIMEOUT");quit(1))
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(2,false)
	game.set_process(false)
	game.set_physics_process(false)
	game.story_label.visible = false
	game.toast_label.visible = false
	clinic = game.clinic_system
	clinic.set_process(false)
	game.player.position = clinic.sites[1].root.position+Vector3(0,0,3.2)
	game.yaw = 0
	game.player.rotation.y = 0
	game.camera_pivot.rotation.x = -0.40
	game.pitch = -0.40
	clinic.sites[1].stage = "clean"
	clinic._update_site_label(1)
	clinic.handle_interaction(0.01,false)
	await shot("phase27_before_clean")
	clinic.wash(1,0.5)
	clinic._process(0.001)
	await shot("phase27_foam_cleaning")
	for cell in clinic.sites[1].cells: clinic.clean_at(1,cell.mesh.global_position,0.2,2.0)
	game._set_role(3)
	for i in range(3):
		clinic.clock = (i+0.5)/0.58
		clinic.care_press(1)
	clinic.handle_interaction(0,false)
	game.toast_label.visible = false
	clinic.clean_flash = 0
	await shot("phase27_after_care")
	game.player.position = clinic.fishing_spots[0].root.position+Vector3(0,0,1.8)
	game.yaw = -PI*0.45
	game.player.rotation.y = game.yaw
	clinic.start_fishing(0)
	clinic._tick_fishing(3)
	clinic.fish_clock = 0.5/0.65
	clinic.handle_interaction(0,false)
	game.toast_label.visible = false
	await shot("phase27_fishing")
	clinic._cancel_fishing()
	game.player.position = clinic.upgrade.position+Vector3(0,0,1.6)
	game.yaw = 0.0
	game.player.rotation.y = 0
	game.credits = 160
	clinic.buy_upgrade()
	clinic.handle_interaction(0,false)
	game.toast_label.visible = false
	await shot("phase27_mart_upgrade")
	print("GODOT_PHASE27_CAPTURE_OK")
	quit(0)
