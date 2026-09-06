extends SceneTree
const MapFactory = preload("res://scripts/map_factory.gd")

func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	var map: Node3D = game.map_visual_root
	assert(map != null)
	var required := ["HangingFold","GlandPore","GlandGlow","AcidFoam","VesselBranch","OrganGlow"]
	for part_name in required: assert(map.get_node_or_null(part_name) != null)
	assert(map.get_child_count() > 170)
	var fold := map.get_node("HangingFold") as MeshInstance3D
	var foam := map.get_node("AcidFoam") as MeshInstance3D
	var r0: float = fold.rotation.z
	var y0: float = foam.position.y
	MapFactory.animate(map,1.45,1.0)
	assert(absf(fold.rotation.z-r0) > 0.0001)
	assert(absf(foam.position.y-y0) > 0.001)
	var lights := 0
	for child in map.get_children():
		if child is OmniLight3D: lights += 1
	assert(lights == 2)
	print("GODOT_MAP_V3_OK parts=", map.get_child_count(), " lights=", lights)
	quit(0)
