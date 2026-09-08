extends SceneTree
var game

func reset_enemy(enemy: CharacterBody3D, pos: Vector3) -> void:
	enemy.set_meta("dead",false)
	enemy.set_meta("hp",240.0)
	enemy.set_meta("max_hp",240.0)
	enemy.set_meta("stun",0.0)
	enemy.set_meta("pinned",0.0)
	enemy.set_meta("engulfed",false)
	enemy.visible=true
	enemy.global_position=pos

func _init() -> void:
	create_timer(50).timeout.connect(func(): printerr("PHASE32_TIMEOUT"); quit(1))
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await physics_frame
	game._select_role(1,false)
	game.set_process(false)
	game.set_physics_process(false)
	game.story_label.visible=false
	for enemy in game.enemies: enemy.set_meta("dead",true)
	var target: CharacterBody3D=game.enemies[0]
	game.player.global_position=Vector3(0,1.15,5.5)
	game.yaw=0.0
	reset_enemy(target,Vector3(0,1.15,2.7))

	# Shared first-person aiming and Kaka's two readable hand tools exist.
	assert(game.first_person and is_instance_valid(game.first_person_aim))
	assert(game.first_person_aim.name=="FirstPersonAim32")
	assert(game.first_person_viewmodel.get_node_or_null("LeftClayArm/BoneHammerHead")!=null)
	assert(game.first_person_viewmodel.get_node_or_null("RightClayArm/RoleTool/BoneHook")!=null)
	for role in range(4):
		game._set_role(role)
		game._fp_action("AIM TEST",0.4)
	assert(game.first_person_aim.events==4)
	game._set_role(1)

	# LMB has three charge stages; stage III delivers a hammer hit and spike fan.
	game.primary_attack_cd=0.0
	game._primary_pressed()
	game._tick_phase11(1.30)
	assert(game.kaka_hammer_stage==3 and game.kaka_charge_nails==5)
	var hp_before: float=target.get_meta("hp")
	game._primary_released()
	assert(float(target.get_meta("hp"))<hp_before)
	assert(game.bone_projectiles.size()>=6)
	assert(game.get_node_or_null("BoneHammerImpact32")!=null)

	# RMB charge launches a physical hook, bites, then reels the target into hammer range.
	reset_enemy(target,Vector3(0,1.15,-3.5))
	game.secondary_attack_cd=0.0
	game._secondary_pressed()
	game._tick_phase11(0.82)
	assert(game.secondary_hold and game.kaka_hook_charge>0.70)
	game._secondary_released()
	assert(not game.secondary_hold)
	assert(is_instance_valid(game.kaka_hook_projectile))
	assert(game.kaka_hook_phase=="outgoing")
	assert(target.global_position.distance_to(game.player.global_position+game._forward()*1.35)>4.0)
	assert(game.get_node_or_null("BoneHookProjectile33")!=null)
	for i in range(80):
		game._tick_kaka_hook_projectile(0.03)
		if game.kaka_hook_phase.is_empty(): break
	assert(target.global_position.distance_to(game.player.global_position+game._forward()*1.35)<0.2)
	assert(float(target.get_meta("hooked_close",0.0))>1.0)
	assert(game.kaka_hook_phase.is_empty())

	# Q previews then places a real five-second damage-blocking wall.
	game.skill_q_cd=0.0
	game._cast_skill(0)
	assert(is_instance_valid(game.kaka_wall_preview) and game.skill_q_cd==0.0)
	game._cast_skill(0)
	assert(not is_instance_valid(game.kaka_wall_preview))
	assert(game.kaka_walls.size()==1 and game.skill_q_cd>4.0)
	var wall: StaticBody3D=game.kaka_walls[0]
	assert(float(wall.get_meta("ttl"))==5.0)
	assert(int(wall.get_meta("model_parts",0))>=89)
	assert(wall.find_children("CartilageMembrane*","MeshInstance3D",false,false).size()>=6)
	assert(game._kaka_wall_blocks_point(wall.global_position+Vector3.UP))

	# E grants armor, physically pushes the wall to the rush endpoint, then shatters it.
	game.skill_e_cd=0.0
	game._cast_skill(1)
	assert(game.kaka_armor_time>2.0 and game.invuln>=1.0)
	game._tick_kaka_rush_contacts()
	assert(game.kaka_wall_pushes==1 and game.kaka_wall_detonations==0 and game.kaka_walls.is_empty())
	assert(wall.global_position.distance_to(wall.get_meta("push_end"))>1.0)
	await create_timer(0.46).timeout
	assert(game.kaka_wall_detonations==1)
	assert(game.get_node_or_null("BoneWallExplosion32")!=null)

	# Enemies now acquire from farther away and recycle attacks more aggressively.
	var melee: CharacterBody3D=game.enemies[1]
	assert(float(melee.get_meta("aggro_radius"))>=11.5)
	var spitter: CharacterBody3D
	for enemy in game.enemies:
		if String(enemy.get_meta("kind"))=="SPITTER":
			spitter=enemy
			break
	assert(is_instance_valid(spitter))
	game.enemy_ecology.configure_enemy(spitter)
	assert(float(spitter.get_meta("aggro_radius"))>=21.0)

	print(
		"GODOT_PHASE32_KAKA_FIRSTPERSON_OK "
		+ "aim=4 hammer=III hook=projectile+reel wall=89part_ribcage ram=push+endpoint_shatter aggression=up"
	)
	game.queue_free()
	await process_frame
	quit()
