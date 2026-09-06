extends SceneTree
const EnemyFactory=preload("res://scripts/enemy_factory.gd")
const SkillVFX=preload("res://scripts/skill_vfx.gd")
func shot(name:String) -> void:
	await create_timer(0.08).timeout
	await RenderingServer.frame_post_draw
	var img:=root.get_viewport().get_texture().get_image()
	img.save_png("C:/Users/EDY/Desktop/GUT_CREW_PHASE7_SHOTS/"+name+".png")
func _init() -> void:
	DirAccess.make_dir_recursive_absolute("C:/Users/EDY/Desktop/GUT_CREW_PHASE7_SHOTS")
	var game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.role_selected=true
	game.role_panel.visible=false
	game.player.position=Vector3(0,1.15,4.2)
	game.spring_arm.spring_length=5.2
	game._set_role(0)
	SkillVFX.spawn_dodge_success(game,game.player.global_position,game.ROLE_COLORS[0])
	await shot("perfect_dodge")
	var e:CharacterBody3D=game.enemies[0]
	e.position=Vector3(0,0.3,0)
	var vis=e.get_meta("visual") as Node3D
	EnemyFactory.apply_control_pose(vis,0.0,0.8,1.0)
	await shot("enemy_pinned")
	SkillVFX.spawn_body_event(game,"acid")
	await shot("acid_event")
	SkillVFX.spawn_body_event(game,"drink",1.0)
	await shot("drink_event")
	print("GODOT_PHASE7_CAPTURE_OK")
	quit(0)
