extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	var required := [
		["SparkPlugTipL","SparkRivetL","SparkCable"],
		["KakaCrown","KakaBoltL","KakaWrenchHead"],
		["BubbleCrownRing","BubbleDropL","BubbleMembrane"],
		["ShroomMedicBag","ShroomVialA","ShroomCapRim"]
	]
	var counts: Array[int] = []
	for i in range(4):
		game._set_role(i)
		await process_frame
		counts.append(game.character_visual.get_child_count())
		for part_name in required[i]: assert(game.character_visual.get_node_or_null(part_name) != null)
	assert(counts.min() >= 29)
	game._set_role(0)
	await process_frame
	game.living_time = 1.2
	game._animate_role_model(0.016)
	var prong = game.character_visual.get_node("SparkProngL") as Node3D
	var tip = game.character_visual.get_node("SparkPlugTipL") as Node3D
	var expected: Vector3 = prong.transform * Vector3(0,0.56,0)
	assert(tip.position.distance_to(expected) < 0.001)
	print("GODOT_CHARACTER_V4_OK counts=", counts)
	quit(0)
