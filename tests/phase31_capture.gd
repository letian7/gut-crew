extends SceneTree
var game
func shot(name_: String) -> void:
	for i in range(12): await process_frame
	RenderingServer.force_draw()
	assert(root.get_texture().get_image().save_png("res://GUT_CREW_QA_SHOTS/"+name_+".png")==OK)

func find_kind(kind: String) -> CharacterBody3D:
	for enemy in game.enemies:
		if String(enemy.get_meta("kind",""))==kind: return enemy
	return null

func _init() -> void:
	create_timer(50).timeout.connect(func():printerr("PHASE31_CAPTURE_TIMEOUT");quit(1))
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await physics_frame
	game._select_role(0,false)
	game.set_process(false)
	game.set_physics_process(false)
	game.story_label.visible=false
	game.toast_label.visible=false
	game.mouth_intro.active=false
	game._toggle_view()
	game.player.global_position=Vector3(0,1.15,5.5)
	game.yaw=0.0
	game.pitch=-0.18
	game.player.rotation.y=0.0
	game.camera_pivot.rotation.x=game.pitch
	var show_kinds := ["RAMMER","SPITTER","SPLITTER"]
	for enemy in game.enemies: enemy.visible=String(enemy.get_meta("kind","")) in show_kinds
	var rammer:=find_kind("RAMMER")
	var spitter:=find_kind("SPITTER")
	var splitter:=find_kind("SPLITTER")
	rammer.global_position=Vector3(-3.2,0.2,-3.8)
	spitter.global_position=Vector3(0,0.2,-6.2)
	splitter.global_position=Vector3(3.2,0.2,-3.8)
	for prop in game.enemy_ecology.dressing_props: prop.visible=false
	for i in range(3):
		game.enemy_ecology.dressing_props[i].visible=true
		game.enemy_ecology.dressing_props[i].global_position=Vector3(-4.5+i*4.5,0.1,-8.5)
	game.EnemyFactory.animate(rammer.get_meta("visual"),"RAMMER",1.2,Vector3.ZERO,false,false,1.0)
	game.EnemyFactory.animate(spitter.get_meta("visual"),"SPITTER",1.2,Vector3.ZERO,false,false,0.85)
	game.EnemyFactory.animate(splitter.get_meta("visual"),"SPLITTER",1.2,Vector3.ZERO,false,false,0.8)
	await shot("phase31_specialist_wildlife")
	game.enemy_ecology._spawn_acid_shot(spitter)
	var projectile:Node3D=game.enemy_ecology.projectiles[-1].node
	projectile.global_position=Vector3(0,1.2,-1.8)
	game.enemy_ecology._spawn_charge_lane(rammer)
	await shot("phase31_attack_patterns")
	print("GODOT_PHASE31_CAPTURE_OK shots=2")
	quit()
