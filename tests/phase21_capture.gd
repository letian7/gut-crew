extends SceneTree
var game
func shot(label: String) -> void:
	for i in range(12): await process_frame
	RenderingServer.force_draw()
	assert(root.get_texture().get_image().save_png("res://GUT_CREW_QA_SHOTS/"+label+".png") == OK)
	print("PHASE21_CAPTURE ",label)
func _init() -> void:
	create_timer(45.0).timeout.connect(func():printerr("PHASE21_CAPTURE_TIMEOUT");quit(1))
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0,false)
	game.set_process(false)
	game.set_physics_process(false)
	for i in range(3): game._complete_clue(i)
	game._catch_mouse()
	game._begin_escape_finale()
	game.escape_finale.tick(2.8)
	game.story_label.visible = false
	await shot("phase21_gut_escape")
	game.escape_finale.tick(3.3)
	await shot("phase21_rear_exit")
	game.escape_finale.tick(2.5)
	game.terrain_world.overlay.visible = false
	game.host_boss.tick(0.01)
	await shot("phase21_toy_provocation")
	game.host_boss.tick(3.3)
	game.player.position.x = 5
	game.host_boss.attack_index = 4
	game.host_boss._begin_attack()
	game.host_boss.tick(0.01)
	await shot("phase21_charge_warning")
	print("GODOT_PHASE21_CAPTURE_OK")
	quit(0)
