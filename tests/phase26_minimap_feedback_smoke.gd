extends SceneTree
func _init() -> void:
	create_timer(40).timeout.connect(func():printerr("PHASE26_TIMEOUT");quit(1))
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0)
	game.set_process(false)
	game.set_physics_process(false)
	var map = game.tactical_map
	var feedback = game.impact_feedback
	map.refresh = 0.0
	map.tick(0.0)
	assert(map.stage == "mouth" and map.dots.size() == 1,"Mouth radar leaks other organs")
	game.mouth_intro.finish()
	map.refresh = 0.0
	map.tick(0.0)
	assert(map.stage == "body")
	var reds := 0
	for dot in map.dots:
		if dot.kind == "enemy": reds += 1
	assert(reds == game.enemies.size())
	var west: Vector2 = map.project_point(Vector3(-100,0,0))
	var east: Vector2 = map.project_point(Vector3(100,0,0))
	assert(west.x < east.x and map.map_rect.has_point(west))
	var target = game.enemies[0]
	target.set_meta("controlled",3.0)
	map.refresh = 0.0
	map.tick(0.0)
	var allies := 0
	for dot in map.dots:
		if dot.kind == "ally": allies += 1
	assert(allies == 1)
	feedback.tick(0.0)
	var before: int = feedback.hit_events
	game._damage_enemy(target,8.0)
	assert(feedback.hit_events == before+1 and feedback.hit_time > 0.0 and not feedback.kill_hit)
	assert(float(target.get_meta("impact_freeze")) > 0.0)
	feedback.tick(0.01)
	assert(game.camera_3p.v_offset > 0.0)
	feedback.tick(0.5)
	assert(is_zero_approx(game.camera_3p.v_offset))
	before = feedback.hit_events
	game._damage_enemy(target,0.0,0.3)
	assert(feedback.hit_events == before,"Zero-damage control pretends to hit")
	game._damage_enemy(target,9999.0)
	assert(feedback.kill_hit)
	map.refresh = 0.0
	map.tick(0.0)
	reds = 0
	for dot in map.dots:
		if dot.kind == "enemy": reds += 1
	assert(reds == game.enemies.size()-1,"Dead enemy left a red dot")
	game.hp = 80
	feedback.report_hurt(game.player.position+Vector3.LEFT*4)
	assert(feedback.directional and feedback.hurt_time > 0.0)
	var hurt_before: int = feedback.hurt_events
	feedback.tick(0.01)
	assert(feedback.hurt_events == hurt_before,"Hit sound duplicated by health polling")
	game.hp = 75
	feedback.tick(0.01)
	assert(not feedback.directional,"Acid invented an enemy direction")
	for sound in feedback.sounds:
		assert(sound.data.size() > 2000 and sound.mix_rate == 22050)
	assert(map.mouse_filter == Control.MOUSE_FILTER_IGNORE and feedback.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	game.game_paused = true
	map.tick(0.1)
	feedback.tick(0.1)
	assert(not map.visible and not feedback.visible)
	assert(is_zero_approx(game.camera_3p.v_offset))
	game.game_paused = false
	game.mission_phase = "return"
	game._begin_host_boss()
	game.host_boss.state = "recover"
	map.refresh = 0
	map.tick(0)
	assert(map.stage == "boss" and map.dots.size() == 1 and map.dots[0].kind == "boss")
	before = feedback.hit_events
	game.host_boss.apply_hit(10,0,0)
	assert(feedback.hit_events == before+1)
	game.mission_phase = "ending"
	map.tick(0.1)
	feedback.tick(0.1)
	assert(not map.visible and not feedback.visible)
	print("GODOT_PHASE26_MINIMAP_FEEDBACK_OK radar=red_enemies ally=purple stages=isolated hit=confirmed kill=gold hurt=directional audio=generated pause=safe")
	quit(0)
