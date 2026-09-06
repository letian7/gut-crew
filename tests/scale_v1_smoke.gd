extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	assert(absf(game.spring_arm.spring_length - 5.85) < 0.01)
	assert(absf(game.camera_3p.fov - 68.0) < 0.01)
	assert(absf(game.camera_pivot.position.y - 1.48) < 0.01)
	assert(game.mounds.size() == 3)
	assert(game.mounds[0].scale.x < 4.0)
	var map: Node3D = game.map_visual_root
	var shell := map.get_node("StomachShell") as MeshInstance3D
	var ceiling := map.get_node("CeilingBulge") as MeshInstance3D
	var hanging := map.get_node("HangingFold") as MeshInstance3D
	assert(shell.scale.y >= 9.69)
	assert(ceiling.position.y >= 7.9)
	assert(hanging.position.y >= 6.2)
	var high := map.get_node("HighGroundSkin") as MeshInstance3D
	assert(high.scale.x <= 2.9)
	for i in range(4):
		game._select_role(i, false)
		game.living_time = 0.0
		game._animate_role_model(0.0)
		assert(game.character_visual.scale.x <= 0.93)
	print("GODOT_SCALE_V1_OK camera=",game.spring_arm.spring_length," shell_y=",shell.scale.y," role=",game.character_visual.scale.x)
	quit(0)
