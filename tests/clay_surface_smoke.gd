extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	for i in range(4):
		game._set_role(i)
		await process_frame
		var marks := 0
		for child in game.character_visual.get_children():
			if child.get_meta("clay_print", false): marks += 1
		assert(marks >= 3)
	var map: Node3D = game.map_visual_root
	var wall_marks := 0
	var wall: MeshInstance3D = null
	for child in map.get_children():
		if child.get_meta("clay_wall_print", false):
			wall_marks += 1
			if wall == null: wall = child as MeshInstance3D
	assert(wall_marks >= 16)
	assert(map.get_node_or_null("ClayPress") != null)
	assert(map.get_child_count() >= 230)
	assert(wall != null)
	var mat := wall.material_override as StandardMaterial3D
	assert(mat != null and mat.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA)
	print("GODOT_CLAY_SURFACE_OK parts=", map.get_child_count(), " wall_marks=", wall_marks)
	quit(0)
