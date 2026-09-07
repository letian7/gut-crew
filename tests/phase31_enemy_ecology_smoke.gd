extends SceneTree
var game
var ecology

func by_kind(kind: String) -> CharacterBody3D:
	for enemy in game.enemies:
		if is_instance_valid(enemy) and String(enemy.get_meta("kind",""))==kind:
			return enemy
	return null

func count_kind(kind: String) -> int:
	var count := 0
	for enemy in game.enemies:
		if is_instance_valid(enemy) and String(enemy.get_meta("kind",""))==kind:
			count += 1
	return count

func _init() -> void:
	create_timer(50).timeout.connect(func(): printerr("PHASE31_TIMEOUT"); quit(1))
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await physics_frame
	game._select_role(0,false)
	game.set_process(false)
	game.set_physics_process(false)
	game.story_label.visible = false
	ecology = game.enemy_ecology
	assert(is_instance_valid(ecology))
	assert(game.enemies.size() >= 33)
	assert(int(ecology.get_meta("specialist_count")) == 15)
	assert(ecology.get_meta("attack_modes") == ["melee","charge","ranged","split","swarm"])
	assert(ecology.dressing_props.size() == 20)
	assert(int(ecology.get_meta("nest_count")) == 12)
	assert(int(ecology.get_meta("vent_count")) == 8)
	assert(int(ecology.get_meta("ecology_parts")) == 100)
	for prop in ecology.dressing_props:
		assert(prop.scale.is_equal_approx(Vector3.ONE),"Ecology prop stretched by 5x world scale")

	# Three new clay species have readable silhouettes and dedicated attack metadata.
	var rammer := by_kind("RAMMER")
	var spitter := by_kind("SPITTER")
	var splitter := by_kind("SPLITTER")
	assert(is_instance_valid(rammer) and is_instance_valid(spitter) and is_instance_valid(splitter))
	assert(rammer.get_node_or_null("EnemyVisual/RammerBody") != null)
	assert(rammer.find_children("ChargeHorn*","MeshInstance3D",true,false).size() == 2)
	assert(spitter.get_node_or_null("EnemyVisual/SpitterSac") != null)
	assert(spitter.find_children("AcidBlister*","MeshInstance3D",true,false).size() == 7)
	assert(splitter.get_node_or_null("EnemyVisual/SplitterBody") != null)
	assert(splitter.find_children("SplitterEye*","MeshInstance3D",true,false).size() == 3)
	assert(rammer.get_meta("attack_mode") == "charge")
	assert(spitter.get_meta("attack_mode") == "ranged")
	assert(splitter.get_meta("attack_mode") == "split")
	# Ranged telegraph resolves into a real dodgeable acid projectile.
	spitter.global_position = game.player.global_position + Vector3(0,0,-8)
	spitter.set_meta("special_cd",0.0)
	spitter.set_meta("special_state","idle")
	ecology.tick(0.01)
	assert(spitter.get_meta("special_state") == "aim")
	ecology.tick(0.74)
	assert(ecology.ranged_shots == 1)
	assert(ecology.projectiles.size() == 1)
	var shot: Node3D = ecology.projectiles[0].node
	shot.global_position = game.player.global_position + Vector3.UP*0.55
	game.invuln = 0.0
	var hp_before: float = game.hp
	ecology._tick_projectiles(0.01)
	assert(game.hp < hp_before and ecology.projectile_hits == 1)
	assert(ecology.projectiles.is_empty())

	# Rammer uses a longer tell, locks a lane, then impacts with stronger knockback.
	rammer.global_position = game.player.global_position + Vector3(6,0,0)
	rammer.set_meta("special_cd",0.0)
	rammer.set_meta("special_state","idle")
	ecology.tick(0.01)
	assert(rammer.get_meta("special_state") == "windup")
	ecology.tick(0.70)
	assert(rammer.get_meta("special_state") == "charge")
	assert(ecology.charge_starts == 1)
	rammer.global_position = game.player.global_position + Vector3(0.8,0,0)
	game.invuln = 0.0
	hp_before = game.hp
	ecology.tick(0.01)
	assert(game.hp < hp_before)
	assert(Vector2(game.player.velocity.x,game.player.velocity.z).length() > 8.0)
	# A mature splitter dies into exactly two smaller, non-recursive swarm larvae.
	var larvae_before := count_kind("SPLIT_LARVA")
	game._damage_enemy(splitter,9999.0)
	assert(ecology.split_events == 1 and ecology.pending_splits.size() == 1)
	game.invuln = 1.0
	ecology.tick(0.01)
	assert(count_kind("SPLIT_LARVA") == larvae_before + 2)
	for enemy in game.enemies:
		if String(enemy.get_meta("kind",""))=="SPLIT_LARVA":
			assert(enemy.get_meta("attack_mode")=="swarm")
			assert(int(enemy.get_meta("split_generation"))==1)
			assert(enemy.get_node_or_null("EnemyVisual/SplitterLobe")!=null)

	print("GODOT_PHASE31_ENEMY_ECOLOGY_OK enemies=%d specialists=15 modes=charge+ranged+split larvae=2 ecology_parts=100" % game.enemies.size())
	game.queue_free()
	await process_frame
	quit()
