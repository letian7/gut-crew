extends SceneTree
var game

func shot(filename: String, frames := 4) -> void:
	for i in range(frames): await process_frame
	RenderingServer.force_draw()
	assert(root.get_texture().get_image().save_png("res://GUT_CREW_QA_SHOTS/"+filename+".png")==OK)

func _init() -> void:
	create_timer(50).timeout.connect(func(): printerr("PHASE32_CAPTURE_TIMEOUT"); quit(1))
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await physics_frame
	game._select_role(1,false)
	game.set_process(false)
	game.set_physics_process(false)
	game.story_label.visible=false
	game.toast_label.visible=false
	game.mouth_intro.active=false
	game.player.global_position=Vector3(0,1.15,5.5)
	game.yaw=0.0
	game.pitch=-0.10
	game.player.rotation.y=0.0
	game.camera_pivot.rotation.x=game.pitch
	for enemy in game.enemies: enemy.visible=false
	var target: CharacterBody3D=game.enemies[0]
	target.visible=true
	target.set_meta("dead",false)
	target.set_meta("hp",240.0)
	target.set_meta("max_hp",240.0)
	target.global_position=Vector3(0,0.2,-3.8)
	game.secondary_attack_cd=0.0
	game._secondary_pressed()
	game._tick_phase11(0.85)
	await shot("phase32_kaka_hook_aim",5)
	game._secondary_released()
	game._tick_kaka_hook_projectile(0.18)
	await shot("phase33_kaka_hook_flight",2)
	for i in range(40):
		game._tick_kaka_hook_projectile(0.03)
		if game.kaka_hook_phase.is_empty(): break
	target.visible=false
	target.set_meta("dead",true)
	game.skill_q_cd=0.0
	game._cast_skill(0)
	await shot("phase33_bone_wall_preview",5)
	game._cast_skill(0)
	await shot("phase33_bone_wall_solid",3)
	game.skill_e_cd=0.0
	game._cast_skill(1)
	game._tick_kaka_rush_contacts()
	await shot("phase33_wall_push",8)
	await create_timer(0.34).timeout
	await shot("phase33_wall_endpoint_shatter",2)
	print("GODOT_PHASE33_CAPTURE_OK shots=6")
	quit()
