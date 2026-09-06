extends SceneTree
var game
var clinic
func release_f() -> void:
	game.interact_down = false
	game._update_mission(0.01)
func press_f(delta := 0.01) -> void:
	game.interact_down = true
	game._update_mission(delta)
func scan(index: int) -> void:
	game.player.position = clinic.sites[index].root.global_position+Vector3(0,0,3.0)
	release_f()
	press_f(0.3)
	assert(clinic.sites[index].stage=="scan")
	press_f(0.3)
	assert(clinic.sites[index].stage=="clean","Spark diagnosis did not enter cleaning")
	release_f()
func clean_site(index: int) -> void:
	for cell in clinic.sites[index].cells:
		clinic.clean_at(index,cell.mesh.global_position,0.2,2.0)
	assert(clinic.sites[index].stage=="care")
	var before: int = game.credits
	clinic.clean_at(index,clinic.sites[index].root.global_position,20,20)
	assert(game.credits==before,"Already-clean tissue farms money")
func reel_catch() -> void:
	clinic._tick_fishing(clinic.fish_bite_delay+0.01)
	assert(clinic.fish_state=="reel")
	for i in range(3):
		clinic.fish_clock = 0.5/0.65
		assert(clinic.fish_press())
	assert(clinic.fish_site==-1)
func walk_to(destination: Vector3) -> void:
	for i in range(240):
		await physics_frame
		var offset: Vector3 = destination-game.player.position
		offset.y = 0
		if offset.length()<0.25: return
		var vy: float = -2.0 if game.player.is_on_floor() else game.player.velocity.y-22.0/60.0
		game.player.velocity = offset.normalized()*5.8*clinic.movement_multiplier()
		game.player.velocity.y = vy
		game.player.move_and_slide()
		assert(game.player.position.y>-0.5,"Fell through care route")
	assert(false,"Cargo route blocked")
func _init() -> void:
	create_timer(55).timeout.connect(func():printerr("PHASE27_TIMEOUT");quit(1))
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await physics_frame
	game._select_role(0,false)
	game.set_process(false)
	game.set_physics_process(false)
	game.story_label.visible = false
	clinic = game.clinic_system
	clinic.set_process(false)
	assert(game.world_scale==5 and clinic.enabled and clinic.sites.size()==3)
	assert(clinic.fishing_spots.size()==2 and clinic.levels==[0,0,0,0])
	assert(clinic.spray.visible==false)
	# Scene geometry: every working area is close to an actual walkable floor.
	for point in [clinic.sites[0].root,clinic.sites[1].root,clinic.sites[2].root,clinic.fishing_spots[0].root,clinic.fishing_spots[1].root,clinic.recycle,clinic.upgrade]:
		var pos: Vector3 = point.global_position
		var query := PhysicsRayQueryParameters3D.create(pos+Vector3.UP*0.8,pos-Vector3.UP*2.0,1,[game.player.get_rid()])
		var hit: Dictionary = game.get_world_3d().direct_space_state.intersect_ray(query)
		assert(not hit.is_empty(),"Clinic has no floor: "+str(pos))
		assert(absf(hit.position.y-pos.y)<0.6,"Clinic floating/buried: "+str(pos)+" ground="+str(hit.position))
	# Real F dispatch, no conflict with existing clues; clean money granted once.
	scan(0)
	var before: int = game.credits
	clean_site(0)
	assert(game.credits==before+20 and clinic.clean_cells==20)
	game._set_role(1)
	release_f()
	press_f()
	assert(clinic.cargo_site==0 and is_equal_approx(clinic.movement_multiplier(),1.0))
	game._set_role(3)
	assert(is_equal_approx(clinic.movement_multiplier(),0.65))
	assert(not clinic.dispose_cargo(),"Cargo disposed remotely")
	game.game_paused = true
	var clock_before: float = clinic.clock
	clinic._process(2.0)
	assert(clinic.clock==clock_before and clinic.cargo_site==0,"Pause lost cargo/ticked work")
	game.game_paused = false
	game.ko_time = 0.5
	clinic._process(0.1)
	assert(clinic.cargo_site==-1 and clinic.sites[0].package.visible,"KO deleted quest cargo")
	game.ko_time = 0
	assert(clinic.pickup_cargo(0))
	await walk_to(clinic.sites[0].bin.global_position+Vector3(0,0,1.4))
	game.hp = 42
	release_f()
	press_f()
	assert(clinic.completed==1 and clinic.sites[0].stage=="healthy" and game.hp==67)
	before = game.credits
	clinic.complete_site(0)
	assert(game.credits==before,"Repeated rescue reward")
	# Bubble washes a local area, not the whole room, and roll/splash share dirt state.
	game._set_role(0)
	scan(1)
	game._set_role(2)
	game.yaw = 0
	game.player.rotation.y = 0
	clinic.wash(1,0.8)
	assert(clinic.clean_fraction(1)>0 and clinic.clean_fraction(1)<1)
	var washed: float = clinic.clean_fraction(1)
	game.player.position = clinic.sites[1].root.global_position
	game.bubble_roll_time = 0.3
	clinic._process(0.2)
	assert(clinic.clean_fraction(1)>washed,"Bubble rolling did not clean")
	game.bubble_roll_time = 0
	clean_site(1)
	game._set_role(3)
	var expert_window: Vector2 = clinic.care_window(1)
	game._set_role(0)
	var novice_window: Vector2 = clinic.care_window(1)
	assert(expert_window.y-expert_window.x>novice_window.y-novice_window.x)
	game._set_role(3)
	clinic.clock = 0
	assert(not clinic.care_press(1) and clinic.sites[1].hits==0)
	for i in range(3):
		clinic.clock = (float(i)+0.5)/0.58
		release_f()
		press_f()
		assert(clinic.sites[1].hits==i+1)
		if i<2: assert(not clinic.care_press(1),"One pulse can be spammed for all treatment")
	assert(clinic.completed==2 and clinic.sites[1].stage=="healthy")
	game._set_role(0)
	scan(2)
	clean_site(2)
	for i in range(3):
		clinic.clock = (i+4.5)/0.58
		assert(clinic.care_press(2))
	assert(clinic.completed==3 and clinic.clean_cells==60)
	game.acid_next = 0
	game.spasm_next = 0
	game._update_living_events(0)
	assert(game.acid_next==27 and game.spasm_next==21,"Treatment has no body consequence")
	# Fishing charges bait once, requires distinct timing cycles, cancels safely.
	game.player.position = clinic.fishing_spots[0].root.global_position+Vector3(0,0,1.4)
	before = game.credits
	release_f()
	press_f()
	assert(clinic.fish_state=="waiting" and game.credits==before-3)
	assert("剩余 5 次" in clinic.fishing_spots[0].root.get_meta("label").text)
	game.acid_mesh.position.y = 0.6
	clinic._tick_fishing(0.01)
	assert(clinic.fishing_spots[0].bobber.position.y>0.6,"Bobber sank below rising acid")
	press_f()
	assert(game.credits==before-3 and clinic.fishing_spots[0].left==5,"Holding F bought multiple casts")
	game.game_paused = true
	clock_before = clinic.fish_clock
	clinic._process(2.0)
	assert(clinic.fish_clock==clock_before and clinic.fish_site==0)
	game.game_paused = false
	reel_catch()
	assert(clinic.bag.size()==1 and clinic.bag_value()>0)
	assert(not clinic.fish_press() and clinic.bag.size()==1)
	assert(clinic.start_fishing(0))
	clinic._tick_fishing(3.0)
	clinic.fish_clock = 0.5/0.65
	assert(clinic.fish_press())
	assert(not clinic.fish_press() and clinic.fish_hits==1,"Spam reels all treasure")
	game.player.position += Vector3(8,0,0)
	clinic._tick_fishing(0.1)
	assert(clinic.fish_site==-1 and clinic.bag.size()==1)
	# Atomic sale ignores the story mouse. Existing shops still own their F actions.
	assert(clinic.sell_bag()==0,"Sold without visiting counter")
	game.player.position = clinic.recycle.global_position+Vector3(0,0,1.2)
	var value: int = clinic.bag_value()
	before = game.credits
	release_f()
	press_f()
	assert(game.credits==before+value and clinic.bag.is_empty() and clinic.sold_value==value)
	press_f()
	assert(game.credits==before+value)
	assert(clinic.sell_bag()==0)
	game.player.position = clinic.fishing_spots[0].root.global_position
	for i in range(8): clinic.bag.append(clinic.LOOT[0].duplicate())
	before = game.credits
	assert(not clinic.start_fishing(0) and game.credits==before,"Full bag consumed bait")
	clinic.bag.clear()
	game.credits = 2
	assert(not clinic.start_fishing(0) and game.credits==2)
	game.credits = 1000
	while clinic.fishing_spots[0].left>0:
		assert(clinic.start_fishing(0))
		clinic._cancel_fishing()
	assert(not clinic.start_fishing(0),"Infinite fishing stock")
	# Four separate upgrade tracks; no spending/cooldown reset exploit.
	game.player.position = clinic.upgrade.global_position+Vector3(0,0,1.2)
	for role in range(4):
		game._set_role(role)
		game.credits = 39
		assert(not clinic.buy_upgrade() and clinic.levels[role]==0)
		game.credits = 300
		game.skill_q_cd = 4
		for tier in range(3):
			before = game.credits
			assert(clinic.buy_upgrade())
			assert(game.credits==before-clinic.COSTS[tier] and game.role_upgrade_level()==tier+1)
		assert(game.skill_q_cd==4,"Upgrade reset active cooldown")
		before = game.credits
		assert(not clinic.buy_upgrade() and game.credits==before)
		assert(game.character_visual.has_node("ClinicKit"))
	assert(clinic.levels==[3,3,3,3])
	game._set_role(1)
	game.primary_hold = true
	game._tick_phase11(1.8)
	assert(game.kaka_charge_nails==13,"Bone volley upgrade is cosmetic")
	game.primary_hold = false
	game._cancel_phase11_holds()
	game._set_role(0)
	game.player.position = game.world_point(Vector3(0,0.5,-1.8))
	var origin: Vector3 = game.player.position
	game._spark_lightning_form()
	assert(game.player.position.distance_to(origin)>8.5,"Upgraded lightning movement unchanged")
	game.acid_next = 100
	game.spasm_next = 100
	game.drink_next = 100
	game.skill_q_cd = 4.0
	game._physics_process(0.1)
	assert(game.skill_q_cd<3.87,"Purchased cooldown enhancement not applied")
	# Verify the other upgrade effects against real actors, not just UI levels.
	game.player.position = Vector3(0,0.4,-12)
	game.yaw = 0
	game.player.rotation.y = 0
	game._spawn_enemy("HAIRBALL",game.player.position+Vector3(0,0,-3),Color.WHITE,500,0)
	var training_a: CharacterBody3D = game.enemies[-1]
	game._spawn_enemy("PLATELET",game.player.position+Vector3(2,0,-4),Color.WHITE,500,0)
	var training_b: CharacterBody3D = game.enemies[-1]
	game._clear_spark_mark()
	game.primary_attack_cd = 0
	clinic.levels[0] = 0
	game._spark_arc_shot()
	assert(float(training_b.get_meta("hp"))==500)
	clinic.levels[0] = 3
	game.primary_attack_cd = 0
	game._spark_arc_shot()
	assert(float(training_b.get_meta("hp"))<500,"Permanent electric chain upgrade failed")
	game._set_role(3)
	game._shroom_puppet_thread()
	assert(float(training_a.get_meta("controlled"))>8.0,"Puppet duration upgrade failed")
	game.hp = 60
	game._spawn_fungus_patch()
	game._tick_zones(0.25)
	assert(game.hp>62.7,"Healing upgrade not applied to fungus field")
	game._set_role(2)
	training_b.position = game.player.position+Vector3(4.7,0,0)
	var target_hp: float = training_b.get_meta("hp")
	clinic.levels[2] = 0
	game.bubble_jump_charge = 1.0
	game._bubble_land()
	assert(float(training_b.get_meta("hp"))==target_hp)
	clinic.levels[2] = 3
	game.bubble_jump_charge = 1.0
	game._bubble_land()
	assert(float(training_b.get_meta("hp"))<target_hp,"Upgraded splash outside old radius did no damage")
	for target in [training_a,training_b]:
		game.enemies.erase(target)
		target.queue_free()
	var snapshot: Dictionary = game.NetworkState.snapshot(game)
	var parsed: Dictionary = JSON.parse_string(JSON.stringify(snapshot))
	assert(game.NetworkState.validate(parsed) and parsed.clinic.completed==3 and parsed.clinic.levels.size()==4)
	game.tactical_map.refresh = 0
	game.tactical_map.tick(0)
	for dot in game.tactical_map.dots: assert(dot.kind!="care","Healed patient remains a pending marker")
	game.player.position = game.shop_pads[0].global_position
	clinic.handle_interaction(0.01,false)
	assert(not clinic.handle_interaction(0.01,false),"Clinic hijacks original shop")
	# A fully treated, upgraded run must still reach the original emotional ending.
	game._set_role(0)
	game.skill_q_cd = 0
	game._clear_spark_mark()
	for i in range(3):
		game.player.position = game.clue_nodes[i].global_position
		release_f()
		press_f(0.5)
		release_f()
	assert(game._clue_count()==3 and game.mission_phase=="chase")
	# A controlled story target inside a patient area must keep capture priority.
	game.mouse_target.global_position = clinic.sites[1].root.global_position
	game.player.position = game.mouse_target.global_position+Vector3(0,0,1.4)
	game.yaw = 0
	game._skill_spark(0)
	press_f(0.8)
	release_f()
	assert(game.mouse_caught and game.mission_phase=="return")
	game.player.position = game.entrance.global_position
	press_f(0.6)
	release_f()
	assert(game.mission_phase=="escape")
	clinic._process(0.01)
	assert(not clinic.visible,"Clinic leaked into cinematic")
	for step in range(86): game.escape_finale.tick(0.1)
	assert(game.mission_phase=="host_boss")
	game.host_boss.tick(3.3)
	preload("res://tests/host_boss_test_helper.gd").finish(game)
	assert(game.mission_phase=="win" and "治愈 3/3" in game.win_label.text)
	game.queue_free()
	await process_frame
	var fresh = load("res://scenes/main.tscn").instantiate()
	root.add_child(fresh)
	await process_frame
	assert(fresh.credits==30 and fresh.clinic_system.levels==[0,0,0,0] and fresh.clinic_system.completed==0 and fresh.clinic_system.bag.is_empty(),"Round economy leaked through replay")
	print("GODOT_PHASE27_CLINIC_SALVAGE_OK care=3 cleaned=60 cargo=ko_safe fishing=timed finite=true selling=atomic roles=4 upgrades=3x4 snapshot=json floor=verified")
	print("GODOT_PHASE27_TREATED_FULL_ROUND_OK ending=win replay=reset upgraded_skills=actual_hits cargo_route=walked")
	quit(0)
