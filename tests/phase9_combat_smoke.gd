extends SceneTree

func _reset_enemy(enemy: CharacterBody3D, pos: Vector3, hp: float = 100.0) -> void:
	enemy.set_meta("dead", false)
	enemy.set_meta("hp", hp)
	enemy.set_meta("stun", 0.0)
	enemy.set_meta("pinned", 0.0)
	enemy.set_meta("goo_slow", 0.0)
	enemy.set_meta("controlled", 0.0)
	enemy.set_meta("control_attack_cd", 0.0)
	enemy.set_meta("combo_t", 0.0)
	enemy.set_meta("combo_role", -1)
	enemy.global_position = pos
	enemy.velocity = Vector3.ZERO

func _init() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.role_selected = true
	game.role_panel.visible = false
	game.player.global_position = Vector3(0, 1.15, 5.5)
	game.yaw = 0.0
	game.player.rotation.y = 0.0
	var enemy: CharacterBody3D = game.enemies[0]
	_reset_enemy(enemy, Vector3(0, 1.15, 2.4))
	game._set_role(0)
	game.primary_attack_cd = 0.0
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var lmb := InputEventMouseButton.new()
	lmb.button_index = MOUSE_BUTTON_LEFT
	lmb.pressed = true
	game._unhandled_input(lmb)
	assert(float(enemy.get_meta("hp")) < 100.0)
	assert(game.primary_attack_cd > 0.0)
	var after_primary: float = float(enemy.get_meta("hp"))
	game._unhandled_input(lmb)
	assert(float(enemy.get_meta("hp")) == after_primary)
	_reset_enemy(enemy, Vector3(0, 1.15, 2.0))
	game.player.global_position = Vector3(0, 1.15, 5.5)
	game.secondary_attack_cd = 0.0
	var blink_start: Vector3 = game.player.global_position
	var rmb := InputEventMouseButton.new()
	rmb.button_index = MOUSE_BUTTON_RIGHT
	rmb.pressed = true
	game._unhandled_input(rmb)
	var blink_distance: float = game.player.global_position.distance_to(blink_start)
	assert(blink_distance > 5.0)
	assert(float(enemy.get_meta("stun")) >= 0.8)
	assert(game.get_node_or_null("PhaseBlinkVFX") != null)

	game._set_role(1)
	game.player.global_position = Vector3(0, 1.15, 5.5)
	_reset_enemy(enemy, Vector3(0, 1.15, 1.8))
	game.secondary_attack_cd = 0.0
	game._secondary_attack()
	assert(float(enemy.get_meta("pinned")) >= 1.0)
	assert(enemy.velocity.z > 0.0)
	game._set_role(2)
	_reset_enemy(enemy, Vector3(0, 1.15, 2.2))
	game.secondary_attack_cd = 0.0
	game._secondary_attack()
	assert(float(enemy.get_meta("goo_slow")) >= 4.4)

	for other in game.enemies:
		other.set_meta("dead", true)
	var puppet: CharacterBody3D = game.enemies[0]
	var victim: CharacterBody3D = game.enemies[1]
	_reset_enemy(puppet, Vector3(0, 1.15, 0.0))
	_reset_enemy(victim, Vector3(0, 1.15, -1.0))
	game._set_role(3)
	game.player.global_position = Vector3(0, 1.15, 2.8)
	game.secondary_attack_cd = 0.0
	game._secondary_attack()
	assert(float(puppet.get_meta("controlled")) > 4.5)
	var victim_hp: float = float(victim.get_meta("hp"))
	game._tick_enemies(0.2)
	assert(float(victim.get_meta("hp")) < victim_hp)
	assert(game.help_label.text.find("LMB primary") >= 0)
	assert(game.help_label.text.find("F interact") >= 0)
	print("GODOT_PHASE9_COMBAT_OK blink=", blink_distance, " puppet_damage=", victim_hp - float(victim.get_meta("hp")))
	quit(0)
