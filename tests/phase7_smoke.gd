extends SceneTree
const EnemyFactory = preload("res://scripts/enemy_factory.gd")
const SkillVFX = preload("res://scripts/skill_vfx.gd")
func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	game.role_selected = true
	game.role_panel.visible = false
	game._set_role(0)
	var enemy: CharacterBody3D = game.enemies[0]
	enemy.global_position = game.player.global_position + Vector3(0,0,-0.8)
	enemy.set_meta("attack_windup",0.01)
	enemy.set_meta("attack_cd",1.0)
	var hp0: float = game.hp
	game._start_dodge()
	game._tick_enemies(0.02)
	assert(game.hp == hp0)
	assert(game.dodge_success_lock > 0.0)
	assert(game.get_node_or_null("PerfectDodgeRing") != null)
	var vis := enemy.get_meta("visual") as Node3D
	var base: Vector3 = vis.get_meta("base_scale",vis.scale)
	EnemyFactory.apply_control_pose(vis,0.0,0.5,1.0)
	assert(vis.scale.y < base.y)
	EnemyFactory.apply_control_pose(vis,0.5,0.0,1.0)
	assert(vis.scale.y < base.y)
	game.mission_phase = "chase"
	game._spawn_mission_mouse()
	var mouse: CharacterBody3D = game.mouse_target
	mouse.position = Vector3(21.75,0.35,0.0)
	mouse.set_meta("burst_cd",2.0)
	game._tick_mission_mouse(mouse,0.02)
	assert(float(mouse.get_meta("wall_bump",0.0)) > 0.0)
	SkillVFX.spawn_body_event(game,"acid")
	assert(game.get_node_or_null("BodyEventRing") != null)
	SkillVFX.spawn_body_event(game,"drink",1.0)
	assert(game.get_node_or_null("SwallowDrop") != null)
	for role in range(4):
		game._set_role(role)
		game.anim_cast_time = 0.30
		game.anim_cast_slot = role % 2
		game._animate_role_model(0.016)
	print("GODOT_PHASE7_OK hp=",game.hp," wall=",mouse.get_meta("wall_bump"))
	quit(0)
