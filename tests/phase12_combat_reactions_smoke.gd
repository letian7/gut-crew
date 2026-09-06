extends SceneTree

func _reset_enemy(enemy: CharacterBody3D, pos: Vector3, hp: float = 180.0) -> void:
	enemy.set_meta("dead", false)
	enemy.set_meta("hp", hp)
	enemy.set_meta("max_hp", hp)
	enemy.set_meta("stun", 0.0)
	enemy.set_meta("pinned", 0.0)
	enemy.set_meta("goo_slow", 0.0)
	enemy.set_meta("controlled", 0.0)
	enemy.set_meta("control_attack_cd", 0.0)
	enemy.set_meta("spore_stacks", 0)
	enemy.set_meta("bone_pins", 0)
	enemy.set_meta("engulfed", false)
	enemy.set_meta("combo_t", 0.0)
	enemy.set_meta("combo_role", -1)
	enemy.set_meta("combo_count", 0)
	enemy.set_meta("big", 0.0)
	enemy.visible = true
	enemy.collision_layer = 1
	enemy.collision_mask = 1
	enemy.global_position = pos
	enemy.velocity = Vector3.ZERO
func _init() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.role_selected = true
	game.role_panel.visible = false
	game.front_ui["root"].visible = false
	game.player.global_position = Vector3(0, 1.15, 5.5)
	game.yaw = 0.0
	game.player.rotation.y = 0.0
	for enemy in game.enemies:
		enemy.set_meta("dead", true)
	var e0: CharacterBody3D = game.enemies[0]
	var e1: CharacterBody3D = game.enemies[1]

	game._set_role(0)
	_reset_enemy(e0, Vector3(0, 1.15, 2.4))
	_reset_enemy(e1, Vector3(1.4, 1.15, 2.5))
	game.skill_q_cd = 0.0
	game._cast_skill(0)
	assert(game.spark_mark_target == e0)
	var chain_before: float = float(e1.get_meta("hp"))
	game.primary_attack_cd = 0.0
	game._spark_arc_shot()
	var chain_damage: float = chain_before - float(e1.get_meta("hp"))
	assert(chain_damage >= 3.0)
	assert(float(e1.get_meta("stun")) >= 0.1)
	assert(game.combat_flow >= 2)
	assert(game.hit_confirm_time > 0.0)
	game._update_target_ui()
	assert(game.crosshair.text == "X")

	game._set_role(1)
	game.player.global_position = Vector3(0, 1.15, 5.5)
	_reset_enemy(e0, Vector3(0, 1.15, 4.45))
	e0.set_meta("bone_pins", 3)
	for i in range(3):
		var nail := Node3D.new()
		nail.set_meta("stuck", true)
		nail.set_meta("stuck_enemy", e0)
		game.add_child(nail)
		game.bone_projectiles.append(nail)
	var shatter_before: float = float(e0.get_meta("hp"))
	game._start_kaka_charge()
	game._tick_kaka_rush_contacts()
	var shatter_damage: float = shatter_before - float(e0.get_meta("hp"))
	assert(shatter_damage >= 51.0)
	assert(int(e0.get_meta("bone_pins")) == 0)
	assert(game.get_node_or_null("BoneShatterVFX") != null)
	game._set_role(2)
	game.player.global_position = Vector3(0, 1.15, 5.5)
	_reset_enemy(e0, Vector3(0, 1.15, 2.9))
	_reset_enemy(e1, Vector3(1.1, 1.15, 3.0))
	game._spawn_bubble_decoy()
	game.bubble_roll_power = 1.0
	game.bubble_roll_time = 1.0
	game._tick_bubble_roll_contacts()
	assert(bool(game.bubble_decoy.get_meta("roll_kicked", false)))
	var decoy_body := game.bubble_decoy as RigidBody3D
	decoy_body.global_position = e0.global_position
	decoy_body.linear_velocity = Vector3(0, 0, -8.0)
	var pinball_before: float = float(e0.get_meta("hp"))
	game._tick_bubble_decoy_impact()
	assert(game.bubble_decoy == null)
	assert(float(e0.get_meta("hp")) < pinball_before)
	assert(float(e1.get_meta("goo_slow")) >= 3.4)

	game._set_role(3)
	_reset_enemy(e0, Vector3(0, 1.15, 3.0))
	_reset_enemy(e1, Vector3(0.8, 1.15, 3.0))
	e0.set_meta("controlled", 6.0)
	e0.set_meta("big", 4.0)
	e0.set_meta("control_attack_cd", 0.0)
	var overdrive_before: float = float(e1.get_meta("hp"))
	game._tick_enemies(0.05)
	var overdrive_damage: float = overdrive_before - float(e1.get_meta("hp"))
	assert(overdrive_damage >= 17.0)
	assert(float(e0.get_meta("control_attack_cd")) <= 0.68)
	assert(game.get_node_or_null("SporeBloomVFX") != null)

	game._update_hud()
	assert(game.status_label.text.find("FLOW x") >= 0)
	assert(game.hit_confirm_damage > 0)
	print("GODOT_PHASE12_REACTIONS_OK chain=", chain_damage, " shatter=", shatter_damage, " overdrive=", overdrive_damage, " flow=", game.combat_flow)
	quit(0)
