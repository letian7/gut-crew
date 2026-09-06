extends Node3D
## Optional rescue contracts: keep the original story completable, make care worthwhile.
const Art = preload("res://scripts/organ_world_factory.gd")
const JOBS = ["闪仔 · 神经诊疗师", "咔咔 · 搬运修复员", "泡泡 · 清洁专家", "菇菇 · 菌疗医生"]
const COSTS = [40, 70, 110]
const PERKS = ["连锁电弧 / 位移和雷暴范围增强", "蓄力骨钉 +2 / 装填恢复更快", "冲洗更宽 / 弹跳溅射更大", "菌毯治疗增强 / 控制更久"]
const LOOT = [
	{"name":"被吞下的瓶盖", "value":12}, {"name":"旧硬币", "value":22},
	{"name":"荧光胃石", "value":30}, {"name":"胃酸珍珠", "value":45},
	{"name":"打嗝小酸鱼", "value":55}]
var game
var sites: Array[Dictionary] = []
var fishing_spots: Array[Dictionary] = []
var levels: Array[int] = [0,0,0,0]
var bag: Array[Dictionary] = []
var completed := 0
var clean_cells := 0
var sold_value := 0
var fish_caught := 0
var cargo_site := -1
var fish_site := -1
var fish_state := "idle"
var fish_clock := 0.0
var fish_bite_delay := 0.0
var fish_hits := 0
var fish_tension := 0
var clock := 0.0
var last_held := false
var action_key := ""
var hold_progress := 0.0
var context_site := -1
var hint := "绿色十字：救助站  ·  蓝点：胃酸钓宝"
var recycle: Node3D
var upgrade: Node3D
var spray: MeshInstance3D
var foam: Array[MeshInstance3D] = []
var spray_time := 0.0
var hud: Control
var rng := RandomNumberGenerator.new()
var enabled := true
var clean_flash := 0.0
var clean_streak := 0
var sound_lock := 0.0
var work_audio: AudioStreamPlayer
var wash_sound: AudioStreamWAV
var success_sound: AudioStreamWAV

func build(host) -> void:
	game = host
	name = "ClinicAndSalvage27"
	rng.randomize()
	# Old regression fixtures use an explicitly separate 1x coordinate layout.
	enabled = not (DisplayServer.get_name() == "headless" and game.world_scale < 2.0)
	if not enabled: return
	_build_site("异物堵塞", "搬走堵塞物，恢复通路", "cargo", Vector3(-17,0.30,-1), 1)
	_build_site("胃黏膜溃疡", "洗净脏污，再敷上菌疗贴", "ulcer", Vector3(0,0.04,-1.8), 3)
	_build_site("神经短路", "清除油垢，校准神经脉冲", "nerve", Vector3(2.5,0.40,-11), 0)
	_build_fishing(Vector3(-8.2,1.125,3.8), Vector3(-4.8,0.2,4.2))
	_build_fishing(Vector3(7.7,1.275,4.0), Vector3(4.8,0.2,4.5))
	recycle = _station("回收站", game.shop_root.global_position+Vector3(-5.2,0,1.0), Color("e5b963"))
	upgrade = _station("职业强化", game.shop_root.global_position+Vector3(5.2,0,1.0), Color("b697ef"))
	spray = Art.cylinder(self,"FoamStream",Vector3.ZERO,Vector3.ONE,Color("b4f3ef"),Vector3.ZERO,0.72)
	spray.visible = false
	for i in range(6):
		var bubble := Art.sphere(self,"WashFoam",Vector3.ZERO,Vector3.ONE*0.15,Color("d9fffa"))
		bubble.visible = false
		foam.append(bubble)
	work_audio = AudioStreamPlayer.new()
	work_audio.volume_db = -19.0
	add_child(work_audio)
	wash_sound = game.impact_feedback.sound(940,0.09,0.14)
	success_sound = game.impact_feedback.sound(740,0.24,0.04)
	var layer := CanvasLayer.new()
	layer.layer = 13
	add_child(layer)
	hud = preload("res://scripts/clinic_hud.gd").new()
	layer.add_child(hud)
	hud.build(self)
	decorate_role()
	_optimize_visuals(self)

func _optimize_visuals(parent: Node) -> void:
	for child in parent.get_children():
		if child is MeshInstance3D:
			child.visibility_range_end = 65.0
			if child.mesh is SphereMesh:
				child.mesh.radial_segments = 16
				child.mesh.rings = 8
			elif child.mesh is CylinderMesh: child.mesh.radial_segments = 16
			elif child.mesh is CapsuleMesh:
				child.mesh.radial_segments = 12
				child.mesh.rings = 6
		_optimize_visuals(child)

func _chime(success := false) -> void:
	if not is_instance_valid(work_audio) or DisplayServer.get_name()=="headless": return
	if sound_lock>0.0 and not success: return
	work_audio.stream = success_sound if success else wash_sound
	work_audio.pitch_scale = 1.0 if success else 0.94+minf(clean_streak,10)*0.035
	work_audio.play()
	sound_lock = 0.10

func _exit_tree() -> void:
	if is_instance_valid(work_audio):
		work_audio.stop()
		work_audio.stream = null
	wash_sound = null
	success_sound = null

func _label(parent: Node3D, text: String, pos: Vector3, color: Color) -> Label3D:
	var label := Label3D.new()
	label.text = text
	label.position = pos
	label.font_size = 30
	label.pixel_size = 0.007
	label.modulate = color
	label.outline_size = 7
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = false
	label.visibility_range_end = 34.0
	parent.add_child(label)
	return label

func _cross(parent: Node3D, pos: Vector3, size_v: float) -> void:
	Art.capsule(parent,"CareCrossV",pos,Vector3(0.18,0.55,0.16)*size_v,Color("9effd1"))
	Art.capsule(parent,"CareCrossH",pos,Vector3(0.18,0.55,0.16)*size_v,Color("9effd1"),Vector3(0,0,PI*0.5))

func _station(title: String, pos: Vector3, color: Color) -> Node3D:
	var station := Node3D.new()
	station.position = pos
	add_child(station)
	Art.cylinder(station,"SoftStand",Vector3(0,0.35,0),Vector3(1.4,0.7,1.4),Color("496b70"))
	Art.sphere(station,"Counter",Vector3(0,0.74,0),Vector3(1.75,0.30,1.5),color)
	_cross(station,Vector3(0,1.2,0),0.9)
	station.set_meta("label",_label(station,title,Vector3(0,2.0,0),color.lightened(0.3)))
	return station

func _build_site(title: String, desc: String, kind: String, authored: Vector3, specialist: int) -> void:
	var site := Node3D.new()
	site.position = game.world_point(authored)
	add_child(site)
	var tissue := Art.sphere(site,"PatientTissue",Vector3(0,0.12,0),Vector3(5.3,0.45,4.6),Color("dd839c"))
	var wound := Art.sphere(site,"InflamedTissue",Vector3(0,0.29,0),Vector3(2.0,0.30,1.7),Color("aa3c67"))
	var stitches: Array[MeshInstance3D] = []
	for i in range(3):
		var stitch := Art.capsule(site,"LivingBandage",Vector3(-0.65+i*0.65,0.49,0),Vector3(0.25,0.85,0.13),Color("b3ecd0"),Vector3(PI*0.5,0,0.24))
		stitch.visible = false
		stitches.append(stitch)
	var cells: Array[Dictionary] = []
	for z in range(4):
		for x in range(5):
			var local := Vector3((x-2)*0.81,0.35,(z-1.5)*0.82)
			var stain := Art.sphere(site,"Grime_%d_%d" % [x,z],local,Vector3(1.02,0.19,1.02),Color("65722d") if (x+z)%3 == 0 else Color("754738"))
			stain.rotation.y = (x*13+z*7)*0.37
			stain.scale.x *= 1.0+sin(x*7.1+z*2.3)*0.11
			cells.append({"mesh":stain,"dirt":1.0,"base":stain.scale})
	var package := Node3D.new()
	site.add_child(package)
	package.position = Vector3(0,0.8,0)
	for i in range(5):
		Art.capsule(package,"FoodBlock",Vector3(sin(i*2.3)*0.5,cos(i*1.7)*0.25,cos(i*2.3)*0.4),Vector3(0.6,1.0,0.6),Color("b68c54"),Vector3(0.8,i*1.4,0.4))
	package.visible = kind == "cargo"
	var disposal := _station("医疗废物箱",site.position+Vector3(7,0,0),Color("71b8b1")) if kind == "cargo" else null
	_cross(site,Vector3(-2.7,1.4,0),1.3)
	var label := _label(site,title+"\n待诊断 · 长按 F",Vector3(0,2.35,0),Color("a4f3d3"))
	sites.append({"root":site,"title":title,"desc":desc,"kind":kind,"specialist":specialist,"stage":"scan","scan":0.0,"cells":cells,"tissue":tissue,"wound":wound,"stitches":stitches,"package":package,"bin":disposal,"hits":0,"last_pulse":-1,"label":label})

func _build_fishing(authored: Vector3, water: Vector3) -> void:
	var stand := _station("胃酸钓宝 · F\n鱼饵 3 C / 6 次",game.world_point(authored),Color("79d8ec"))
	var bobber := Art.sphere(self,"AcidBobber",game.world_point(water),Vector3(0.5,0.6,0.5),Color("ffca68"))
	bobber.visible = false
	var line := Art.cylinder(self,"FishingLine",Vector3.ZERO,Vector3.ONE,Color("e9dfbc"))
	line.visible = false
	Art.capsule(stand,"FishingRod",Vector3(0.5,1.5,0),Vector3(0.09,1.5,0.09),Color("e6c48e"),Vector3(0,0,-0.35))
	fishing_spots.append({"root":stand,"bobber":bobber,"water":bobber.position,"line":line,"left":6})

func decorate_role() -> void:
	if not enabled: return
	var old: Node = game.character_visual.get_node_or_null("ClinicKit")
	if is_instance_valid(old):
		game.character_visual.remove_child(old)
		old.queue_free()
	var kit := Node3D.new()
	kit.name = "ClinicKit"
	game.character_visual.add_child(kit)
	_cross(kit,Vector3(0.0,0.92,-0.41),0.4)
	var color: Color = game.ROLE_COLORS[game.role_index]
	Art.capsule(kit,"MedicalBackpack",Vector3(0,0.87,0.33),Vector3(0.48,0.43,0.22),color.darkened(0.23))
	match int(game.role_index):
		0: Art.torus(kit,"ScannerCoil",Vector3(0.26,0.92,0.34),Vector3.ONE*0.12,Color("ffea8c"),Vector3(PI*0.5,0,0))
		1: Art.capsule(kit,"CarryBrace",Vector3(0.27,0.83,0.29),Vector3(0.10,0.61,0.12),Color("fff0cc"))
		2:
			for x in [-0.14,0.14]: Art.capsule(kit,"FoamTank",Vector3(x,0.91,0.43),Vector3(0.20,0.38,0.19),Color("a6fff0"))
		3: Art.sphere(kit,"HealingBud",Vector3(0.18,1.11,0.37),Vector3(0.28,0.18,0.27),Color("c7f4ac"))

func active() -> bool:
	return enabled and game.role_selected and not game.game_paused and game.ko_time <= 0.0 and not game.mouth_intro.active and game.mission_phase in ["diagnose","chase","return"]

func _process(delta: float) -> void:
	if not enabled: return
	visible = not game.mouth_intro.active and game.mission_phase in ["diagnose","chase","return"]
	if not active():
		if is_instance_valid(work_audio): work_audio.stop()
		if not game.game_paused:
			_cancel_fishing()
			if cargo_site >= 0: drop_cargo()
		last_held = true
		spray.visible = false
		for item in foam: item.visible = false
		return
	clock += delta
	sound_lock = maxf(0.0,sound_lock-delta)
	clean_flash = maxf(0.0,clean_flash-delta)
	if clean_flash<=0.0: clean_streak = 0
	spray_time = maxf(0.0,spray_time-delta)
	spray.visible = spray_time > 0.0
	for item in foam: item.visible = spray.visible
	if cargo_site >= 0:
		var package: Node3D = sites[cargo_site].package
		package.global_position = game.player.global_position+game._forward()*1.45+Vector3.UP*0.95
		package.rotation.y = game.yaw
	if game.role_index == 2 and game.bubble_roll_time > 0.0:
		for i in range(sites.size()):
			if sites[i].stage == "clean": clean_at(i,game.player.global_position,1.8+levels[2]*0.2,delta*2.8)
	_tick_fishing(delta)
	for site in sites:
		var wound: MeshInstance3D = site.wound
		wound.scale.y = 0.30*(1.0+sin(clock*(2.0 if site.stage=="healthy" else 5.0))*0.1)

func _flat_distance(a: Vector3, b: Vector3) -> float:
	if absf(a.y-b.y) > 2.4: return 9999.0
	return Vector2(a.x,a.z).distance_to(Vector2(b.x,b.z))

func _start_action(key: String) -> void:
	if action_key != key:
		action_key = key
		hold_progress = 0.0

func _prompt(text: String, ratio := -1.0) -> void:
	hint = text
	game.interact_label.text = text
	game.interact_label.add_theme_color_override("font_color",Color("b2ffe1"))
	game.capture_bar.visible = ratio >= 0.0
	game.capture_bar.value = clampf(ratio,0.0,1.0)
	game.crosshair.scale = Vector2.ONE
	game.interact_progress = 0.0
	game.interact_action_key = "clinic"

func handle_interaction(delta: float, held: bool) -> bool:
	if not active(): return false
	var pressed := held and not last_held
	last_held = held
	context_site = -1
	if not held: hold_progress = 0.0
	if fish_site >= 0:
		_prompt("钓宝：绿区按 F 收线 · 移开取消 · 失误 %d/3" % fish_tension)
		if fish_state == "waiting": _prompt("已抛竿… 等浮漂下沉再按 F（现在按会收竿）")
		if pressed: fish_press()
		return true
	if cargo_site >= 0:
		var bin_node: Node3D = sites[cargo_site].bin
		var at_bin := _flat_distance(game.player.global_position,bin_node.global_position) < 2.5
		_prompt("按 F：投入医疗废物箱" if at_bin else "搬运中 · 前往绿色废物箱 · F 放回原位")
		if pressed:
			if at_bin: dispose_cargo()
			else: drop_cargo()
		return true
	if _flat_distance(game.player.global_position,recycle.global_position) < 2.0:
		_prompt("按 F：出售背包 %d 件 / %d C（任务老鼠不会出售）" % [bag.size(),bag_value()])
		if pressed: sell_bag()
		return true
	if _flat_distance(game.player.global_position,upgrade.global_position) < 2.0:
		var tier: int = levels[game.role_index]
		_prompt("职业已满级 · Lv.3" if tier>=3 else "按 F 强化 %d C · %s" % [COSTS[tier],PERKS[game.role_index]])
		if pressed: buy_upgrade()
		return true
	for i in range(fishing_spots.size()):
		if _flat_distance(game.player.global_position,fishing_spots[i].root.global_position) < 2.2:
			_prompt("F 抛竿：鱼饵 3 C · 剩余 %d 次 · 背包 %d/8" % [fishing_spots[i].left,bag.size()])
			if pressed: start_fishing(i)
			return true
	for i in range(sites.size()):
		var site: Dictionary = sites[i]
		if _flat_distance(game.player.global_position,site.root.global_position) > 4.4: continue
		context_site = i
		_start_action("site%d:%s" % [i,site.stage])
		match String(site.stage):
			"scan":
				var duration := 0.55 if game.role_index == 0 else 1.4
				if held: hold_progress += delta
				_prompt("长按 F 诊断：%s · 闪仔扫描更快" % site.title,hold_progress/duration)
				if hold_progress >= duration:
					site.stage = "clean"
					_update_site_label(i)
					game._toast("确诊："+site.desc+" · 先清洗病灶",Color("a1ffe0"),3.0)
			"clean":
				_prompt("长按 F 冲洗 · 移动/转向覆盖污渍 · 泡泡滚动也能清洁",clean_fraction(i))
				if held: wash(i,delta)
			"care":
				if site.kind == "cargo":
					_prompt("按 F 搬走堵塞物 · 咔咔搬运不减速")
					if pressed: pickup_cargo(i)
				else:
					_prompt("绿区按 F：%s  %d/3 · %s更擅长" % ["敷菌疗贴" if site.kind=="ulcer" else "校准神经",site.hits,JOBS[site.specialist]])
					if pressed: care_press(i)
			"healthy":
				_prompt("已治愈 ✓ %s · 胃酸压力降低，痉挛间隔延长" % site.title)
		return true
	action_key = ""
	hint = "绿色十字：救助站  ·  蓝点：胃酸钓宝"
	return false

func clean_fraction(index: int) -> float:
	var dirt := 0.0
	for cell in sites[index].cells: dirt += float(cell.dirt)
	return 1.0-dirt/float(sites[index].cells.size())

func wash(index: int, delta: float) -> void:
	var root_pos: Vector3 = sites[index].root.global_position
	var target: Vector3 = game.player.global_position+game._forward()*1.7
	var camera: Camera3D = game.camera_1p if game.first_person else game.camera_3p
	var origin := camera.global_position
	var direction := -camera.global_basis.z
	if direction.y < -0.08:
		var t := (root_pos.y+0.35-origin.y)/direction.y
		var aimed := origin+direction*t
		if t>0.0 and _flat_distance(aimed,game.player.global_position)<3.8: target = aimed
	target.y = root_pos.y+0.35
	var expert: bool = game.role_index == 2
	var radius := 1.25+levels[2]*0.16 if expert else 0.85
	clean_at(index,target,radius,delta*(2.2 if expert else 1.0))
	var right: Vector3 = game._forward().cross(Vector3.UP)
	var start: Vector3 = game.player.global_position+Vector3.UP*0.92+right*0.64+game._forward()*0.25
	_line(spray,start,target,0.22 if expert else 0.12)
	spray_time = 0.08
	for i in range(foam.size()):
		var f := float(i)/foam.size()
		foam[i].global_position = start.lerp(target,f)+Vector3(sin(clock*13+i)*0.16,cos(clock*11+i)*0.12,0)
		foam[i].scale = Vector3.ONE*(0.19+f*0.18)

func clean_at(index: int, pos: Vector3, radius: float, amount: float) -> int:
	if index<0 or index>=sites.size() or sites[index].stage != "clean" or amount<=0.0: return 0
	var changed := 0
	for cell in sites[index].cells:
		var stain: MeshInstance3D = cell.mesh
		if float(cell.dirt)<=0.0 or stain.global_position.distance_to(pos)>radius: continue
		cell.dirt = maxf(0.0,float(cell.dirt)-amount)
		stain.scale = (cell.base as Vector3)*maxf(0.01,sqrt(float(cell.dirt)))
		stain.visible = float(cell.dirt)>0.0
		if not stain.visible:
			clean_cells += 1
			game.credits += 1
			changed += 1
	if changed>0:
		clean_streak += changed
		clean_flash = 1.2
		_chime()
	if clean_fraction(index) >= 0.9999:
		sites[index].stage = "care"
		_update_site_label(index)
		game._toast("清洁完成！粉红组织露出来了 · 继续处理病因",Color("a5fff0"),2.5)
	return changed

func needle() -> float:
	return fposmod(clock*0.58,1.0)

func care_window(index: int) -> Vector2:
	var expert: bool = game.role_index == sites[index].specialist
	return Vector2(0.28,0.74) if expert else Vector2(0.42,0.66)

func care_press(index: int) -> bool:
	if sites[index].stage != "care" or sites[index].kind == "cargo": return false
	var pulse := int(floor(clock*0.58))
	if int(sites[index].last_pulse)==pulse: return false
	var window := care_window(index)
	if needle()<window.x or needle()>window.y:
		game._toast("慢一点，跟着组织的脉搏按 F · 已完成的治疗不会丢失",Color("ffe5a0"),1.4)
		return false
	sites[index].hits = mini(3,int(sites[index].hits)+1)
	sites[index].last_pulse = pulse
	_chime(true)
	var patch: MeshInstance3D = sites[index].stitches[sites[index].hits-1]
	patch.visible = true
	game._toast("治疗成功 %d/3 · 病灶正在闭合" % sites[index].hits,Color("b3ffd5"),1.2)
	if sites[index].hits >= 3: complete_site(index)
	return true

func pickup_cargo(index: int) -> bool:
	if cargo_site>=0 or sites[index].stage!="care" or sites[index].kind!="cargo": return false
	cargo_site = index
	return true

func drop_cargo() -> void:
	if cargo_site<0: return
	var package: Node3D = sites[cargo_site].package
	package.position = Vector3(0,0.8,0)
	package.rotation = Vector3.ZERO
	cargo_site = -1

func dispose_cargo() -> bool:
	if cargo_site<0: return false
	var index := cargo_site
	if _flat_distance(game.player.global_position,sites[index].bin.global_position)>2.5: return false
	cargo_site = -1
	sites[index].package.visible = false
	complete_site(index)
	return true

func movement_multiplier() -> float:
	return 1.0 if cargo_site<0 or game.role_index==1 else 0.65

func complete_site(index: int) -> void:
	if sites[index].stage != "care": return
	if sites[index].kind != "cargo" and int(sites[index].hits)<3: return
	if sites[index].kind == "cargo" and sites[index].package.visible: return
	sites[index].stage = "healthy"
	completed += 1
	game.credits += 30
	game.hp = minf(100.0,game.hp+25.0)
	game.acid_next = maxf(game.acid_next,14.0)
	game.spasm_next = maxf(game.spasm_next,12.0)
	_chime(true)
	(sites[index].wound.material_override as StandardMaterial3D).albedo_color = Color("edb0ba")
	_update_site_label(index)
	game._toast("救助成功！%s · +30 C · 恢复 25 HP · 身体压力下降" % sites[index].title,Color("a4ffcb"),3.5)

func _update_site_label(index: int) -> void:
	var site: Dictionary = sites[index]
	var status := "冲洗污渍" if site.stage=="clean" else ("处理病因" if site.stage=="care" else "已治愈 ✓")
	site.label.text = site.title+"\n"+status

func _line(mesh: MeshInstance3D, a: Vector3, b: Vector3, width: float) -> void:
	var direction := b-a
	if direction.length()<0.001: return
	mesh.global_position = (a+b)*0.5
	mesh.quaternion = Quaternion(Vector3.UP,direction.normalized())
	mesh.scale = Vector3(width,direction.length(),width)

func start_fishing(index: int) -> bool:
	if not active() or fish_site>=0 or index<0 or index>=fishing_spots.size(): return false
	if _flat_distance(game.player.global_position,fishing_spots[index].root.global_position)>2.2: return false
	if bag.size()>=8 or game.credits<3 or fishing_spots[index].left<=0:
		game._toast("背包已满 / 鱼饵不足 / 此处已钓空 · 去救助或回收站",Color("ffe4a2"),2.0)
		return false
	game.credits -= 3
	fishing_spots[index].left -= 1
	var sign_label: Label3D = fishing_spots[index].root.get_meta("label")
	sign_label.text = "胃酸钓宝 · F\n鱼饵 3 C / 剩余 %d 次" % fishing_spots[index].left
	fish_site = index
	fish_state = "waiting"
	fish_clock = 0.0
	fish_bite_delay = rng.randf_range(1.3,2.7)
	fish_hits = 0
	fish_tension = 0
	fishing_spots[index].bobber.visible = true
	fishing_spots[index].line.visible = true
	return true

func _tick_fishing(delta: float) -> void:
	if fish_site<0: return
	if _flat_distance(game.player.global_position,fishing_spots[fish_site].root.global_position)>3.0:
		_cancel_fishing()
		game._toast("离开钓位，已收竿（鱼饵不退回）",Color("ffe4b3"),1.5)
		return
	fish_clock += delta
	if fish_state=="waiting" and fish_clock>=fish_bite_delay:
		fish_state = "reel"
		fish_clock = 0.0
		game._toast("咬钩！绿区按 F，三次成功拉上来",Color("a6f4ff"),2.2)
	if fish_state=="reel" and fish_clock>9.0:
		_cancel_fishing()
		game._toast("鱼线松了，宝贝溜走了",Color("ffe4b3"),1.5)
		return
	var spot: Dictionary = fishing_spots[fish_site]
	var surface: Vector3 = spot.water
	surface.y = game.acid_mesh.global_position.y+0.18+sin(clock*6.0)*0.10-(0.08 if fish_state=="reel" else 0.0)
	spot.bobber.position = surface
	_line(spot.line,spot.root.global_position+Vector3(0.5,2.4,0),spot.bobber.global_position,0.025)

func fish_press() -> bool:
	if fish_site<0: return false
	if fish_state=="waiting":
		_cancel_fishing()
		return false
	var value := fposmod(fish_clock*0.65,1.0)
	if value<0.28 or value>0.68:
		fish_tension += 1
		if fish_tension>=3:
			_cancel_fishing()
			game._toast("脱钩了！等指针进绿色区域再收线",Color("ffe4a2"),2.0)
		return false
	fish_hits += 1
	# Restart the timing cycle: spamming F inside one window cannot reel instantly.
	fish_clock = 0.0
	if fish_hits>=3:
		var roll := rng.randi_range(0,99)
		var id := 0 if roll<25 else (1 if roll<52 else (2 if roll<77 else (3 if roll<94 else 4)))
		bag.append(LOOT[id].duplicate())
		fish_caught += 1
		_chime(true)
		game._toast("钓到了：%s！回收价值 %d C · 去 BODY MART 出售" % [LOOT[id].name,LOOT[id].value],Color("ffeb9d"),3.0)
		_cancel_fishing()
	return true

func _cancel_fishing() -> void:
	if fish_site>=0:
		fishing_spots[fish_site].bobber.visible = false
		fishing_spots[fish_site].line.visible = false
	fish_site = -1
	fish_state = "idle"

func bag_value() -> int:
	var total := 0
	for item in bag: total += int(item.value)
	return total

func sell_bag() -> int:
	if not active() or _flat_distance(game.player.global_position,recycle.global_position)>2.0: return 0
	var value := bag_value()
	bag.clear()
	game.credits += value
	sold_value += value
	if value>0: _chime(true)
	game._toast("回收完成 +%d C · 背包已清空" % value,Color("ffe8a0"),1.8)
	return value

func buy_upgrade() -> bool:
	if not active() or _flat_distance(game.player.global_position,upgrade.global_position)>2.0: return false
	var role: int = game.role_index
	var tier: int = levels[role]
	if tier>=3 or game.credits<COSTS[tier]:
		game._toast("已满级" if tier>=3 else "BioCoins 不足：先救助或钓宝回收",Color("ffe4b3"),1.5)
		return false
	game.credits -= COSTS[tier]
	levels[role] += 1
	_chime(true)
	game._toast("%s Lv.%d · 冷却恢复更快 · %s" % [JOBS[role],levels[role],PERKS[role]],Color("d4b7ff"),3.0)
	return true

func snapshot() -> Dictionary:
	var patients: Array[Dictionary] = []
	for i in range(sites.size()):
		patients.append({"stage":sites[i].stage,"clean":snappedf(clean_fraction(i),0.01),"hits":int(sites[i].hits)})
	var stocks: Array[int] = []
	for spot in fishing_spots: stocks.append(int(spot.left))
	return {"patients":patients,"completed":completed,"clean_cells":clean_cells,"cargo":cargo_site,"bag":bag.duplicate(true),"sold":sold_value,"levels":levels.duplicate(),"fishing_stock":stocks,"fish_state":fish_state}
