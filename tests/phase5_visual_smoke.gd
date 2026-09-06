extends SceneTree
const SkillVFX = preload("res://scripts/skill_vfx.gd")
const EnemyFactory = preload("res://scripts/enemy_factory.gd")

func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	game._set_role(0)
	game.anim_cast_time = 0.21
	game._animate_role_model(0.0)
	assert(game.character_visual.get_node("SparkMouth").scale.y > 0.07)
	game.anim_cast_time = 0.0
	game.anim_hurt_time = 0.2
	game._animate_role_model(0.0)
	assert(game.character_visual.get_node("SparkMouth").scale.y > 0.09)
	SkillVFX.spawn_sync(game, Vector3.ZERO, 3, Color("#ffd83f"), Color("#63dcff"))
	await process_frame
	assert(game.get_node_or_null("SyncRing") != null)
	assert(game.get_node_or_null("SyncBead") != null)
	assert(game.get_node_or_null("SyncCore") != null)
	var hb := Node3D.new(); root.add_child(hb)
	var hbd: Dictionary = EnemyFactory.build(hb, "HAIRBALL")
	EnemyFactory.animate(hbd["visual"], "HAIRBALL", 1.0, Vector3.ZERO, false, false, 1.0)
	assert((hbd["visual"] as Node3D).get_node("Tongue").position.z < -0.65)
	var pb := Node3D.new(); root.add_child(pb)
	var pbd: Dictionary = EnemyFactory.build(pb, "PLATELET")
	EnemyFactory.animate(pbd["visual"], "PLATELET", 1.0, Vector3.ZERO, false, false, 1.0)
	assert((pbd["visual"] as Node3D).get_node("PlateletArm").rotation.x < -0.8)
	var gb := Node3D.new(); root.add_child(gb)
	var gbd: Dictionary = EnemyFactory.build(gb, "PARASITE")
	EnemyFactory.animate(gbd["visual"], "PARASITE", 1.0, Vector3.ZERO, false, false, 1.0)
	assert((gbd["visual"] as Node3D).get_node("ParasiteMouth").scale.x > 0.45)
	game.mission_phase = "chase"
	game._spawn_mission_mouse()
	var mv := game.mouse_target.get_meta("visual") as Node3D
	assert(mv.get_node_or_null("MouseShell") != null)
	assert(mv.get_node_or_null("MouseLEDNose") != null)
	assert(mv.get_node_or_null("MouseTailBead") != null)
	assert(mv.get_node_or_null("ParasiteHead") == null)
	EnemyFactory.animate(mv, "TOY_MOUSE", 1.2, Vector3(4,0,0), false, false, 0.0)
	print("GODOT_PHASE5_VISUAL_OK")
	quit(0)
