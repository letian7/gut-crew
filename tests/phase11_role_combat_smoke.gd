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
	enemy.set_meta("engulfed", false)
	enemy.set_meta("combo_t", 0.0)
	enemy.set_meta("combo_role", -1)
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
	game.primary_attack_cd = 0.0
	game._primary_pressed()
	game.primary_attack_cd = 0.0
	game._tick_phase11(0.18)
	game._primary_released()
	assert(float(e0.get_meta("hp")) <= 170.0)
	assert(game.get_node_or_null("ArcStreamVFX") != null)

	_reset_enemy(e0, Vector3(0, 1.15, 1.5))
	game.player.global_position = Vector3(0, 1.15, 5.5)
	game.secondary_attack_cd = 0.0
	var dash_start: Vector3 = game.player.global_position
	game._secondary_attack()
	var dash_distance: float = game.player.global_position.distance_to(dash_start)
	assert(dash_distance > 6.5)
	assert(float(e0.get_meta("hp")) < 180.0)

	game.player.global_position = Vector3(0, 1.15, 5.5)
	_reset_enemy(e0, Vector3(0, 1.15, 1.8))
	game.skill_q_cd = 0.0
	game._cast_skill(0)
	assert(game.spark_mark_target == e0)
	assert(game.spark_mark_time > 8.5)
	e0.global_position = Vector3(3.0, 1.15, 0.5)
	game._cast_skill(0)
	assert(game.player.global_position.distance_to(e0.global_position) < 1.5)
	assert(game.skill_q_cd > 4.5)
	game.player.global_position = Vector3(0, 1.15, 5.5)
	_reset_enemy(e0, Vector3(0, 1.15, 3.5))
	_reset_enemy(e1, Vector3(1.4, 1.15, 4.1))
	game.skill_e_cd = 0.0
	game._cast_skill(1)
	assert(float(e0.get_meta("stun")) >= 2.1)
	assert(float(e1.get_meta("stun")) >= 2.1)
	assert(game.get_node_or_null("NeuralStormVFX") != null)

	game._set_role(1)
	game.player.global_position = Vector3(0, 1.15, 5.5)
	_reset_enemy(e0, Vector3(0, 1.15, 2.9))
	game.primary_attack_cd = 0.0
	game._primary_pressed()
	game._tick_phase11(1.30)
	assert(game.kaka_charge_nails == 5)
	game._primary_released()
	assert(game.bone_projectiles.size() >= 6)
	for i in range(8):
		game._tick_bone_projectiles(0.05)
	assert(float(e0.get_meta("hp")) < 180.0)
	assert(float(e0.get_meta("pinned")) >= 1.3)

	var ally := CharacterBody3D.new()
	ally.add_to_group("crew_allies")
	game.add_child(ally)
	ally.global_position = game.player.global_position + game._forward() * 1.0
	game.skill_e_cd = 0.0
	game._cast_skill(1)
	game._tick_kaka_rush_contacts()
	assert(ally.velocity.length() > 10.0)
	game._set_role(2)
	game.player.global_position = Vector3(0, 1.15, 5.5)
	_reset_enemy(e0, Vector3(0, 1.15, 4.4))
	game.primary_attack_cd = 0.0
	game._primary_pressed()
	game._tick_phase11(1.20)
	assert(game.bubble_roll_charge > 0.7)
	game._primary_released()
	assert(game.bubble_roll_time > 1.3)
	game._tick_bubble_roll_contacts()
	assert(float(e0.get_meta("hp")) < 180.0)

	_reset_enemy(e0, Vector3(0, 1.15, 3.4))
	game.secondary_attack_cd = 0.0
	game._secondary_pressed()
	game._tick_phase11(1.0)
	game._secondary_released()
	assert(game.bubble_airborne)
	assert(game.player.velocity.y > 10.0)
	game.player.global_position = Vector3(0, 1.15, 3.8)
	game._bubble_land()
	assert(float(e0.get_meta("hp")) < 180.0)
	assert(float(e0.get_meta("goo_slow")) >= 4.4)

	game.skill_q_cd = 0.0
	game._cast_skill(0)
	assert(is_instance_valid(game.bubble_decoy))
	assert(game.bubble_decoy_time > 7.5)
	_reset_enemy(e0, Vector3(0, 1.15, 2.5))
	game.skill_e_cd = 0.0
	game._cast_skill(1)
	assert(game.bubble_payload == e0)
	assert(bool(e0.get_meta("engulfed")))
	game._cast_skill(1)
	assert(game.bubble_payload == null)
	assert(not bool(e0.get_meta("engulfed")))
	assert(game.skill_e_cd > 5.5)

	game._set_role(3)
	game.player.global_position = Vector3(0, 1.15, 5.5)
	_reset_enemy(e0, Vector3(0, 1.15, 2.8))
	_reset_enemy(e1, Vector3(1.0, 1.15, 2.4))
	for i in range(3):
		game.primary_attack_cd = 0.0
		game._shroom_spore_shot()
	assert(int(e0.get_meta("spore_stacks")) == 0)
	assert(float(e1.get_meta("hp")) < 180.0)

	game.secondary_attack_cd = 0.0
	game._shroom_puppet_thread()
	assert(float(e0.get_meta("controlled")) > 5.5)
	var corpse: CharacterBody3D = game.register_clay_corpse(1, Vector3(0, 1.15, 4.0))
	game.secondary_attack_cd = 0.0
	game._shroom_puppet_thread()
	assert(float(corpse.get_meta("puppet_time")) > 5.5)
	var victim_hp: float = float(e1.get_meta("hp"))
	corpse.global_position = e1.global_position + Vector3(0, 0, 1.0)
	corpse.set_meta("attack_cd", 0.0)
	game._tick_clay_puppets(0.1)
	assert(float(e1.get_meta("hp")) < victim_hp)

	game.skill_q_cd = 0.0
	game._skill_shroom(0)
	var patch: Node3D = game.fungus_patches.back()
	assert(float(patch.get_meta("radius")) >= 3.6)
	e0.set_meta("spore_stacks", 2)
	var before_ferment: float = float(e0.get_meta("hp"))
	game.skill_e_cd = 0.0
	game._skill_shroom(1)
	assert(float(e0.get_meta("hp")) < before_ferment)
	assert(float(corpse.get_meta("puppet_time")) > 7.0)

	game._update_hud()
	assert(game.status_label.text.find("SPORE BLOOM") >= 0)
	assert(game.help_label.text.find("LMB") >= 0)
	print("GODOT_PHASE11_ROLE_COMBAT_OK dash=", dash_distance, " nails=", game.bone_projectiles.size(), " corpse=", corpse.get_meta("puppet_time"))
	quit(0)
