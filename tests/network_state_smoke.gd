extends SceneTree
const NetworkState = preload("res://scripts/network_state.gd")
func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	game.role_selected = true
	game._set_role(2)
	var snap: Dictionary = game.build_network_snapshot()
	assert(NetworkState.validate(snap))
	assert(int(snap["schema"]) == 1)
	assert(int(snap["player"]["role"]) == 2)
	assert((snap["player"]["position"] as Array).size() == 3)
	var encoded := JSON.stringify(snap)
	assert(encoded.find("BUBBLE") == -1)
	assert(encoded.length() > 100)
	var mid := NetworkState.lerp_position([0.0,0.0,0.0],[2.0,4.0,6.0],0.5)
	assert(mid.distance_to(Vector3(1,2,3)) < 0.001)
	print("GODOT_NETWORK_STATE_OK bytes=",encoded.length())
	quit(0)
