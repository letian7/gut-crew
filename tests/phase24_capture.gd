extends SceneTree
var game
func shot(label: String) -> void:
	for i in range(14): await process_frame
	RenderingServer.force_draw()
	assert(root.get_texture().get_image().save_png("res://GUT_CREW_QA_SHOTS/"+label+".png") == OK)
	print("PHASE24_CAPTURE ",label)
func _init() -> void:
	create_timer(55.0).timeout.connect(func():printerr("PHASE24_CAPTURE_TIMEOUT");quit(1))
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0)
	game.set_process(false)
	game.set_physics_process(false)
	game.player.position = game.world_point(Vector3(0,17.65,63))
	game.story_label.visible = false
	game._update_hud()
	await shot("phase24_mouth_5x")
	game.mouth_intro.finish()
	game.terrain_world.overlay.visible = false
	game.story_label.visible = false
	game.player.position.y = 4.66
	game.camera_pivot.rotation.x = -0.18
	await shot("phase24_stomach_upper_5x")
	game.player.position = game.world_point(Vector3(-8.2,0.05,0))
	game.yaw = -0.65
	game.player.rotation.y = game.yaw
	await shot("phase24_lowland_5x")
	game.player.position = game.world_point(Vector3(14.5,0.59,8.0))
	game.player.rotation.y = PI
	game.yaw = PI
	await shot("phase24_forest_5x")
	print("GODOT_PHASE24_CAPTURE_OK")
	quit(0)
