extends SceneTree
var game
func shot(label: String) -> void:
	for i in range(12): await process_frame
	RenderingServer.force_draw()
	assert(root.get_texture().get_image().save_png("res://GUT_CREW_QA_SHOTS/"+label+".png") == OK)
	print("PHASE20_CAPTURE ",label)
func _init() -> void:
	create_timer(45.0).timeout.connect(func():printerr("PHASE20_CAPTURE_TIMEOUT");quit(1))
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0)
	game.set_process(false)
	game.set_physics_process(false)
	game.player.position.y = game.mouth_intro.floor_y(63)+0.18
	game.mouth_intro.tick(0.01)
	game._update_hud()
	await shot("phase20_mouth_start")
	game.player.position = Vector3(0,game.mouth_intro.floor_y(46)+0.2,46)
	await shot("phase20_throat_descent")
	game.mouth_intro.finish()
	game.player.position.y = 4.64
	game.terrain_world.overlay.visible = false
	game.story_label.visible = false
	game._update_hud()
	game.camera_pivot.rotation.x = -0.28
	await shot("phase20_stomach_upper")
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.position = Vector3(0,9.8,-2)
	camera.look_at(Vector3(0,2.5,8))
	camera.current = true
	for layer in game.find_children("*","CanvasLayer",true,false): layer.visible = false
	await shot("phase20_vertical_overview")
	print("GODOT_PHASE20_CAPTURE_OK")
	quit(0)
