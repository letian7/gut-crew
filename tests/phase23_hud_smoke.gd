extends SceneTree
func _init() -> void:
	create_timer(30.0).timeout.connect(func():printerr("PHASE23_TIMEOUT");quit(1))
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0)
	game.set_process(false)
	game.set_physics_process(false)
	var hud = game.combat_hud
	hud.set_process(false)
	hud.tick(0)
	assert(hud.root_ui.visible and hud.health.value == 100)
	assert(game.status_label.modulate.a == 0)
	assert(not game.terrain_world.visible and not game.vertical_stomach.visible)
	assert(game.player.visible)
	assert(game.vertical_stomach.get_node("AcidOverpassFleshUnderside/CameraHull").collision_layer == 2)
	assert((game.player.collision_mask & 2) == 0)
	game.hp = 72
	hud.tick(0.016)
	assert(hud.health.value == 72 and hud.trail.value == 100)
	assert(hud.hit_time > 0 and hud.change_label.text == "−28")
	hud.tick(0.2)
	assert(hud.trail.value == 100)
	hud.tick(0.4)
	assert(hud.trail.value < 100 and hud.trail.value >= 72)
	hud.tick(1.0)
	assert(hud.trail.value == 72)
	game.hp = 80
	hud.tick(0.016)
	assert(hud.change_label.text == "+8" and hud.trail.value == 80)
	game.hp = 25
	game.acid_umbrella_time = 4.5
	game.plasma_soda_time = 2.3
	game.invuln = 1.1
	game.spark_mark_time = 2.0
	hud.tick(0.016)
	assert("危险" in hud.warning.text and hud.edge_panels[0].color.a > 0)
	assert("抗酸 4.5s" in hud.statuses.text and "无敌 1.1s" in hud.statuses.text)
	assert(hud.skills[2].state.text == "再按 Q 瞬移")
	game._set_role(1)
	game.primary_hold = true
	game.kaka_charge_nails = 4
	game.kaka_charge_time = 1.2
	hud.tick(0)
	assert(hud.skills[0].state.text == "蓄力 ×4")
	game.hp = 0
	game.ko_time = 0.6
	hud.tick(0.01)
	assert(hud.health.value == 0 and hud.revive.visible and "倒地" in hud.warning.text)
	assert(hud.skills[0].state.text == "重捏中")
	var hit: float = hud.hit_time
	game.game_paused = true
	hud.tick(1.0)
	assert(not hud.root_ui.visible and hud.hit_time == hit)
	game.game_paused = false
	game.mission_phase = "escape"
	hud.tick(0)
	assert(not hud.root_ui.visible)
	game.hp = 100
	game.ko_time = 0
	game.mouth_intro.finish()
	assert(game.terrain_world.visible and game.vertical_stomach.visible)
	game.player.position = Vector3(0,0.2,5.5)
	game.yaw = 0
	game.player.rotation.y = 0
	for enemy in game.enemies: enemy.visible = false
	game._spawn_enemy("HAIRBALL",Vector3(0,0.35,0),Color.WHITE,100.0,0.0)
	var target = game.enemies[-1]
	target.set_meta("hp",40.0)
	target.set_meta("controlled",2.5)
	await physics_frame
	await process_frame
	hud.tick(0.016)
	var found := false
	for card in hud.enemy_cards:
		if card.panel.visible and card.id == target.get_instance_id():
			assert(card.bar.value == 40 and "操控" in card.status.text)
			found = true
	assert(found,"Projected enemy health bar missing")
	assert(hud.enemy_cards[0].bar.size.y <= 8 and hud.revive.size.y <= 8)
	assert(hud.skills[0].bar.size.y <= 8)
	assert(target.get_meta("hp_label").modulate.a == 0)
	for control in hud.root_ui.find_children("*","Control",true,false):
		assert(control.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	game.mission_phase = "ending"
	hud.tick(0)
	assert(not hud.root_ui.visible)
	print("GODOT_PHASE23_HUD_OK health=trail hit=feedback heal=green states=timed ko=visible enemy=projected input=pass_through mouth=cull_restore")
	quit(0)
