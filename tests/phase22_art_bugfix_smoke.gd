extends SceneTree
const Boss = preload("res://scripts/host_boss.gd")
func _init() -> void:
	create_timer(30.0).timeout.connect(func():printerr("PHASE22_TIMEOUT");quit(1))
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0)
	game.set_process(false)
	game.set_physics_process(false)
	assert(game.mouth_intro.get_meta("art_revision") == 22)
	assert(game.vertical_stomach.get_meta("art_revision") == 22)
	var teeth := 0
	for node in game.mouth_intro.get_children():
		if node.get_meta("sculpted_tooth",false): teeth += 1
	assert(teeth == 28)
	assert(game.mouth_intro.has_node("SculptedPalateFolds"))
	# Full capsule must remain under the ellipse, even near the narrow upper wall.
	for z in [34.0,45.0,51.0,63.0]:
		for x in [-10.0,0.0,10.0]:
			var p: Vector3 = game.mouth_intro.constrain(Vector3(x,100,z))
			var width: float = lerpf(2.7,3.1,(z-33)/17) if z < 50 else lerpf(3.1,6.0,(z-50)/18)
			var height: float = 5.7 if z < 50 else lerpf(5.7,9.0,(z-50)/18)
			var crown: float = game.mouth_intro.floor_y(z)+height*sqrt(1.0-pow((absf(p.x)+0.32)/width,2))
			assert(p.y+1.5 < crown)
	var grounded := Vector3(0,game.mouth_intro.floor_y(60)+0.16,60)
	assert(game.mouth_intro.constrain(grounded).is_equal_approx(grounded))
	game._story_beat("PRESERVE_STORY",5.0,3)
	for role in [1,2,3,0]:
		game._select_role(role)
		assert(game.story_label.text == "PRESERVE_STORY" and game.story_chapter == 3)
	game.game_paused = true
	game._tick_story(2.0)
	assert(game.story_time == 5.0)
	game.game_paused = false
	game._tick_story(0.5)
	assert(game.story_time == 4.5)
	game.mouth_intro.finish()
	game.mission_phase = "return"
	game._begin_host_boss()
	var boss = game.host_boss
	assert(boss.cat_head.has_node("MoodBrows22"))
	game.player.position = Boss.ORIGIN+Vector3(4,0.75,4)
	boss.attack_index = 0
	boss._begin_attack()
	boss._resolve_attack()
	assert(Vector2(boss.paw_right.global_position.x-boss.attack_pos.x,boss.paw_right.global_position.z-boss.attack_pos.z).length()<0.02)
	boss.attack_index = 2
	boss._begin_attack()
	boss._resolve_attack()
	for step in range(5):
		boss.tick(0.1)
		assert(is_equal_approx(boss.marker.mesh.outer_radius,boss.wave_radius+0.9))
		assert(is_equal_approx(boss.marker.mesh.inner_radius,maxf(0.02,boss.wave_radius-0.9)))
	game.interact_label.text = "STALE_TOY_PROMPT"
	preload("res://tests/host_boss_test_helper.gd").finish(game)
	assert(game.interact_label.text == "" and not game.capture_bar.visible)
	assert(not boss.mood_brows.visible)
	print("GODOT_PHASE22_ART_BUGFIX_OK teeth=28 arched_boundary=12 story=preserved wave=matched paw=matched ending=clean")
	quit(0)
