extends SceneTree
const SkillVFX = preload("res://scripts/skill_vfx.gd")
const EnemyFactory = preload("res://scripts/enemy_factory.gd")

func shot(game, path: String) -> void:
	await create_timer(0.10).timeout
	await RenderingServer.frame_post_draw
	var img := root.get_viewport().get_texture().get_image()
	img.save_png(path)

func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	game.role_selected = true
	game.role_panel.visible = false
	game.set_physics_process(false)
	game.player.position = Vector3(0,1.15,4.2)
	game.spring_arm.spring_length = 5.4
	game.camera_3p.fov = 70.0
	var ui_nodes := [game.status_label,game.view_label,game.help_label,game.danger_label,game.target_label,game.toast_label,game.mission_label,game.interact_label,game.crosshair]
	for n in ui_nodes:
		if n: n.visible = false
	var out := "C:/Users/EDY/Desktop/GUT_CREW_PHASE6_SHOTS"
	DirAccess.make_dir_recursive_absolute(out)
	for e in game.enemies:
		if is_instance_valid(e): e.visible = false
	await shot(game,out+"/map_v4.png")
	var enemy: CharacterBody3D = game.enemies[2]
	enemy.visible = true
	enemy.global_position = Vector3(0,0.2,0.9)
	var ev := enemy.get_meta("visual") as Node3D
	EnemyFactory.animate(ev,String(enemy.get_meta("kind")),1.0,Vector3.ZERO,false,false,0.85)
	EnemyFactory.spawn_attack_telegraph(game,String(enemy.get_meta("kind")),enemy.global_position)
	await shot(game,out+"/enemy_telegraph.png")
	enemy.visible = false
	SkillVFX.spawn_sync_pair(game,Vector3(0,0.05,0.8),3,0,1,game.ROLE_COLORS[0],game.ROLE_COLORS[1])
	await shot(game,out+"/sync_spark_kaka.png")
	await create_timer(0.50).timeout
	SkillVFX.spawn_sync_pair(game,Vector3(0,0.05,0.8),3,2,3,game.ROLE_COLORS[2],game.ROLE_COLORS[3])
	await shot(game,out+"/sync_bubble_shroom.png")
	game.mission_phase = "chase"
	game._spawn_mission_mouse()
	game.mouse_target.visible = true
	game.mouse_target.global_position = Vector3(0,0.25,0.9)
	EnemyFactory.spawn_mouse_burst(game,game.mouse_target.global_position)
	await shot(game,out+"/mouse_turbo.png")
	print("GODOT_PHASE6_CAPTURE_OK")
	quit(0)
