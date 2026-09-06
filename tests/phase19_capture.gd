extends SceneTree
const Enemies = preload("res://scripts/enemy_factory.gd")
var camera: Camera3D

func shot(name: String) -> void:
	for frame in range(6): await process_frame
	await RenderingServer.frame_post_draw
	var path := ProjectSettings.globalize_path("res://GUT_CREW_QA_SHOTS/"+name+".png")
	assert(root.get_texture().get_image().save_png(path) == OK)
	print("ART19_CAPTURE ",name)

func _init() -> void:
	create_timer(90.0).timeout.connect(func(): printerr("PHASE19_CAPTURE_TIMEOUT");quit(1))
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0, false)
	game.set_process(false)
	game.set_physics_process(false)
	for layer in game.find_children("*","CanvasLayer",true,false): layer.visible = false
	camera = Camera3D.new()
	game.add_child(camera)
	camera.current = true
	camera.fov = 40
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(-1,29,-3)
	lamp.light_color = Color("#ffe1bb")
	lamp.light_energy = 3.0
	lamp.omni_range = 12
	game.add_child(lamp)
	camera.position = game.entrance.global_position + Vector3(3.4,3.2,6.4)
	camera.look_at(game.entrance.global_position + Vector3(0,1.65,0))
	await shot("phase19_return_capsule")
	var kinds := ["HAIRBALL","PLATELET","PARASITE"]
	for kind in kinds:
		var visual: Node3D = Enemies.build(game,kind).visual
		visual.position = Vector3(0,25,0)
		camera.position = Vector3(2.3,26.6,-4.0)
		camera.look_at(Vector3(0,25.80,0.3))
		await shot("phase19_"+kind.to_lower())
		visual.queue_free()
		await process_frame
	game.mission_phase = "return"
	game._begin_host_boss()
	var boss = game.host_boss
	for layer in game.find_children("*","CanvasLayer",true,false): layer.visible = false
	camera.current = true
	camera.position = Vector3(9,46.0,11)
	camera.look_at(Vector3(0,43.8,-4.5))
	lamp.position = Vector3(-4,46,2)
	lamp.omni_range = 24
	lamp.light_energy = 2.5
	await shot("phase19_mochi_portrait")
	boss.attack_index = 0
	boss._begin_attack()
	boss.tick(0.1)
	await shot("phase19_mochi_paw_windup")
	boss._resolve_attack()
	boss.tick(0.01)
	await shot("phase19_mochi_paw_hit")
	boss.state = "recover"
	game._damage_enemy(boss.target,10000.0)
	for layer in boss.find_children("*","CanvasLayer",true,false): layer.visible = true
	for page in range(4):
		boss.tick(0.01)
		await shot("phase19_story_"+str(page))
		boss.story_elapsed = 1.1
		boss.advance_story()
	print("GODOT_PHASE19_CAPTURE_OK ending=",game.mission_phase)
	quit(0)
