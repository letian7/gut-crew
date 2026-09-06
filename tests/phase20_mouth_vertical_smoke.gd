extends SceneTree
const Mouth = preload("res://scripts/mouth_entry.gd")
const Vertical = preload("res://scripts/vertical_stomach.gd")

func walk(game, a: Vector3, b: Vector3) -> bool:
	game.player.position = a+Vector3.UP*0.12
	game.player.velocity = Vector3.ZERO
	for i in range(550):
		await physics_frame
		var offset: Vector3 = b-game.player.position
		offset.y = 0
		if offset.length() < 0.24:
			if absf(game.player.position.y-b.y)>=0.7:
				printerr("PHASE20_WRONG_ELEVATION ",a," -> ",b," actual=",game.player.position)
				return false
			return true
		var vy: float = -2.0 if game.player.is_on_floor() else game.player.velocity.y-22.0/60.0
		game.player.velocity = offset.normalized()*5.8
		game.player.velocity.y = vy
		game.player.move_and_slide()
	printerr("PHASE20_BLOCKED ",a," -> ",b," at ",game.player.position)
	return false

func _init() -> void:
	create_timer(95.0).timeout.connect(func(): printerr("PHASE20_TIMEOUT");quit(1))
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0)
	game.set_process(false)
	game.set_physics_process(false)
	assert(game.mouth_intro.active and game.mission_phase == "mouth")
	assert(game.player.position.is_equal_approx(Mouth.SPAWN))
	assert(game.mouth_intro.get_meta("floor_drop") > 9.0)
	game.terrain_world.keep_inside()
	assert(game.player.position.z > 60 and game.player.position.y > 16)
	game._spark_lightning_form()
	assert(game.player.position.z > 50 and game.player.position.y > 15)
	game.ko_time = 0.01
	game._physics_process(0.02)
	assert(game.player.position.z > 60)
	game.game_paused = true
	game.mouth_intro.tick(0.5)
	assert(game.mouth_intro.active)
	game.game_paused = false
	for enemy in game.enemies:
		enemy.collision_layer = 0
		enemy.collision_mask = 0
	assert(await walk(game,Vector3(0,game.mouth_intro.floor_y(63)+0.16,63),Vector3(0,game.mouth_intro.floor_y(50)+0.16,50)))
	assert(await walk(game,Vector3(0,game.mouth_intro.floor_y(50)+0.16,50),Vector3(0,game.mouth_intro.floor_y(34.7)+0.16,34.7)))
	print("PHASE20_TONGUE_THROAT_WALK_OK")
	game.mouth_intro.tick(0.01)
	assert(game.terrain_world.overlay.visible and game.mouth_intro.swallow_time > 0)
	game.game_paused = true
	var before: float = game.mouth_intro.swallow_time
	game.mouth_intro.tick(2.0)
	assert(game.mouth_intro.swallow_time == before)
	game.game_paused = false
	game.mouth_intro.tick(1.3)
	assert(not game.mouth_intro.active and game.mouth_intro.completed)
	assert(game.mission_phase == "diagnose" and game.player.position.is_equal_approx(Mouth.ARRIVAL))
	for side in [-1.0,1.0]:
		var top := Vector3(side*3,4.6,11)
		var mid := Vector3(side*7,Vertical.BRIDGE_Y,7.8)
		var low := Vector3(side*7,Vertical.BRIDGE_Y,6.5)
		var foot := Vertical.LEFT_FOOT if side < 0 else Vertical.RIGHT_FOOT
		var edge := Vector3(foot.x,foot.y,2.4 if side < 0 else 2.75)
		var ground := Vector3(foot.x,0,0)
		assert(await walk(game,top,mid))
		assert(await walk(game,mid,low))
		assert(await walk(game,low,foot))
		assert(await walk(game,foot,edge))
		assert(await walk(game,edge,ground))
		assert(await walk(game,ground,edge))
		assert(await walk(game,edge,foot))
		assert(await walk(game,foot,low))
		assert(await walk(game,low,mid))
		assert(await walk(game,mid,top))
		print("PHASE20_BIDIRECTIONAL_FOLD_OK ",side)
	assert(await walk(game,Vector3(-7,Vertical.BRIDGE_Y,7),Vector3(7,Vertical.BRIDGE_Y,7)))
	assert(await walk(game,Vector3(7,Vertical.BRIDGE_Y,7),Vector3(-7,Vertical.BRIDGE_Y,7)))
	game.mission_phase = "return"
	game._begin_host_boss()
	preload("res://tests/host_boss_test_helper.gd").finish(game)
	assert(game.mission_phase == "win")
	print("GODOT_PHASE20_MOUTH_VERTICAL_OK spawn=mouth descent=10m levels=3 routes=walked phase=win")
	quit(0)
