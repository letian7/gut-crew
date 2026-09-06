extends SceneTree

const AnatomyFactory = preload("res://scripts/stomach_anatomy_factory.gd")

func _init() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	assert(is_instance_valid(game.stomach_anatomy_root))
	var anatomy: Node3D = game.stomach_anatomy_root
	assert(int(anatomy.get_meta("anatomical_zones", 0)) == 5)
	var parts := int(anatomy.get_meta("visual_parts", 0))
	assert(parts >= 210)
	var required: Array[String] = [
		"FundusLobe00", "CorpusMucosa00", "AntrumFunnel00",
		"PyloricCollar00", "CardiaRosette00", "MucosalRuga00",
		"GastricPit00", "MucosalVessel00", "MucusFilm00",
		"PeristalticBand00"
	]
	for part_name in required:
		assert(anatomy.get_node_or_null(part_name) != null)
	var ruga: Node3D = anatomy.get_node("MucosalRuga00")
	var old_scale := ruga.scale
	AnatomyFactory.animate(anatomy, 2.75, 0.8)
	assert(ruga.scale.distance_to(old_scale) > 0.0001)

	var counts: Array[int] = []
	var signatures: Array[String] = [
		"SparkEarCoil", "KakaBackVertebra",
		"BubbleSuspendedCell", "ShroomRadialGill"
	]
	var common_parts: Array[String] = [
		"ClayNose", "LowerLip", "EyeCatchlight", "ClayEyelid",
		"Palm", "Finger", "Thumb", "BootToe", "BootSole",
		"SoleTread", "ChestSeam", "ElbowPad", "ClayDent"
	]
	for role in range(4):
		game._set_role(role)
		await process_frame
		assert(int(game.character_visual.get_meta("model_version", 0)) == 5)
		var count: int = game.character_visual.get_child_count() - 1
		assert(game.character_visual.get_node_or_null("Art18Model") != null)
		assert(int(game.character_visual.get_meta("art18_legacy_count", 0)) == count)
		counts.append(count)
		assert(count >= 65)
		for part_name in common_parts:
			assert(game.character_visual.get_node_or_null(part_name) != null)
		assert(game.character_visual.get_node_or_null(signatures[role]) != null)
		assert(int(game.character_visual.get_meta("v5_part_count", 0)) == count)
	assert(counts == [73, 81, 71, 80])
	print("GODOT_PHASE14_ANATOMY_CHARACTER_OK anatomy=", parts,
		" counts=", counts, " zones=5")
	quit(0)
