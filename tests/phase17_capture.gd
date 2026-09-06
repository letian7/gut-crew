extends SceneTree
func _shot(path: String) -> void:
	await create_timer(0.25).timeout
	await RenderingServer.frame_post_draw
	assert(root.get_viewport().get_texture().get_image().save_png(path) == OK)

func _pose(game, pos: Vector3, angle: float, first := false) -> void:
	game.player.global_position = pos
	game.player.velocity = Vector3.ZERO
	game.yaw = angle
	game.player.rotation.y = angle
	game.camera_pivot.rotation.x = -0.08
	game.camera_1p.current = first
	game.camera_3p.current = not first
	game.character_visual.visible = not first
	game.story_label.visible = false
	game.danger_label.visible = false
	game.terrain_world.zone_label.visible = false
	game._update_hud()

func _init() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0, false)
	game.set_process(false)
	game.set_physics_process(false)
	_pose(game,Vector3(0,0.2,4),PI*0.65)
	await _shot("res://GUT_CREW_QA_SHOTS/phase17_enclosed_hub.png")
	_pose(game,Vector3(14.5,0.38,2.8),PI)
	await _shot("res://GUT_CREW_QA_SHOTS/phase17_forest_passage.png")
	_pose(game,Vector3(18,0.4,-2.2),0.0)
	await _shot("res://GUT_CREW_QA_SHOTS/phase17_gut_passage.png")
	_pose(game,Vector3(-18,0.5,7.5),PI,true)
	await _shot("res://GUT_CREW_QA_SHOTS/phase17_lung_interior.png")
	_pose(game,Vector3(0,0.86,-5.4),0.0)
	await _shot("res://GUT_CREW_QA_SHOTS/phase17_nerve_passage.png")
	game.mission_phase = "return"
	game._begin_host_boss()
	await _shot("res://GUT_CREW_QA_SHOTS/phase17_capsule_transition.png")
	game.terrain_world.tick(2.0)
	game.host_boss.tick(0.01)
	await _shot("res://GUT_CREW_QA_SHOTS/phase17_closed_clinic.png")
	_pose(game,Vector3(0,40.8,5),PI)
	await _shot("res://GUT_CREW_QA_SHOTS/phase17_clinic_reverse.png")
	print("GODOT_PHASE17_CAPTURE_OK")
	quit(0)
