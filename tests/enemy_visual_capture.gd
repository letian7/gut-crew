extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	game.role_panel.visible = false
	game.role_selected = true
	game.character_visual.visible = false
	game.help_label.visible = false
	game.status_label.visible = false
	game.view_label.visible = false
	game.crosshair.visible = false
	game.danger_label.visible = false
	game.target_label.visible = false
	game.mission_label.visible = false
	game.interact_label.visible = false
	game.set_physics_process(false)
	var out := "C:/Users/EDY/Desktop/GUT_CREW_ENEMY_SHOTS"
	DirAccess.make_dir_recursive_absolute(out)
	var kinds := ["HAIRBALL","PLATELET","PARASITE"]
	for kind in kinds:
		for e in game.enemies: e.visible = false
		var target = game.enemies.filter(func(x): return String(x.get_meta("kind")) == kind)[0]
		target.visible = true
		target.global_position = game.player.global_position + Vector3(0,-0.8,-3.2)
		target.rotation = Vector3(0,PI,0)
		await process_frame
		await RenderingServer.frame_post_draw
		var img := game.get_viewport().get_texture().get_image()
		img.save_png(out + "/" + kind.to_lower() + ".png")
	print("GODOT_ENEMY_VISUAL_CAPTURE_OK")
	quit(0)