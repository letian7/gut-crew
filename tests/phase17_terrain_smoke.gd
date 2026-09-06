extends SceneTree
const Terrain = preload("res://scripts/terrain_world.gd")

func _ray(game, a: Vector3, b: Vector3, mask := 4) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(a,b,mask)
	query.exclude = [game.player.get_rid()]
	query.hit_back_faces = true
	return game.get_world_3d().direct_space_state.intersect_ray(query)

func _walk(game, a: Vector3, b: Vector3) -> void:
	game.player.global_position = a+Vector3.UP*0.15
	game.player.velocity = Vector3.ZERO
	for step in range(150):
		await physics_frame
		var offset: Vector3 = b-game.player.global_position
		offset.y = 0.0
		if offset.length() < 0.20: return
		var fall: float = -2.0 if game.player.is_on_floor() else game.player.velocity.y-22.0/60.0
		game.player.velocity = offset.normalized()*4.5
		game.player.velocity.y = fall
		game.player.move_and_slide()
		assert(game.player.position.y > -0.5)
	printerr("BLOCKED_ROUTE ",a," -> ",b," stopped ",game.player.position)
	assert(false,"Door or ramp blocked")

func _init() -> void:
	create_timer(60.0).timeout.connect(func(): printerr("PHASE17_TIMEOUT"); quit(1))
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0, false)
	game.set_process(false)
	game.set_physics_process(false)
	for enemy in game.enemies:
		enemy.collision_layer = 0
		enemy.collision_mask = 0
	var terrain = game.terrain_world
	assert(terrain.get_meta("closed_boundary"))
	assert(terrain.get_meta("walkable_links") == 4)
	assert(terrain.get_meta("chamber_count") == 4)
	assert(not game.map_visual_root.get_node("StomachShell").visible)
	await physics_frame
	var rays := 0
	for height in [0.6,4.0,9.5]:
		for i in range(64):
			var angle := TAU*float(i)/64.0
			# Sample immediately outside the stomach; the separate mouth now occupies z=33..68.
			var outside := Vector3(cos(angle)*32.0,height,sin(angle)*32.0)
			var hit := _ray(game,outside,Vector3(0,height,0))
			assert(not hit.is_empty(),"Perimeter hole")
			assert(hit["collider"].get_parent().name == "ContinuousInnerWall")
			rays += 1
	assert(not _ray(game,Vector3(0,2,0),Vector3(0,25,0)).is_empty())
	assert(not _ray(game,Vector3(0,-0.1,0),Vector3(0,-4,0)).is_empty())
	for link in Terrain.LINKS:
		var a: Vector3 = link["a"]
		var b: Vector3 = link["b"]
		for i in range(11):
			var p := a.lerp(b,float(i)/10.0)
			assert(not _ray(game,p+Vector3.UP*0.3,p-Vector3.UP).is_empty())
			assert(not _ray(game,p+Vector3.UP*2,p+Vector3.UP*9).is_empty())
		assert(_ray(game,a+Vector3.UP*1.0,b+Vector3.UP*1.0).is_empty())
		await _walk(game,a,b)
		await _walk(game,b,a)
		print("PHASE17_LINK_WALK_OK ",link["id"])
	await _walk(game,Vector3(0,0.035,-3.2),Vector3(0,0.825,-5.3))
	game.player.position = Vector3(18,1.0,3.0)
	game.yaw = 0.0
	game._spark_lightning_form()
	assert(game.player.position.x > 17.5,"Old small-map clamp returned player to hub")
	var safe: Vector3 = terrain.constrain_point(Vector3(80,30,80))
	assert(safe.y <= 10.0 and safe.x < 25.0 and safe.z < 17.0)
	game.mission_phase = "return"
	game._begin_host_boss()
	assert(terrain.overlay.visible)
	game.game_paused = true
	terrain.tick(1.0)
	assert(is_equal_approx(terrain.transition_time,1.6))
	game.game_paused = false
	terrain.tick(2.0)
	assert(not terrain.overlay.visible)
	var clinic = game.host_boss.get_node("ClosedClinicRoom")
	assert(clinic.get_meta("wall_count") == 4)
	assert(clinic.get_node_or_null("RoomCeiling") != null)
	await physics_frame
	for direction in [Vector3.RIGHT,Vector3.LEFT,Vector3.FORWARD,Vector3.BACK,Vector3.UP]:
		assert(not _ray(game,Vector3(0,46,2),Vector3(0,46,2)+direction*50,1).is_empty())
	preload("res://tests/host_boss_test_helper.gd").finish(game)
	assert(game.mission_phase == "win")
	print("GODOT_PHASE17_TERRAIN_OK perimeter_rays=",rays," bidirectional_links=4 clinic=closed phase=win")
	quit(0)
