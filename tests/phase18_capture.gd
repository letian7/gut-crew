extends SceneTree

func _shot(name_text: String) -> void:
	await create_timer(0.4).timeout
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png("res://GUT_CREW_QA_SHOTS/"+name_text+".png") == OK)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0, false)
	game.set_process(false)
	game.set_physics_process(false)
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.current = true
	camera.fov = 36
	for canvas in game.find_children("*","CanvasLayer",true,false): canvas.visible = false
	var key := OmniLight3D.new()
	key.position = Vector3(-2,29,-3)
	key.light_color = Color("ffe4bd")
	key.light_energy = 3
	key.omni_range = 10
	game.add_child(key)
	for role in range(4):
		game._set_role(role)
		game.player.position = Vector3(0,25,0)
		game.player.rotation = Vector3.ZERO
		game.player.velocity = Vector3.ZERO
		game._animate_role_model(0.016)
		camera.position = Vector3(2.8,26.9,-5.4)
		camera.look_at(Vector3(0,26.18,0))
		await _shot("phase18_role_"+str(role))
	game._set_role(0)
	game.player.position = Vector3(0,0.2,4)
	game.player.rotation.y = PI*0.65
	game.character_visual.visible = true
	game.camera_3p.current = true
	game.camera_pivot.rotation.x = -0.08
	await _shot("phase18_hub_clean")
	for canvas in game.find_children("*","CanvasLayer",true,false): canvas.visible = true
	game.terrain_world.overlay.visible = false
	game.story_label.visible = false
	game.danger_label.visible = false
	game.terrain_world.zone_label.visible = false
	game._update_hud()
	await _shot("phase18_hub_hud")
	game.player.position = Vector3(14.5,0.4,2.8)
	game.player.rotation.y = PI
	await _shot("phase18_forest_link")
	game.player.position = Vector3(18,0.4,-2.2)
	game.player.rotation.y = 0
	await _shot("phase18_gut_link")
	var start := Time.get_ticks_msec()
	for i in range(120): await process_frame
	print("GODOT_PHASE18_CAPTURE_OK frames=120 elapsed_ms=",Time.get_ticks_msec()-start)
	quit(0)
