extends SceneTree
const MapFactory = preload("res://scripts/map_factory.gd")

func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	var map: Node3D = game.map_visual_root
	assert(map != null)
	var required := ["StomachShell", "CardiaGateModel", "PyloricGateModel", "NerveCord", "MucusBead", "AcidBubble", "HighGroundSkin"]
	for part_name in required:
		assert(map.get_node_or_null(part_name) != null)
	assert(map.get_child_count() > 80)
	var bead := map.get_node("MucusBead") as MeshInstance3D
	var y0 := bead.position.y
	MapFactory.animate(map, 1.37, 1.0)
	assert(absf(bead.position.y - y0) > 0.001)
	var prop_keys := ["SwallowedPill", "SwallowedCap", "SwallowedToy", "SwallowedBone"]
	for i in range(4):
		var prop := Node3D.new()
		MapFactory.build_swallowed_prop(prop, i)
		assert(prop.get_node_or_null(prop_keys[i]) != null)
		assert(prop.get_child_count() >= 2)
		prop.queue_free()
	print("GODOT_MAP_VISUAL_V2_OK parts=", map.get_child_count())
	quit(0)
