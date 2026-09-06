extends SceneTree
const Terrain = preload("res://scripts/terrain_world.gd")
const Mouth = preload("res://scripts/mouth_entry.gd")
const Vertical = preload("res://scripts/vertical_stomach.gd")
var walked := 0.0

func ray(game,a: Vector3,b: Vector3,mask := 4) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(a,b,mask)
	query.exclude = [game.player.get_rid()]
	query.hit_back_faces = true
	return game.get_world_3d().direct_space_state.intersect_ray(query)

func walk(game,a: Vector3,b: Vector3) -> void:
	a = game.world_point(a)
	b = game.world_point(b)
	game.player.position = a+Vector3.UP*0.12
	game.player.velocity = Vector3.ZERO
	var steps := ceili(a.distance_to(b)/5.8*60.0)+180
	for i in range(steps):
		await physics_frame
		var offset: Vector3 = b-game.player.position
		offset.y = 0.0
		if offset.length() < 0.24:
			assert(absf(game.player.position.y-b.y)<0.7,"Wrong elevation on enlarged route")
			walked += a.distance_to(b)
			return
		var vy: float = -2.0 if game.player.is_on_floor() else game.player.velocity.y-22.0/60.0
		game.player.velocity = offset.normalized()*5.8
		game.player.velocity.y = vy
		game.player.move_and_slide()
		assert(game.player.position.y > -0.6,"Fell through enlarged terrain")
	printerr("PHASE24_BLOCKED ",a," -> ",b," at ",game.player.position)
	assert(false,"Enlarged walk route blocked")

func _init() -> void:
	create_timer(600.0).timeout.connect(func(): printerr("PHASE24_TIMEOUT");quit(1))
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0)
	game.set_process(false)
	game.set_physics_process(false)
	assert(game.world_scale == 5.0,"Production layout must be five times, not legacy fixture")
	assert(game.get_meta("world_extent") == Vector2(260,180))
	assert(game.world_layout.baked_shapes > 50)
	assert(game.player.scale.is_equal_approx(Vector3.ONE))
	assert(game.entrance.scale.is_equal_approx(Vector3.ONE))
	assert(game.shop_root.scale.is_equal_approx(Vector3.ONE))
	assert(game.player.position.is_equal_approx(game.world_point(Mouth.SPAWN)))
	assert(game.clue_nodes[0].position.distance_to(game.clue_nodes[2].position) > 180.0)
	for enemy in game.enemies:
		assert(enemy.scale.is_equal_approx(Vector3.ONE))
		enemy.collision_layer = 0
		enemy.collision_mask = 0
	for body in game.find_children("*","StaticBody3D",true,false):
		assert(body.global_basis.get_scale().is_equal_approx(Vector3.ONE),"Non-uniform static body left behind")
	await physics_frame
	await walk(game,Vector3(0,17.61,63),Vector3(0,16.18,50))
	await walk(game,Vector3(0,16.18,50),Vector3(0,8.836,34.7))
	game.mouth_intro.tick(0.01)
	assert(game.mouth_intro.swallow_time > 0.0)
	game.mouth_intro.tick(1.3)
	assert(game.player.position.is_equal_approx(game.world_point(Mouth.ARRIVAL)))
	print("PHASE24_MOUTH_WALK_OK meters=",walked)
	for height in [0.6,4.0,9.5]:
		for i in range(64):
			var angle := TAU*float(i)/64.0
			var hit := ray(game,game.world_point(Vector3(cos(angle)*32,height,sin(angle)*32)),Vector3(0,height,0))
			assert(not hit.is_empty(),"Expanded perimeter hole")
			assert(hit.collider.get_parent().name == "ContinuousInnerWall")
	for link in Terrain.LINKS:
		for i in range(11):
			var p: Vector3 = game.world_point(link.a.lerp(link.b,float(i)/10.0))
			assert(not ray(game,p+Vector3.UP*0.3,p-Vector3.UP).is_empty())
			assert(not ray(game,p+Vector3.UP*2,p+Vector3.UP*9).is_empty())
		await walk(game,link.a,link.b)
		await walk(game,link.b,link.a)
		print("PHASE24_ORGAN_LINK_OK ",link.id)
	for side in [-1.0,1.0]:
		var foot := Vertical.LEFT_FOOT if side<0 else Vertical.RIGHT_FOOT
		var path: Array[Vector3] = [Vector3(side*3,4.6,11),Vector3(side*7,2.65,7.8),Vector3(side*7,2.65,6.5),foot,Vector3(foot.x,foot.y,2.4 if side<0 else 2.75),Vector3(foot.x,0,0)]
		for i in range(path.size()-1): await walk(game,path[i],path[i+1])
		path.reverse()
		for i in range(path.size()-1): await walk(game,path[i],path[i+1])
		print("PHASE24_FOLD_BOTH_DIRECTIONS_OK ",side)
	await walk(game,Vector3(-7,2.65,7),Vector3(7,2.65,7))
	await walk(game,Vector3(7,2.65,7),Vector3(-7,2.65,7))
	var safe: Vector3 = game.terrain_world.constrain_point(Vector3(600,30,600))
	assert(safe.x > 50 and safe.x < 125 and safe.z > 50 and safe.z < 85 and safe.y<=10)
	game.player.position = game.world_point(Vector3(18,1,3))
	game.yaw = 0.0
	game._spark_lightning_form()
	assert(game.player.position.x > 85,"Skill used obsolete small-map clamp")
	game.player.position = game.world_point(Vector3(0,0.1,5))
	game.acid_next = 99
	game.spasm_next = 99
	game.drink_next = 99
	game.acid_tide_time = 3.0
	game.hp = 100
	game._update_living_events(0.1)
	assert(game.hp < 100,"Expanded acid has no damage")
	game.player.position.x = 40
	var before: float = game.hp
	game._update_living_events(0.1)
	assert(game.hp == before,"Acid damage escaped its visual region")
	for i in range(game.organ_props.size()):
		if game.organ_props[i].get_meta("prop_type") == "relay_to_forest":
			game._use_organ_prop(i)
			assert(game.player.position.is_equal_approx(game.world_point(Vector3(14.5,1.25,9.2))))
	game.player.position = game.shop_pads[0].global_position
	assert(game._nearest_shop_item() == 0,"Shop no longer reachable")
	game.world_layout._process(0.0)
	assert("m" in game.world_layout.guide.text)
	game.game_paused = true
	game.world_layout._process(0.0)
	assert(not game.world_layout.guide.visible)
	game.game_paused = false
	print("GODOT_PHASE24_WORLD_SCALE_OK factor=5 extent=260x180 perimeter_rays=192 walked_m=",snappedf(walked,0.1)," baked=",game.world_layout.baked_shapes)
	quit(0)
