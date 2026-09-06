extends SceneTree

func _init() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.role_selected = true
	game.role_panel.visible = false
	assert(game.shop_root != null)
	assert(game.shop_pads.size() == 4)
	assert(game.credits == 30)
	var money: int = game.credits
	game._complete_clue(0)
	assert(game.credits == money + 12)
	game.credits = 100
	assert(game._buy_item(0))
	assert(game.credits == 76 and game.acid_umbrella_time > 0.0)
	game._tick_fun_items(0.0)
	assert(game.character_visual.get_node_or_null("AcidUmbrella") != null)
	game.hp = 100.0
	game.player.position = Vector3(0,0.45,4.0)
	game.acid_tide_time = 2.0
	game._update_living_events(1.0)
	assert(game.hp > 97.0)
	game.credits = 100
	assert(game._buy_item(1))
	game.skill_q_cd = 5.0
	game.skill_e_cd = 5.0
	for e in game.enemies: e.set_meta("dead", true)
	game._physics_process(1.0)
	assert(game.skill_q_cd < 3.6 and game.skill_e_cd < 3.6)
	game.credits = 100
	assert(game._buy_item(2))
	assert(is_instance_valid(game.catnip_beacon))
	var lure = game.enemies[0]
	lure.set_meta("dead", false)
	lure.set_meta("attack_cd", 10.0)
	lure.position = Vector3.ZERO
	game.player.position = Vector3(-5,1.15,0)
	game.catnip_beacon.global_position = Vector3(5,0.2,0)
	game._tick_enemies(0.1)
	assert(lure.velocity.x > 0.0)
	game.credits = 100
	assert(game._buy_item(3))
	assert(game.purchases >= 4)
	var near_pad: Node3D = game.shop_pads[0]
	game.player.global_position = near_pad.global_position
	assert(game._nearest_shop_item() == 0)
	game.clue_done = [true,true,true]
	game.mission_phase = "diagnose"
	game.credits = 100
	var bought_before: int = game.purchases
	game.interact_down = true
	game._update_mission(0.4)
	game._update_mission(0.4)
	assert(game.credits == 76 and game.purchases == bought_before + 1)
	assert(game.interact_requires_release)
	game.interact_down = false
	game._update_mission(0.01)
	assert(not game.interact_requires_release)
	var bounty = game.enemies[1]
	bounty.set_meta("dead", false)
	bounty.set_meta("hp", 1.0)
	bounty.set_meta("combo_role", -1)
	bounty.set_meta("combo_t", 0.0)
	game.role_index = 0
	var before_bounty: int = game.credits
	game._damage_enemy(bounty, 5.0)
	assert(game.credits == before_bounty + 6)
	var combo_enemy = game.enemies[2]
	combo_enemy.set_meta("dead", false)
	combo_enemy.set_meta("hp", 80.0)
	combo_enemy.set_meta("combo_role", 1)
	combo_enemy.set_meta("combo_t", 1.0)
	combo_enemy.set_meta("combo_count", 1)
	var before_sync: int = game.credits
	game._damage_enemy(combo_enemy, 1.0)
	assert(game.credits == before_sync + 4)
	game.mission_phase = "return"
	var before_win: int = game.credits
	preload("res://tests/host_boss_test_helper.gd").finish(game)
	assert(game.credits == before_win + 20)
	assert(game.win_label.text.find("Purchases") >= 0)
	var snap: Dictionary = game.build_network_snapshot()
	assert(snap.has("economy"))
	assert(int(snap["economy"]["credits"]) == game.credits)
	assert(float(snap["economy"]["soda"]) >= 0.0)
	print("GODOT_PHASE8_ECONOMY_OK credits=",game.credits," purchases=",game.purchases)
	quit(0)
