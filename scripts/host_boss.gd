extends Node3D

const Art = preload("res://scripts/organ_world_factory.gd")
const CreatureArt = preload("res://scripts/art19_creatures.gd")
const Detail = preload("res://scripts/art22_detail.gd")
const ORIGIN := Vector3(0, 40, 0)
const MAX_PANIC := 320.0
const STORY = [
	["第一幕 · 打赢以后，任务才真正开始", "莫奇终于收起了爪子，却仍盯着我们手中的电子老鼠。\n我们把玩具放回它面前，愤怒的嘶叫慢慢变成了呜咽。\n它不是在报复救命恩人。它以为，我们要拿走最后一个会叫它名字的东西。"],
	["第二幕 · 被误读的病历", "病历上写着：被遗弃，拒食七天。\n玩具终于放出那段修复的录音：\n“莫奇，替我保管小老鼠。等医生让我回家，我就来接你。”"],
	["第三幕 · 门开了", "诊疗室的门被轻轻推开。\n一个戴着住院手环的小女孩伸出手，掌心放着同样磨旧的猫铃。\n莫奇慢慢收起爪子，把小老鼠推到她手边。"],
	["尾声 · 最后一声晚安", "“这一次，换我接你回家。”\n莫奇没有再护住玩具，它把额头贴进女孩的掌心。\n我们以为救出的是一段录音。其实，是两颗一直在等对方回家的心。"]
]
var game
var target: CharacterBody3D
var cat: Node3D
var cat_head: Node3D
var paw_left: Node3D
var paw_right: Node3D
var toy: Node3D
var hand: Node3D
var marker: MeshInstance3D
var ui_root: Control
var boss_bar: ProgressBar
var boss_label: Label
var story_panel: Panel
var story_title: Label
var story_body: Label
var next_button: Button
var state := "idle"
var panic := MAX_PANIC
var state_time := 0.0
var elapsed := 0.0
var attack_index := 0
var attack_kind := 0
var attack_pos := Vector3.ZERO
var wave_radius := 0.0
var story_index := 0
var story_elapsed := 0.0
var rescued := false
var last_role := -1
var combo_time := 0.0
var strikes := 0
var control_lock := 0.0
var impact_time := 0.0
var mood_brows: Node3D
var toy_cooldown := 0.0
var toy_lure_time := 0.0
var toy_was_held := false
var attack_lured := false
var charge_start := Vector3.ZERO
var charge_end := Vector3.ZERO
var provoked := false

func provoke_with_toy() -> void:
	provoked = true
	state = "toy_intro"
	state_time = 3.2
	toy.position = game.player.position+Vector3(0,0.65,-1.0)
	boss_label.text = "电子老鼠响了！莫奇炸毛：把我的玩具还回来！"
	game._toast("抢玩具大战：躲过攻击，再让莫奇冷静下来",Color("#ffd7a1"),3.0)

func squeak_toy() -> bool:
	if state not in ["wait","recover"] or toy_cooldown > 0.0: return false
	if game.player.global_position.distance_to(toy.global_position) > 2.5: return false
	toy_cooldown = 10.0
	toy_lure_time = 8.0
	game._toast("吱！下一次冲撞会追玩具——快离开标记！",Color("#ffe1a7"),2.5)
	return true

func start(host) -> void:
	if state != "idle":
		return
	game = host
	_set_clinic_lighting()
	_build_arena()
	_build_cat()
	_build_ui()
	game._spawn_enemy("HAIRBALL", ORIGIN + Vector3(0, 0.35, -1.5), Color("#d79b65"), MAX_PANIC, 0.0)
	target = game.enemies[-1]
	target.set_meta("kind", "MOCHI")
	target.set_meta("host_boss", true)
	target.set_meta("contact_damage", 0.0)
	(target.get_meta("visual") as Node3D).visible = false
	(target.get_meta("hp_label") as Label3D).visible = false
	game.mission_phase = "host_boss"
	if is_instance_valid(game.mouse_target):
		game.mouse_target.visible = false
	game.player.global_position = respawn_point()
	game.player.velocity = Vector3.ZERO
	game.hp = 100.0
	game.invuln = 1.0
	game.yaw = 0.0
	game.pitch = -0.12
	game.player.rotation.y = 0.0
	game.camera_pivot.rotation.x = game.pitch
	game.first_person = false
	game.camera_1p.current = false
	game.camera_3p.current = true
	game.character_visual.visible = true
	game.primary_hold = false
	game.secondary_hold = false
	game.interact_down = false
	game.story_time = 0.0
	game.toast_label.position = Vector2(300,592)
	game.toast_label.size = Vector2(680,42)
	game.mission_label.visible = false
	game.story_label.visible = false
	game.danger_label.visible = false
	game.acid_tide_time = 0.0
	game.spasm_time = 0.0
	game.drink_time = 0.0
	game.drink_wave.visible = false
	for enemy in game.enemies:
		if enemy != target and is_instance_valid(enemy):
			enemy.visible = false
	game._clear_spark_mark()
	state = "wait"
	state_time = 1.5
	game._toast("FINAL RESCUE: MOCHI / defeat panic, not the patient", Color("#ffe0a0"), 4.0)

func respawn_point() -> Vector3:
	return ORIGIN + Vector3(0, 0.75, 5.6)

func _set_clinic_lighting() -> void:
	for child in game.get_children():
		if child is WorldEnvironment:
			child.environment = child.environment.duplicate()
			child.environment.background_color = Color("#657f7c")
			child.environment.ambient_light_color = Color("#c7d7d0")
			child.environment.ambient_light_energy = 0.35
		elif child is DirectionalLight3D:
			child.light_color = Color("#fff0d9")
			child.light_energy = 0.8

func _build_arena() -> void:
	Art.static_pad(self, "ClinicTable", ORIGIN + Vector3(0,-0.4,0), Vector3(24,0.8,22), Color("#769b9c"))
	for side in [-1.0, 1.0]:
		Art.static_pad(self, "TrayEdge", ORIGIN + Vector3(side*11.8,0.3,0), Vector3(0.4,0.6,22), Color("#d6e5d7"))
	_build_clinic_room()
	var lamp := OmniLight3D.new()
	lamp.position = ORIGIN + Vector3(0,9,5)
	lamp.light_color = Color("#ffedcf")
	lamp.light_energy = 2.8
	lamp.omni_range = 28.0
	add_child(lamp)
	var key := SpotLight3D.new()
	key.name = "MochiPortraitKey22"
	key.position = ORIGIN+Vector3(-6,9,4)
	key.light_color = Color("ffe3bb")
	key.light_energy = 2.2
	key.spot_range = 22.0
	key.spot_angle = 62.0
	add_child(key)
	key.look_at(ORIGIN+Vector3(0,3,-3))
	toy = Node3D.new()
	toy.name = "RecoveredMemoryMouse"
	toy.position = ORIGIN + Vector3(-3.5,0.3,1.0)
	add_child(toy)
	Art.sphere(toy,"MouseBody",Vector3.ZERO,Vector3(0.8,0.45,1.0),Color("#b9cf8c"))
	for side in [-1.0,1.0]:
		Art.sphere(toy,"MouseEar",Vector3(0.24*side,0.25,0.2),Vector3.ONE*0.3,Color("#edb1b6"))
	Art.capsule(toy,"MouseTail",Vector3(0,0,-0.8),Vector3(0.06,0.7,0.06),Color("#cc9996"),Vector3(PI*0.5,0,0))
	hand = Node3D.new()
	hand.name = "ChildReturningHand"
	hand.position = ORIGIN + Vector3(6,0.65,0.5)
	hand.visible = false
	add_child(hand)
	Art.sphere(hand,"Palm",Vector3.ZERO,Vector3(1.4,0.42,1.3),Color("#f2c7a4"))
	for i in range(4):
		Art.capsule(hand,"Finger",Vector3(-0.46+float(i)*0.3,0,0.8),Vector3(0.23,0.65,0.23),Color("#f2c7a4"),Vector3(PI*0.5,0,0))
	Art.capsule(hand,"Forearm",Vector3(1.7,0,-0.6),Vector3(0.75,2.6,0.7),Color("#eebf9c"),Vector3(0,0,PI*0.5))
	Art.sphere(hand,"Thumb",Vector3(-0.7,0,0.18),Vector3(0.4,0.4,0.72),Color("#f2c7a4"))
	Art.torus(hand,"HospitalBracelet",Vector3(0,0,-0.75),Vector3(0.72,0.18,0.55),Color("#85d9ef"),Vector3(PI*0.5,0,0))
	CreatureArt.attach(hand, "HAND")

func _build_clinic_room() -> void:
	var room := Node3D.new()
	room.name = "ClosedClinicRoom"
	add_child(room)
	Art.static_pad(room,"BackWall",ORIGIN+Vector3(0,5,-12),Vector3(34,16,0.5),Color("#91aaa3"))
	Art.static_pad(room,"FrontWall",ORIGIN+Vector3(0,5,16),Vector3(34,16,0.5),Color("#91aaa3"))
	for side in [-1.0,1.0]:
		Art.static_pad(room,"SideWall",ORIGIN+Vector3(side*17,5,2),Vector3(0.5,16,28),Color("#849e9d"))
		Art.static_pad(room,"MedicineCabinet",ORIGIN+Vector3(side*14,0,-6),Vector3(3,5.5,4),Color("#738b8c"))
		for drawer in range(3):
			Art.static_pad(room,"CabinetDrawer",ORIGIN+Vector3(side*14,-1.5+float(drawer)*1.4,-3.96),Vector3(2.65,1.10,0.10),Color("#b9c9c2"))
			Art.capsule(room,"DrawerHandle",ORIGIN+Vector3(side*14,-1.5+float(drawer)*1.4,-3.84),Vector3(0.10,0.65,0.10),Color("#e3cc9f"),Vector3(0,0,PI*0.5))
	Art.static_pad(room,"RoomCeiling",ORIGIN+Vector3(0,13.2,2),Vector3(34,0.5,28),Color("#a4b4aa"))
	Art.static_pad(room,"RoomFloor",ORIGIN+Vector3(0,-3.25,2),Vector3(34,0.5,28),Color("#6b8785"))
	for side in [-1.0,1.0]:
		Art.static_pad(room,"TableEndRim",ORIGIN+Vector3(0,0.3,side*10.8),Vector3(23.6,0.6,0.4),Color("#d6e5d7"))
	Art.static_pad(room,"ClinicDoorFrame",ORIGIN+Vector3(8,1.8,-11.65),Vector3(4.8,8.6,0.24),Color("#526d70"))
	Art.static_pad(room,"ClinicClosedDoor",ORIGIN+Vector3(8,1.8,-11.45),Vector3(4.1,8.0,0.18),Color("#c9b9a0"))
	Art.sphere(room,"DoorHandle",ORIGIN+Vector3(9.4,1.1,-11.2),Vector3(0.28,0.28,0.3),Color("#f6d697"))
	var sign := Art.zone_label(room,"MOCHI / RESCUE ROOM",ORIGIN+Vector3(8,7,-11.2),Color("#f5e4bc"))
	sign.font_size = 34
	sign.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	Art.static_pad(room,"FrostedWindow",ORIGIN+Vector3(-16.7,5.2,3),Vector3(0.12,4.5,7),Color("#b4d5d4"))
	for i in range(4):
		Art.static_pad(room,"WindowBar",ORIGIN+Vector3(-16.58,5.2,0.4+float(i)*1.7),Vector3(0.08,4.5,0.12),Color("#667f81"))
	room.set_meta("closed_boundary",true)
	room.set_meta("wall_count",4)

func _build_cat() -> void:
	cat = Node3D.new()
	cat.name = "MochiHostBody"
	cat.position = ORIGIN + Vector3(0,0,-4.5)
	add_child(cat)
	Art.sphere(cat,"CatBody",Vector3(0,2.6,-1.9),Vector3(6.8,4.6,7.4),Color("#c38e68"))
	Art.sphere(cat,"CatChest",Vector3(0,2.6,1.0),Vector3(4.0,3.7,2.0),Color("#f7dbac"))
	cat_head = Node3D.new()
	cat_head.name = "CatHead"
	cat_head.position = Vector3(0,4.3,0.7)
	cat.add_child(cat_head)
	Art.sphere(cat_head,"HeadClay",Vector3.ZERO,Vector3(5.0,3.6,3.5),Color("#dfa676"))
	for side in [-1.0,1.0]:
		var ear := MeshInstance3D.new()
		var cone := CylinderMesh.new()
		cone.top_radius = 0.08
		cone.bottom_radius = 0.92
		cone.height = 2.0
		ear.mesh = cone
		ear.name = "CatEar"
		ear.position = Vector3(1.72*side,2.0,-0.25)
		ear.rotation.z = -side*0.23
		ear.material_override = Art.mat(Color("#bc7e5c"))
		cat_head.add_child(ear)
		Art.sphere(cat_head,"InnerEar",Vector3(1.72*side,2.0,0.35),Vector3(0.62,1.0,0.2),Color("#eeb4b1"))
		Art.sphere(cat_head,"EyeWhite",Vector3(0.95*side,0.22,1.56),Vector3(1.02,0.95,0.3),Color("#fff1bc"))
		Art.sphere(cat_head,"Pupil",Vector3(0.95*side,0.22,1.73),Vector3(0.32,0.70,0.12),Color("#283945"))
		Art.sphere(cat_head,"EyeGlint",Vector3(0.82*side,0.43,1.8),Vector3.ONE*0.15,Color.WHITE)
		Art.sphere(cat_head,"Muzzle",Vector3(0.45*side,-0.62,1.53),Vector3(1.28,0.84,0.63),Color("#ffe1b8"))
		for i in range(3):
			Art.capsule(cat_head,"Whisker",Vector3(1.9*side,-0.45-float(i)*0.16,1.55),Vector3(0.045,1.45,0.045),Color("#ffe4c0"),Vector3(0,0,PI*0.5+side*float(i-1)*0.12))
	Art.sphere(cat_head,"Nose",Vector3(0,-0.36,1.99),Vector3(0.62,0.38,0.23),Color("#cf8899"))
	Art.sphere(cat_head,"Mouth",Vector3(0,-0.90,1.83),Vector3(0.40,0.13,0.12),Color("#633e53"))
	for i in range(3):
		Art.capsule(cat_head,"ForeheadStripe",Vector3(-0.58+float(i)*0.58,1.2,1.38),Vector3(0.18,0.63,0.10),Color("#9a664d"),Vector3(0,0,float(i-1)*-0.12))
	paw_left = Art.sphere(cat,"LeftPaw",Vector3(-2.5,0.72,2.1),Vector3(2.1,1.45,2.8),Color("#f3c797"))
	paw_right = Art.sphere(cat,"RightPaw",Vector3(2.5,0.72,2.1),Vector3(2.1,1.45,2.8),Color("#f3c797"))
	for side in [-1.0,1.0]:
		for toe in range(3):
			var toe_node := Art.sphere(cat,"Toe",Vector3(side*2.5+(float(toe)-1.0)*0.48,0.64,3.2),Vector3(0.52,0.62,0.48),Color("#ffe0b2"))
			toe_node.reparent(paw_left if side < 0.0 else paw_right,true)
	for i in range(9):
		var a := float(i)*0.27
		Art.sphere(cat,"TailSegment",Vector3(3.0+sin(a)*2.2,0.9+sin(a)*0.8,-4.3+float(i)*0.55),Vector3(0.95,0.88,1.15),Color("#af765b"))
	cat.set_meta("host_species","cat")
	cat.set_meta("rescue_target",true)
	CreatureArt.attach(cat, "MOCHI")
	mood_brows = Node3D.new()
	mood_brows.name = "MoodBrows22"
	cat_head.add_child(mood_brows)
	var brows: Array = []
	for side in [-1.0,1.0]:
		var curve: Array[Vector3] = []
		for i in range(13):
			var t := float(i)/12.0
			curve.append(Vector3(side*(0.44+t*1.1),0.64+t*0.31+sin(t*PI)*0.07,1.69))
		brows.append(curve)
	var brow_mesh := Detail.tubes(mood_brows,"AngryEyebrows",brows,0.105,Color("765444"))
	brow_mesh.set_meta("art22_detail_kind","expression_brow")

func _label(parent: Control, pos: Vector2, size_v: Vector2, text_value: String, font_size: int) -> Label:
	var label := Label.new()
	label.position = pos
	label.size = size_v
	label.text = text_value
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",Color("#fff0d2"))
	label.add_theme_color_override("font_outline_color",Color("#241c32"))
	label.add_theme_constant_override("outline_size",5)
	parent.add_child(label)
	return label

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 22
	add_child(layer)
	ui_root = Control.new()
	ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(ui_root)
	var header := Panel.new()
	header.position = Vector2(125,104)
	header.size = Vector2(1030,60)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.name = "BossHeader"
	var header_style := StyleBoxFlat.new()
	header_style.bg_color = Color(0.08,0.12,0.15,0.88)
	header_style.set_corner_radius_all(14)
	header.add_theme_stylebox_override("panel",header_style)
	ui_root.add_child(header)
	boss_label = _label(ui_root,Vector2(170,107),Vector2(980,30),"MOCHI / PANIC",20)
	boss_bar = ProgressBar.new()
	boss_bar.position = Vector2(270,144)
	boss_bar.size = Vector2(740,12)
	boss_bar.max_value = MAX_PANIC
	boss_bar.value = panic
	boss_bar.show_percentage = false
	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = Color("#2a4344")
	bar_bg.set_corner_radius_all(8)
	var bar_fill := StyleBoxFlat.new()
	bar_fill.bg_color = Color("#f5b778")
	bar_fill.set_corner_radius_all(8)
	boss_bar.add_theme_stylebox_override("background",bar_bg)
	boss_bar.add_theme_stylebox_override("fill",bar_fill)
	ui_root.add_child(boss_bar)
	story_panel = Panel.new()
	story_panel.position = Vector2(125,450)
	story_panel.size = Vector2(1030,238)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08,0.08,0.12,0.96)
	style.set_corner_radius_all(22)
	story_panel.add_theme_stylebox_override("panel",style)
	story_panel.visible = false
	ui_root.add_child(story_panel)
	story_title = _label(story_panel,Vector2(26,18),Vector2(960,40),"",25)
	story_body = _label(story_panel,Vector2(26,64),Vector2(970,114),"",20)
	story_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	next_button = Button.new()
	next_button.position = Vector2(742,181)
	next_button.size = Vector2(250,42)
	next_button.text = "继续故事 / NEXT"
	next_button.pressed.connect(advance_story)
	story_panel.add_child(next_button)

func tick(delta: float) -> void:
	if state == "idle" or state == "complete" or game.game_paused:
		return
	elapsed += delta
	combo_time = maxf(0.0,combo_time-delta)
	control_lock = maxf(0.0,control_lock-delta)
	impact_time = maxf(0.0,impact_time-delta)
	toy_cooldown = maxf(0.0,toy_cooldown-delta)
	toy_lure_time = maxf(0.0,toy_lure_time-delta)
	if state == "toy_intro":
		state_time -= delta
		cat_head.rotation.z = sin(elapsed*7.0)*0.07
		toy.rotation.z = sin(elapsed*16.0)*0.12
		CreatureArt.sync(cat)
		if state_time <= 0.0:
			toy.position = ORIGIN+Vector3(-3.5,0.3,1.0)
			state = "wait"
			state_time = 1.0
		return
	if state == "ending":
		story_elapsed += delta
		next_button.disabled = story_elapsed < 1.0
		cat_head.rotation.z = sin(elapsed*0.7)*0.028
		CreatureArt.sync(cat)
		return
	if game.ko_time > 0.0:
		return
	target.global_position = ORIGIN + Vector3(0,0.35,-1.5)
	target.velocity = Vector3.ZERO
	target.set_meta("controlled",0.0)
	boss_bar.value = panic
	var frenzy := panic <= MAX_PANIC*0.5
	var names := ["拍爪：离开圆圈","扑击：离开长条","喵叫冲击环：跳过去","甩尾横扫：跳起或远离横带","抢玩具冲撞：朝侧面闪避"]
	boss_label.text = "莫奇 / %s %d   %s" % ["炸毛" if frenzy else "愤怒",int(ceil(panic)),names[attack_kind] if state in ["windup","wave"] else "喘息破绽：技能安抚；靠近老鼠按 F 引诱" if state == "recover" else "它正在盯着被拿走的玩具"]
	var toy_held: bool = Input.is_key_pressed(KEY_F) or game.interact_down
	var pads := Input.get_connected_joypads()
	if not pads.is_empty(): toy_held = toy_held or Input.is_joy_button_pressed(pads[0],JOY_BUTTON_LEFT_SHOULDER)
	if toy_held and not toy_was_held: squeak_toy()
	toy_was_held = toy_held
	toy.rotation.z = sin(elapsed*15.0)*0.13 if toy_lure_time > 0.0 else 0.0
	game.interact_label.text = ("F：让电子老鼠发声，引诱冲撞" if toy_cooldown <= 0.0 else "玩具冷却 %.0fs" % toy_cooldown) if game.player.position.distance_to(toy.position)<2.5 else ""
	cat_head.rotation.z = sin(elapsed*1.4)*0.045
	paw_left.position.y = 0.72 + (sin(elapsed*3.0)*0.1)
	paw_right.position.y = 0.72 + (1.1 if state == "windup" and attack_kind == 0 else 0.0)
	paw_right.position.z = 2.1 + (3.0 if impact_time > 0.0 and attack_kind == 0 else 0.0)
	if attack_kind == 0 and impact_time > 0.0:
		paw_right.position = Vector3(2.5,0.72,2.1).lerp(cat.to_local(attack_pos+Vector3.UP*0.55),clampf(impact_time/0.3,0.0,1.0))
	else:
		paw_right.position.x = 2.5
	cat.position.z = ORIGIN.z-4.5 + (1.4 if impact_time > 0.0 and attack_kind == 1 else 0.0)
	cat.rotation.y = sin(elapsed*9.0)*0.25 if attack_kind == 3 and impact_time > 0.0 else 0.0
	if attack_kind == 4 and impact_time > 0.0:
		var lunge := sin(clampf(1.0-impact_time/0.65,0.0,1.0)*PI)
		cat.position.x = charge_end.x*lunge*0.65
		cat.position.z += (charge_end.z-charge_start.z)*lunge*0.55
	else:
		cat.position.x = 0.0
	cat_head.scale = Vector3(1.03,0.94,1.03) if impact_time > 0.0 else Vector3.ONE
	CreatureArt.sync(cat)
	state_time -= delta
	if state == "wave":
		wave_radius += delta*13.0
		_sync_wave_marker()
		var flat := Vector2(game.player.position.x,game.player.position.z+1.5).length()
		if absf(flat-wave_radius) < 0.9 and game.player.position.y < ORIGIN.y+1.1:
			_hurt_player(14.0)
	if state_time > 0.0:
		return
	match state:
		"wait","recover": _begin_attack()
		"windup": _resolve_attack()
		"wave":
			_clear_marker()
			state = "recover"
			state_time = 2.2 if frenzy else 2.8

func _begin_attack() -> void:
	attack_kind = attack_index % 5
	attack_index += 1
	attack_pos = game.player.global_position
	attack_lured = toy_lure_time > 0.0
	if attack_lured:
		attack_kind = 4
		attack_pos = toy.global_position
		toy_lure_time = 0.0
	attack_pos.y = ORIGIN.y+0.05
	state = "windup"
	state_time = 0.95 if panic <= MAX_PANIC*0.5 else 1.3
	if attack_kind == 4: state_time += 0.35
	_clear_marker()
	if attack_kind == 0:
		marker = Art.sphere(self,"PawWarning",attack_pos,Vector3(5.4,0.04,5.4),Color("#ffb36d"),0.55,1.0)
	elif attack_kind == 1:
		marker = MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(3.8,0.06,16)
		marker.mesh = box
		marker.position = Vector3(attack_pos.x,ORIGIN.y+0.06,1.0)
		marker.material_override = Art.mat(Color("#ff7794"),0.52,1.0)
		add_child(marker)
	elif attack_kind == 2:
		marker = Art.torus(self,"MeowWarning",ORIGIN+Vector3(0,0.10,-1.5),Vector3(0.7,0.08,0.7),Color("#a8edff"),Vector3.ZERO,0.75,1.2)
	elif attack_kind == 3:
		marker = _warning_lane("TailWarning",Vector3(-10.6,ORIGIN.y+0.06,attack_pos.z),Vector3(10.6,ORIGIN.y+0.06,attack_pos.z),3.4,Color("#ffc76b"))
	else:
		charge_start = ORIGIN+Vector3(0,0.06,-1.5)
		var direction := (attack_pos-charge_start).normalized()
		direction.y = 0.0
		if direction.length() < 0.01: direction = Vector3.BACK
		charge_end = charge_start+direction.normalized()*13.0
		charge_end.x = clampf(charge_end.x,-10.2,10.2)
		charge_end.z = clampf(charge_end.z,-7.0,8.5)
		marker = _warning_lane("ToyChargeWarning",charge_start,charge_end,3.6,Color("#f7a0c8"))

func _warning_lane(label: String, a: Vector3, b: Vector3, width: float, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = label
	var box := BoxMesh.new()
	box.size = Vector3(width,0.06,a.distance_to(b))
	node.mesh = box
	node.material_override = Art.mat(color,0.55,1.0)
	node.position = (a+b)*0.5
	add_child(node)
	node.look_at(b,Vector3.UP)
	return node

func _resolve_attack() -> void:
	var p: Vector3 = game.player.global_position
	impact_time = 0.30
	if attack_kind == 2:
		state = "wave"
		state_time = 1.35
		wave_radius = 0.5
		_sync_wave_marker()
		return
	var hit := false
	if attack_kind == 0:
		hit = Vector2(p.x-attack_pos.x,p.z-attack_pos.z).length() < 2.7 and p.y < ORIGIN.y+2.4
		paw_right.position = cat.to_local(attack_pos+Vector3.UP*0.55)
		CreatureArt.sync(cat)
	elif attack_kind == 1:
		hit = absf(p.x-attack_pos.x) < 1.9 and p.z > -7.0 and p.z < 9.0 and p.y < ORIGIN.y+2.8
	elif attack_kind == 3:
		hit = absf(p.z-attack_pos.z) < 1.7 and absf(p.x) < 10.6 and p.y < ORIGIN.y+1.3
	else:
		var closest := Geometry3D.get_closest_point_to_segment(Vector3(p.x,charge_start.y,p.z),charge_start,charge_end)
		hit = Vector2(p.x-closest.x,p.z-closest.z).length() < 1.8 and p.y < ORIGIN.y+2.8
		impact_time = 0.65
	if hit:
		_hurt_player([20.0,25.0,14.0,18.0,28.0][attack_kind])
	_clear_marker()
	state = "recover"
	state_time = 2.2 if panic <= MAX_PANIC*0.5 else 2.8
	if attack_kind == 4: state_time += 0.6
	if attack_lured:
		state_time += 1.2
		game._toast("扑空了！合作输出窗口延长",Color("#b7f5da"),1.6)

func _sync_wave_marker() -> void:
	if not is_instance_valid(marker): return
	var ring := marker.mesh as TorusMesh
	ring.inner_radius = maxf(0.02,wave_radius-0.9)
	ring.outer_radius = wave_radius+0.9
	marker.scale = Vector3(1.0,0.08,1.0)

func _hurt_player(amount: float) -> void:
	if game.invuln > 0.0 or game.ko_time > 0.0 or game.hp <= 0.0:
		return
	game.hp = maxf(0.0,game.hp-amount)
	game._player_hurt_feedback(amount, target.global_position, true)
	game.invuln = 0.85
	strikes += 1

func apply_hit(amount: float, control: float, role: int) -> void:
	if state not in ["wait","windup","wave","recover"] or amount <= 0.0:
		return
	var effect := amount * (1.0 if state == "recover" else 0.30)
	if control > 0.0:
		effect *= 1.20
		# Strong control delays one warning; tiny LMB stuns cannot stunlock.
		if control >= 0.5 and control_lock <= 0.0 and state == "windup":
			state_time += 0.45
			control_lock = 5.0
			game._toast("SOOTHING WINDOW +0.45s",Color("#b7f5da"),1.0)
	if combo_time > 0.0 and last_role >= 0 and last_role != role:
		effect += 8.0
		game.synergies += 1
		game._toast("RESCUE SYNC: shared reassurance",Color("#b7f5da"),1.1)
	last_role = role
	combo_time = 2.6
	effect = minf(effect,panic)
	panic = maxf(0.0,panic-effect)
	game.impact_feedback.report_hit(effect,panic<=0.0)
	target.set_meta("hp",panic)
	game.hit_confirm_time = 0.15
	game.hit_shake = maxf(game.hit_shake,0.08)
	if panic > 0.0:
		game._spawn_damage_number(target.global_position+Vector3.UP*1.5,int(ceil(effect)))
	if panic <= 0.0:
		_begin_ending()

func _clear_marker() -> void:
	if is_instance_valid(marker):
		marker.get_parent().remove_child(marker)
		marker.queue_free()
	marker = null

func keep_in_arena() -> void:
	game.player.position.x = clampf(game.player.position.x,-10.6,10.6)
	game.player.position.z = clampf(game.player.position.z,-7.3,8.8)
	if game.player.position.y < ORIGIN.y-2.0:
		game.player.global_position = respawn_point()
		game.player.velocity = Vector3.ZERO

func retry() -> void:
	panic = MAX_PANIC
	target.set_meta("hp",panic)
	_clear_marker()
	state = "wait"
	state_time = 1.5
	attack_index = 0
	combo_time = 0.0
	last_role = -1
	control_lock = 0.0
	impact_time = 0.0
	toy_cooldown = 0.0
	toy_lure_time = 0.0
	toy_was_held = false
	cat.position = ORIGIN+Vector3(0,0,-4.5)
	cat.rotation = Vector3.ZERO
	paw_right.position = Vector3(2.5,0.72,2.1)
	mood_brows.visible = true
	game.invuln = 1.5
	game._clear_spark_mark()
	game._cancel_phase11_holds()
	game.player.global_position = respawn_point()

func _begin_ending() -> void:
	_clear_marker()
	game.interact_label.text = ""
	game.capture_bar.visible = false
	mood_brows.visible = false
	paw_right.position = Vector3(2.5,0.72,2.1)
	cat.position = ORIGIN+Vector3(0,0,-4.5)
	cat.rotation = Vector3.ZERO
	state = "ending"
	game.mission_phase = "ending"
	target.set_meta("dead",true)
	target.collision_layer = 0
	target.collision_mask = 0
	game.primary_hold = false
	game.secondary_hold = false
	game.player.velocity = Vector3.ZERO
	game.player.global_position = ORIGIN+Vector3(0,0.8,6)
	game.yaw = 0.0
	game.player.rotation.y = 0.0
	game.camera_pivot.rotation.x = -0.16
	game.camera_3p.current = true
	game.camera_1p.current = false
	game.first_person = false
	boss_bar.visible = false
	boss_label.visible = false
	ui_root.get_node("BossHeader").visible = false
	game.character_visual.visible = false
	game.toast_time = 0.0
	game.toast_label.visible = false
	game.view_label.visible = false
	var story_camera := Camera3D.new()
	story_camera.name = "ReunionCamera"
	add_child(story_camera)
	story_camera.global_position = ORIGIN+Vector3(0,4.8,7.5)
	story_camera.fov = 58.0
	story_camera.look_at(ORIGIN+Vector3(0,2.7,-3.0),Vector3.UP)
	story_camera.current = true
	game.status_label.visible = false
	game.target_label.visible = false
	game.help_label.visible = false
	game.crosshair.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	story_panel.visible = true
	story_index = 0
	_show_story_page()

func _show_story_page() -> void:
	story_elapsed = 0.0
	next_button.disabled = true
	story_title.text = STORY[story_index][0]
	story_body.text = STORY[story_index][1]
	next_button.text = "完成救助 / RESULTS" if story_index == STORY.size()-1 else "继续故事 / NEXT"
	cat_head.rotation.x = 0.08+float(story_index)*0.05
	hand.visible = story_index >= 2
	if story_index >= 2:
		toy.position = ORIGIN+Vector3(3.8,0.3,1.0)
	if story_index == 3:
		hand.position = ORIGIN+Vector3(0.75,5.9,-2.7)
		hand.rotation = Vector3(0,-PI*0.5,-0.15)
		hand.scale.z = 1.5
		cat_head.position.x = 0.5

func advance_story() -> void:
	if state != "ending" or story_elapsed < 1.0 or game.game_paused:
		return
	story_index += 1
	if story_index >= STORY.size():
		rescued = true
		state = "complete"
		ui_root.visible = false
		game._win_round()
	else:
		_show_story_page()
