extends SceneTree
var game
func shot(label: String) -> void:
	for i in range(12): await process_frame
	RenderingServer.force_draw()
	assert(root.get_texture().get_image().save_png("res://GUT_CREW_QA_SHOTS/"+label+".png") == OK)
func _init() -> void:
	create_timer(30).timeout.connect(func():printerr("PHASE26_CAPTURE_TIMEOUT");quit(1))
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0,false)
	game.set_process(false)
	game.set_physics_process(false)
	game.story_label.visible = false
	game.player.position = game.world_point(Vector3(-8.2,0.04,0))
	game.yaw = -0.6
	game.player.rotation.y = game.yaw
	game._spawn_enemy("HAIRBALL",game.player.position+game._forward()*4.5,Color.WHITE,100,0)
	var enemy = game.enemies[-1]
	game._damage_enemy(enemy,18)
	game.impact_feedback.set_process(false)
	game.impact_feedback.tick(0.01)
	game.combat_hud.tick(0)
	game.tactical_map.refresh = 0
	game.tactical_map.tick(0)
	await shot("phase26_minimap_hit")
	game.hp = 63
	game.impact_feedback.report_hurt(game.player.position+Vector3.LEFT*4)
	game.impact_feedback.tick(0.01)
	game.combat_hud.tick(0.01)
	await shot("phase26_directional_hurt")
	print("GODOT_PHASE26_CAPTURE_OK")
	quit(0)
