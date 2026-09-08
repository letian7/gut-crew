extends SceneTree
var game
func aim_at(point: Vector3) -> void:
	var direction: Vector3=(point-game.camera_1p.global_position).normalized()
	game.yaw=atan2(-direction.x,-direction.z)
	game.pitch=asin(direction.y)
	game.player.rotation.y=game.yaw
	game.camera_pivot.rotation.x=game.pitch

func surface(pos: Vector3, size: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	game.add_child(body)
	body.position=pos
	body.collision_layer=1
	var shape := BoxShape3D.new()
	shape.size=size
	var c := CollisionShape3D.new()
	c.shape=shape
	body.add_child(c)
	return body

func fire(point: Vector3, target: CharacterBody3D = null) -> void:
	game._clear_kaka_hook_projectile()
	game.player.velocity=Vector3.ZERO
	aim_at(point)
	game.kaka_hook_target=target
	game.kaka_hook_charge=1.0
	game._release_kaka_hook()
	var muzzle: Node3D=game.first_person_viewmodel.get_node("RightClayArm/RoleTool/HookMuzzle")
	assert(game.kaka_hook_start.distance_to(muzzle.global_position)<0.01)
	for i in range(100):
		game._tick_kaka_hook_projectile(0.02)
		if game.kaka_hook_phase!="outgoing": break

func _init() -> void:
	create_timer(35).timeout.connect(func(): printerr("PHASE35_TIMEOUT"); quit(1))
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await physics_frame
	game._select_role(1,false)
	game.set_process(false)
	game.set_physics_process(false)
	for enemy in game.enemies: enemy.set_meta("dead",true)
	game.player.position=Vector3(0,50,400)
	var wall := surface(Vector3(0,51,389),Vector3(7,7,0.4))
	var roof := surface(Vector3(0,61,399),Vector3(8,0.4,8))
	var ground := surface(Vector3(0,44,400),Vector3(20,0.5,20))
	await physics_frame
	fire(wall.position)
	assert(game.kaka_hook_phase=="attached")
	assert(game.grapple.anchor_body==wall)
	var distance: float=game.player.position.distance_to(game.kaka_hook_tip)
	for i in range(20):
		game.grapple.motion(game,0.016,Vector3.ZERO)
		game.player.move_and_slide()
		await physics_frame
	assert(game.player.position.distance_to(game.kaka_hook_tip)<distance)
	assert(game.player.position.z>389.2)
	game.player.position=Vector3(0,50,400)
	fire(roof.position)
	assert(game.kaka_hook_phase=="attached" and game.grapple.hanging)
	game.player.velocity=Vector3(6,0,0)
	game.grapple.motion(game,0.016,Vector3.RIGHT)
	assert(game.player.velocity.x>5.0)
	game.grapple.release(game,true)
	assert(game.kaka_hook_phase.is_empty() and game.player.velocity.x>5.0 and game.player.velocity.y>=6.0)
	fire(ground.position)
	assert(game.kaka_hook_phase=="attached" and not game.grapple.hanging)
	game._clear_kaka_hook_projectile()
	var elite: CharacterBody3D=game.enemies[0]
	elite.position=Vector3(0,50,394)
	elite.set_meta("dead",false)
	elite.set_meta("hp",500.0)
	elite.set_meta("heavy",true)
	var original := elite.position
	fire(elite.position+Vector3.UP*0.72,elite)
	assert(game.kaka_hook_phase=="attached" and game.grapple.anchor_body==elite)
	assert(elite.position.distance_to(original)<0.01)
	assert(game.grapple.heavy(game,elite))
	game._clear_kaka_hook_projectile()
	# Foreground geometry must win over a target beyond it.
	var blocker := surface(Vector3(0,51,397),Vector3(5,5,0.4))
	await physics_frame
	fire(elite.position+Vector3.UP*0.72,elite)
	assert(game.grapple.anchor_body==blocker)
	assert(elite.position.distance_to(original)<0.01)
	game._clear_kaka_hook_projectile()
	game.mouth_intro.begin()
	var training: Node3D=game.mouth_intro.training
	assert(training.stations.size()==6 and training.pickups.size()==4)
	game.player.position=training.pickups[0].node.global_position+Vector3(0,0,1)
	assert(training.take(0))
	assert(not training.take(0))
	assert(training.pockets.medkit==1)
	assert(not training.use_supply("medkit"))
	game.hp=50.0
	assert(training.use_supply("medkit") and game.hp==85.0)
	game.player.position=training.pickups[1].node.global_position+Vector3(0,0,1)
	assert(training.take(1))
	game.inventory_ui.open_inventory()
	assert(game.inventory_ui.supply_text.text.contains("血浆汽水 1"))
	game.inventory_ui._use_training_supply("soda")
	assert(game.plasma_soda_time==16.0 and training.pockets.soda==0)
	game.inventory_ui.close_inventory()
	game.mouth_intro.finish()
	assert(game.mission_phase=="diagnose" and not training.prompt.visible)
	game.mission_phase="return"
	game._begin_host_boss()
	game.first_person=true
	game.camera_1p.current=true
	game.camera_3p.current=false
	game.player.position=game.host_boss.target.position+Vector3(0,0,12)
	var boss_start: Vector3=game.host_boss.target.position
	fire(game.grapple.hit_center(game,game.host_boss.target),game.host_boss.target)
	assert(game.kaka_hook_phase=="attached" and game.grapple.anchor_body==game.host_boss.target)
	assert(game.host_boss.target.position.distance_to(boss_start)<0.01)
	print("GODOT_PHASE35_OK muzzle=right_hand surfaces=wall+ground+ceiling elite+boss=self_pull occlusion=blocked swing=momentum supplies=pickup+use+no_duplicate mouth=exit")
	game.queue_free()
	await process_frame
	quit()
