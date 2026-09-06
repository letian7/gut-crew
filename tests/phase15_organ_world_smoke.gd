extends SceneTree

const OrganWorldFactory = preload("res://scripts/organ_world_factory.gd")

func _prop_index(game, prop_type: String) -> int:
	for i in range(game.organ_props.size()):
		if String(game.organ_props[i].get_meta("prop_type", "")) == prop_type:
			return i
	return -1

func _enemy_by_name(game, display_name: String) -> CharacterBody3D:
	for enemy in game.enemies:
		if String(enemy.get_meta("display_name", "")) == display_name:
			return enemy
	return null

func _init() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	assert(is_instance_valid(game.organ_world_root))
	assert(int(game.organ_world_root.get_meta("zone_count", 0)) == 4)
	var parts := int(game.organ_world_root.get_meta("visual_parts", 0))
	assert(parts >= 120)
	assert(game.organ_props.size() == 5)
	var required: Array[String] = [
		"HairballForestShelf", "TangledHair00", "GroomingTurbine",
		"IntestinalMazeShelf", "GutLoop00", "PeristalsisDrum",
		"LungChamberShelf", "Alveolus00", "AlveoliBellows",
		"NerveHighwayShelf", "SynapseNode00", "NerveFastTravelRelay"
	]
	for part_name in required:
		assert(game.organ_world_root.get_node_or_null(part_name) != null)
	var enemy_names: Dictionary = {}
	for enemy in game.enemies:
		var display_name := String(enemy.get_meta("display_name", ""))
		if display_name != "":
			enemy_names[display_name] = true
	assert(game.enemies.size() >= 18)
	for name in ["FUR MITE", "NEST ROLLER", "GUT GNAWER", "BILE BOUNCER",
		"BUBBLE LEECH", "POLLEN PUFF", "STATIC TICK", "AXON CHEWER"]:
		assert(enemy_names.has(name))
	var alveolus := game.organ_world_root.get_node("Alveolus00") as Node3D
	var old_scale := alveolus.scale
	OrganWorldFactory.animate(game.organ_world_root, game.organ_props, 3.0, 0.1, 0.7)
	assert(alveolus.scale.distance_to(old_scale) > 0.0001)

	game._select_role(0, false)
	var credits_before: int = game.credits
	var groomer_index := _prop_index(game, "groomer")
	var fur_mite := _enemy_by_name(game, "FUR MITE")
	game._use_organ_prop(groomer_index)
	assert(float(game.organ_props[groomer_index].get_meta("cooldown", 0.0)) > 0.0)
	assert(float(fur_mite.get_meta("stun", 0.0)) >= 5.9)
	assert(game.credits == credits_before + 6)
	var drum_index := _prop_index(game, "gut_drum")
	var gnawer := _enemy_by_name(game, "GUT GNAWER")
	var gnawer_hp := float(gnawer.get_meta("hp"))
	game._use_organ_prop(drum_index)
	assert(float(gnawer.get_meta("hp")) < gnawer_hp)
	var bellows_index := _prop_index(game, "bellows")
	game._use_organ_prop(bellows_index)
	assert(game.player.velocity.y >= 14.4)
	assert(game.plasma_soda_time >= 6.9)
	var forest_relay := _prop_index(game, "relay_to_nerve")
	game._use_organ_prop(forest_relay)
	assert(game.player.global_position.distance_to(Vector3(0.0, 1.25, -11.2)) < 0.1)
	var nerve_relay := _prop_index(game, "relay_to_forest")
	game._use_organ_prop(nerve_relay)
	assert(game.player.global_position.distance_to(Vector3(14.5, 1.25, 9.2)) < 0.1)
	assert(game.organ_prop_uses == 5)
	print("GODOT_PHASE15_ORGAN_WORLD_OK zones=4 parts=", parts,
		" props=", game.organ_props.size(), " enemies=", game.enemies.size())
	quit(0)
