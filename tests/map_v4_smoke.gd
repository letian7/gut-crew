extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	var map: Node3D = game.map_visual_root
	assert(map.get_node_or_null("MuscleFiber") != null)
	assert(map.get_node_or_null("MucusStrand") != null)
	assert(map.get_node_or_null("MucusDrop") != null)
	assert(map.get_node_or_null("TissueSeam") != null)
	assert(map.get_child_count() >= 280)
	var strand := map.get_node("MucusStrand") as MeshInstance3D
	var before: Vector3 = strand.scale
	game.MapFactory.animate(map,1.4,0.6)
	var after: Vector3 = strand.scale
	assert(absf(after.y-before.y) > 0.001)
	print("GODOT_MAP_V4_OK parts=",map.get_child_count()," strand_y=",before.y,"->",after.y)
	quit(0)
