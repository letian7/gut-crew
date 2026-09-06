extends SceneTree
func _init() -> void:
	create_timer(30).timeout.connect(func():printerr("PHASE25_TIMEOUT");quit(1))
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0)
	game.set_process(false)
	game.set_physics_process(false)
	assert(game.world_scale == 5.0)
	assert(game.mouth_intro.roof_lift == 1.8)
	assert(game.get_meta("proportion_fixed25") > 100)
	assert(game.get_meta("distance_details25") > 100)
	var teeth := 0
	for mesh in game.mouth_intro.get_children():
		if mesh.get_meta("sculpted_tooth",false):
			assert(mesh.top_level)
			assert(mesh.global_basis.get_scale().is_equal_approx(Vector3.ONE*1.6),"Tooth sculpture flattened")
			assert(mesh.is_visible_in_tree())
			teeth += 1
	assert(teeth == 28)
	var fill = game.player.get_node("CrewSoftFill25")
	assert(fill.light_energy > 0.0 and not fill.shadow_enabled)
	assert(game.player.scale == Vector3.ONE)
	game.mouth_intro.finish()
	for mesh in game.organ_world_root.get_children():
		if mesh.has_meta("sculpture_proportion25"):
			assert(mesh.top_level)
			assert(mesh.visibility_range_end == 65.0)
	# Dynamic decoration animation must not restore the flattened parent transform.
	game.OrganWorldFactory.animate(game.organ_world_root,game.organ_props,5.0,0.016,0.0)
	var hair = game.organ_world_root.get_node("TangledHair00")
	var shape: Vector3 = hair.global_basis.get_scale()
	assert(shape.y/shape.x > 5.0,"Hair animation undid proportion fix")
	game.drink_wave.position = Vector3(0,0.18,0)
	assert(game._in_drink_wave(Vector3(2.7,0.3,0)),"Expanded visible water has no contact")
	assert(not game._in_drink_wave(Vector3(4.0,0.3,0)),"Invisible water beyond slab")
	assert(not game._in_drink_wave(Vector3(0,2.65,0)),"Bridge is not safe from lowland water")
	assert(not game._in_drink_wave(Vector3(0,0.3,80)),"Water escaped the stomach region")
	game.player.position = game.world_point(Vector3(-8,0.2,0))
	game.world_layout._process(0.0)
	assert(game.world_layout.guide.visible and "m" in game.world_layout.guide.text)
	game.mouth_intro.begin()
	assert(not hair.is_visible_in_tree(),"Top-level artwork ignored hidden mouth world")
	game.mouth_intro.finish()
	assert(hair.is_visible_in_tree())
	game.mission_phase = "return"
	game.mouse_caught = true
	game._begin_escape_finale()
	game.world_layout._process(0.0)
	assert(not game.world_layout.guide.visible)
	assert(game.escape_finale.rail(0.0).x > 180.0,"Escape route overlaps expanded stomach")
	print("GODOT_PHASE25_WORLD_POLISH_OK teeth=28 proportions=",game.get_meta("proportion_fixed25")," distance_details=",game.get_meta("distance_details25")," water=aligned shade=readable visibility=restored")
	quit(0)
