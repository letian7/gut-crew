extends RefCounted

static func finish(game) -> void:
	if game.mission_phase == "return":
		game._begin_host_boss()
	assert(game.mission_phase == "host_boss")
	assert(is_instance_valid(game.host_boss.cat))
	game.host_boss.state = "recover"
	game._damage_enemy(game.host_boss.target, 10000.0)
	assert(game.mission_phase == "ending")
	assert(not game.win_panel.visible)
	for page in range(4):
		assert(game.host_boss.story_index == page)
		game.host_boss.story_elapsed = 1.1
		game.host_boss.advance_story()
	assert(game.mission_phase == "win")
	assert(game.host_boss.rescued)
