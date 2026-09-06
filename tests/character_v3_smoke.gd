extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	var required: Array = [
		["SparkCable", "SparkBoltA", "SparkBrowL"],
		["KakaJaw", "KakaWrenchHead", "KakaKneeL"],
		["BubbleMembrane", "BubbleGlintA", "BubbleBeltWave"],
		["ShroomCapRim", "ShroomCollar", "ShroomBlushL"]
	]
	var counts: Array[int] = []
	for i in range(4):
		game._set_role(i)
		await process_frame
		counts.append(game.character_visual.get_child_count())
		for part_name in required[i]:
			assert(game.character_visual.get_node_or_null(part_name) != null)
	assert(counts.min() >= 25)
	game._set_role(3)
	await process_frame
	game.living_time = 1.25
	game._animate_role_model(0.016)
	var cap = game.character_visual.get_node("ShroomCap")
	var rim = game.character_visual.get_node("ShroomCapRim")
	assert(absf(cap.rotation.z - rim.rotation.z) < 0.001)
	print("GODOT_CHARACTER_V3_OK counts=", counts)
	quit(0)
