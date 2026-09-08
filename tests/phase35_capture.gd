extends SceneTree
var game
func shot(label: String) -> void:
	for i in range(6): await process_frame
	RenderingServer.force_draw()
	assert(root.get_texture().get_image().save_png("res://GUT_CREW_QA_SHOTS/"+label+".png")==OK)
func _init() -> void:
	create_timer(30).timeout.connect(func(): printerr("PHASE35_CAPTURE_TIMEOUT"); quit(1))
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await physics_frame
	game._select_role(1,true)
	game.set_process(false)
	game.set_physics_process(false)
	game.set_process_unhandled_input(false)
	game.story_label.hide()
	var training: Node3D=game.mouth_intro.training
	game.player.position=training.stations[0].global_position+Vector3(2.0,0.25,5.0)
	game.yaw=0.25
	game.player.rotation.y=game.yaw
	game.camera_pivot.rotation.x=0.0
	training.tick(0.1)
	await shot("phase35_mouth_lessons")
	game.player.position=training.pickups[0].node.global_position+Vector3(0,0,1)
	training.take(0)
	game.inventory_ui.open_inventory()
	await shot("phase35_supply_inventory")
	game.inventory_ui.close_inventory()
	var anchor: Node3D=training.get_node("PalatePracticeAnchor")
	game.player.position=game.world_point(Vector3(0,game.mouth_intro.floor_y(56)+1.0,56))+Vector3(0,0,4)
	var direction: Vector3=(anchor.global_position-game.camera_1p.global_position).normalized()
	game.yaw=atan2(-direction.x,-direction.z)
	game.pitch=asin(direction.y)
	game.player.rotation.y=game.yaw
	game.camera_pivot.rotation.x=game.pitch
	game.kaka_hook_charge=1.0
	game._release_kaka_hook()
	game._tick_kaka_hook_projectile(0.12)
	training.tick(0.1)
	await shot("phase35_right_hand_launch")
	for i in range(60):
		game._tick_kaka_hook_projectile(0.02)
		if game.kaka_hook_phase!="outgoing": break
	assert(game.kaka_hook_phase=="attached")
	await shot("phase35_palate_rope")
	print("GODOT_PHASE35_CAPTURE_OK shots=4")
	quit()
