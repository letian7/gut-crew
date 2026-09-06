extends Node3D
const Art = preload("res://scripts/organ_world_factory.gd")
const Shell = preload("res://scripts/art18_organic_shell.gd")
const Creature = preload("res://scripts/art19_creatures.gd")
const ORIGIN := Vector3(65,16,0)
const DURATION := 8.5
var game
var elapsed := 0.0
var completed := false
var camera: Camera3D
var rear_cat: Node3D
var exit_ring: Node3D
var foam: Array[Node3D] = []
var old_help := ""

func rail(t: float) -> Vector3:
	return ORIGIN+Vector3(32.0*(game.world_scale-1.0),0,0)+Vector3(sin(t*PI)*1.8,-t*5.0,-t*17.0)

func start(host) -> void:
	game = host
	name = "IntestinalEscape21"
	old_help = game.help_label.text
	game.mission_phase = "escape"
	game._cancel_phase11_holds()
	game._clear_spark_mark()
	game.interact_down = false
	game.capture_bar.visible = false
	game.interact_label.text = ""
	game.crosshair.visible = false
	game.status_label.visible = false
	game.view_label.visible = false
	game.danger_label.visible = false
	game.target_label.visible = false
	game.toast_time = 0.0
	game.toast_label.visible = false
	game.help_label.text = "撤离过场 · Esc 暂停"
	if is_instance_valid(game.mouse_target):
		for label in game.mouse_target.find_children("*","Label3D",true,false): label.visible = false
	game.character_visual.visible = true
	game.first_person = false
	game.terrain_world.overlay.visible = false
	game.player.velocity = Vector3.ZERO
	game.player.rotation = Vector3.ZERO
	_build_route()
	camera = Camera3D.new()
	camera.fov = 67
	add_child(camera)
	camera.current = true
	game._story_beat("异物已取出，体内压力恢复。抱紧电子老鼠——这次出口在后面！",4.5,0)
	tick(0.0)

func _build_route() -> void:
	var points: Array[Vector3] = []
	var indices: Array[int] = []
	for row in range(65):
		var t := lerpf(-0.28,1.0,float(row)/64.0)
		for col in range(33):
			var angle := float(col)/32.0*TAU
			var fold := 1.0+0.08*sin(t*PI*18.0)
			points.append(rail(t)+Vector3(cos(angle)*2.7*fold,2.1+sin(angle)*2.35*fold,0))
	for row in range(64):
		for col in range(32):
			var i := row*33+col
			indices.append_array([i,i+33,i+1,i+1,i+33,i+34])
	Shell._mesh(self,"TerminalGutTunnel",points,indices,Color("a37c83"))
	var end := rail(1.0)
	exit_ring = Art.torus(self,"SoftExit",end+Vector3.UP*2.1,Vector3(2.65,0.55,2.3),Color("aa7788"),Vector3(PI*0.5,0,0))
	Art.static_pad(self,"LitterTrayFloor",end+Vector3(0,-1.1,-5),Vector3(20,0.6,18),Color("b8ad99"))
	Art.static_pad(self,"RoomFloor",end+Vector3(0,-2,-1),Vector3(32,0.5,36),Color("829795"))
	for side in [-1.0,1.0]:
		Art.static_pad(self,"RoomSide",end+Vector3(side*16,5,-1),Vector3(0.4,14,36),Color("a1b5ae"))
		Art.static_pad(self,"RoomEnd",end+Vector3(0,5,-1+side*18),Vector3(32,14,0.4),Color("94aaa4"))
	Art.static_pad(self,"RoomCeiling",end+Vector3(0,12,-1),Vector3(32,0.4,36),Color("bcc9be"))
	for side in [-1.0,1.0]:
		Art.static_pad(self,"TrayRim",end+Vector3(side*10,0,-5),Vector3(0.5,2,18),Color("809c9d"))
	for i in range(44):
		var x := sin(float(i)*2.399)*8.5
		var z := -1.5-fmod(float(i)*1.37,12.0)
		Art.sphere(self,"PaperLitter",end+Vector3(x,-0.67,z),Vector3(0.23,0.12,0.3),Color("c6b99e"))
	rear_cat = Node3D.new()
	rear_cat.name = "MochiRearView"
	rear_cat.position = end+Vector3(0,-0.8,4.8)
	rear_cat.rotation.y = -0.25
	add_child(rear_cat)
	Creature.attach(rear_cat,"MOCHI")
	rear_cat.visible = false
	for i in range(9):
		var puff := Art.sphere(self,"ComicFoam",end,Vector3.ONE*0.16,Color("bcb19a"))
		puff.visible = false
		foam.append(puff)
	for t in [0.0,0.4,0.8,1.2]:
		var light := OmniLight3D.new()
		light.position = rail(t)+Vector3.UP*2
		light.light_color = Color("ffdfbb")
		light.light_energy = 1.8
		light.omni_range = 12
		add_child(light)
	set_meta("exit_route","terminal_gut_to_litter_tray")

func tick(delta: float) -> void:
	if completed or game.game_paused: return
	elapsed += delta
	game.round_time += delta
	var end := rail(1.0)
	if elapsed < 5.0:
		var t := elapsed/5.0
		game.player.global_position = rail(t)+Vector3.UP*0.18
		game.player.rotation.z = sin(elapsed*4)*0.12
		camera.global_position = rail(t-0.24)+Vector3.UP*2.2
		camera.look_at(rail(minf(t+0.10,1.0))+Vector3.UP*0.9)
		game.mission_label.text = "蠕动撤离 · 肠道末端 → 排泄出口"
	elif elapsed < 7.0:
		var t := (elapsed-5.0)/2.0
		rear_cat.visible = true
		get_node("TerminalGutTunnel").visible = false
		exit_ring.visible = false
		game.player.global_position = end+Vector3(0,0.18+sin(t*PI)*2.0-0.95*t,-5.0*t)
		game.player.rotation.z = sin(t*TAU)*0.42
		camera.global_position = end+Vector3(12,6,-10)
		camera.look_at(end+Vector3(0,1.4,1.2))
		game.mission_label.text = "噗通！全员排出 · 电子老鼠安全"
		for i in range(foam.size()):
			foam[i].visible = t < 0.72
			foam[i].position = end+Vector3(sin(float(i)*2.4)*t*2.5,0.5+sin(t*PI)*(0.5+float(i%3)),-t*(2.5+float(i%4)))
	else:
		game.player.rotation = Vector3.ZERO
		game.player.global_position = end+Vector3(0,-0.77,-5)
		game.mission_label.text = "电子老鼠突然响了——莫奇发现了它！"
		if is_instance_valid(game.mouse_target):
			game.mouse_target.rotation.z = sin(elapsed*8)*0.1
	if is_instance_valid(game.mouse_target):
		game.mouse_target.visible = true
		game.mouse_target.global_position = game.player.global_position+Vector3(0,0.75,-0.65)
		game.mouse_target.velocity = Vector3.ZERO
	if elapsed >= DURATION: finish()

func finish() -> void:
	if completed: return
	completed = true
	visible = false
	camera.current = false
	game.player.rotation = Vector3.ZERO
	game.mission_phase = "return"
	game.crosshair.visible = true
	game.status_label.visible = true
	game.view_label.visible = true
	game.target_label.visible = true
	game.help_label.text = old_help
	game._begin_host_boss()
	game.host_boss.provoke_with_toy()
	game.set_meta("exited_via_rear",true)
