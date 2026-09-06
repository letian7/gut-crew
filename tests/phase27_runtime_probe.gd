extends SceneTree
var game
func _init() -> void:
	create_timer(40).timeout.connect(func():printerr("PHASE27_RUNTIME_TIMEOUT");quit(1))
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(2,false)
	game.story_time = 0
	game.pitch = -0.52
	game.camera_pivot.rotation.x = game.pitch
	var clinic = game.clinic_system
	var center: Vector3 = clinic.sites[1].root.global_position
	game.player.position = center+Vector3(0,0.10,3.1)
	game.interact_down = true
	await create_timer(2.0).timeout
	assert(clinic.sites[1].stage=="clean","Live F did not diagnose")
	await create_timer(1.0).timeout
	assert(clinic.clean_fraction(1)>0.0,"Live wash does not reach tissue")
	print("PHASE27_LIVE_WASH_OK fps=",Engine.get_frames_per_second()," cleaned=",clinic.clean_cells," phase=",clinic.sites[1].stage)
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://GUT_CREW_QA_SHOTS/phase27_live_wash.png")
	game.interact_down = false
	await process_frame
	game.player.position = clinic.fishing_spots[0].root.global_position+Vector3(0,0.12,1.6)
	game.yaw = -PI*0.45
	game.player.rotation.y = game.yaw
	await create_timer(0.5).timeout
	game.interact_down = true
	await create_timer(0.1).timeout
	game.interact_down = false
	await create_timer(3.0).timeout
	assert(clinic.fish_site==0 and clinic.fish_state=="reel","Live fishing didn't reach bite state")
	print("PHASE27_LIVE_FISH_OK fps=",Engine.get_frames_per_second()," credits=",game.credits)
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://GUT_CREW_QA_SHOTS/phase27_live_fishing.png")
	game._handle_escape()
	var fish_time: float = clinic.fish_clock
	await create_timer(0.3).timeout
	assert(game.game_paused and clinic.fish_clock==fish_time and not clinic.hud.visible)
	game._handle_escape()
	game.player.position = clinic.upgrade.position+Vector3(0,0.12,1.4)
	await create_timer(0.2).timeout
	assert(clinic.fish_site==-1)
	game.credits = 60
	game.interact_down = true
	await create_timer(0.15).timeout
	game.interact_down = false
	assert(clinic.levels[2]==1 and game.credits==20,"Live upgrade F failed")
	await create_timer(0.5).timeout
	print("GODOT_PHASE27_RUNTIME_OK renderer=live F=wash_fish_upgrade pause=frozen")
	quit(0)
