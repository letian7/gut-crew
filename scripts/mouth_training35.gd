extends Node3D
const FX = preload("res://scripts/skill_vfx.gd")
const Art = preload("res://scripts/clay_art.gd")
const LESSONS := [
	["01  欢迎加入急诊班","WASD 行走 · 鼠标看向四周\nShift 冲刺 · 沿舌面下行"],
	["02  越过湿滑组织","空格跳跃 · Ctrl 闪避\n落地后再次起跳"],
	["03  左右手工具","左键攻击 / 蓄力 · 右键副手\n咔咔：骨锤三段蓄力 + 骨钩"],
	["04  顶部牵绳练习","咔咔右键蓄力，瞄准顶部挂点\nWASD 摆荡 · 空格脱钩跳跃"],
	["05  分工才是急诊班","Q / E 职业技能 · 1—4 切职业\n泡泡清洁 / 菇菇治疗 / 咔咔搬运"],
	["06  整理后再出发","F 拾取补给 · Tab 查看和使用\n寻宝可卖钱，前往胃部小店升级"]]
var game
var mouth
var stations: Array[Node3D] = []
var pickups: Array[Dictionary] = []
var pockets := {"medkit":0,"soda":0}
var completed: Array[bool] = [false,false,false,false,false,false]
var prompt: Label
var last_f := false
var collected := 0
var start_position := Vector3.ZERO
var initial_inventory := 0

func box(parent: Node3D, label: String, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name=label
	var mesh := BoxMesh.new()
	mesh.size=size
	part.mesh=mesh
	part.position=pos
	part.material_override=Art.material(color)
	parent.add_child(part)
	return part

func text3(parent: Node3D, words: String, pos: Vector3, size: int, color: Color) -> Label3D:
	var label := Label3D.new()
	label.text=words
	label.font_size=size
	label.pixel_size=0.006
	label.position=pos
	label.modulate=color
	label.outline_size=5
	label.outline_modulate=Color("#12272c")
	label.visibility_range_end=19.0
	parent.add_child(label)
	return label

func build(g,m) -> void:
	game=g
	mouth=m
	name="MouthTraining35"
	for i in range(6):
		var z := 62.0-float(i)*2.0
		var side := -1.0 if i%2==0 else 1.0
		var station := Node3D.new()
		station.name="Lesson%02d" % (i+1)
		add_child(station)
		station.global_position=g.world_point(Vector3(0,m.floor_y(z)+0.15,z))+Vector3(side*3.1,0,0)
		box(station,"SoftSign",Vector3(0,1.8,0),Vector3(2.8,1.4,0.16),Color("#24454a"))
		box(station,"CreamBorder",Vector3(0,2.53,0),Vector3(2.9,0.09,0.20),Color("#efce90"))
		FX.cylinder(station,"Stand",Vector3.ZERO,Vector3.UP*1.2,0.085,Color("#e3c8a1"))
		text3(station,LESSONS[i][0],Vector3(0,2.14,0.10),42,Color("#ffe3a7"))
		text3(station,LESSONS[i][1],Vector3(0,1.61,0.10),30,Color("#d9f4ea"))
		stations.append(station)
		# One route marker opposite each board keeps the center lane readable.
		text3(self,"↓  沿舌面前进",g.world_point(Vector3(0,m.floor_y(z)+0.35,z-0.7)),30,Color("#9be6c5"))
	for spec in [[0,"medkit","急诊补胶包"],[1,"soda","血浆汽水"],[4,"coin","实习津贴 15C"],[5,"salvage","被吞下的瓶盖"]]:
		var index := int(spec[0])
		var pickup := Node3D.new()
		pickup.name="TrainingPickup_"+String(spec[1])
		add_child(pickup)
		pickup.global_position=stations[index].global_position+Vector3(0,0.45,0.8)
		box(pickup,"SupplyBox",Vector3.ZERO,Vector3(0.48,0.38,0.42),Color("#9ae6cd") if spec[1]=="medkit" else Color("#e9c68d"))
		box(pickup,"SealVertical",Vector3(0,0,0.22),Vector3(0.06,0.25,0.02),Color("#fff0d5"))
		box(pickup,"SealHorizontal",Vector3(0,0,0.23),Vector3(0.24,0.06,0.02),Color("#fff0d5"))
		text3(pickup,String(spec[2])+"\n[F] 拾取",Vector3(0,0.6,0),30,Color("#fff1bf"))
		pickups.append({"node":pickup,"kind":spec[1],"label":spec[2],"taken":false})
	var z := 56.0
	var ceiling: float = m.floor_y(z)+lerpf(9.0,5.7,(68.0-z)/18.0)*m.roof_lift
	var anchor := StaticBody3D.new()
	anchor.name="PalatePracticeAnchor"
	anchor.collision_layer=1
	add_child(anchor)
	anchor.global_position=g.world_point(Vector3(0,ceiling-0.18,z))
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size=Vector3(2.0,0.3,2.0)
	collision.shape=shape
	anchor.add_child(collision)
	box(anchor,"AnchorPad",Vector3.ZERO,shape.size,Color("#83d7b8"))
	FX.torus(anchor,"AnchorRing",Vector3(0,-0.2,0),Vector3.ONE*0.7,Color("#ffdb86"),1.0,0.2)
	text3(anchor,"抬头：牵绳练习挂点",Vector3(0,-0.6,0.9),36,Color("#ffecb4"))
	var layer := CanvasLayer.new()
	layer.layer=22
	add_child(layer)
	prompt=Label.new()
	prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	prompt.position=Vector2(-390,-210)
	prompt.size=Vector2(780,80)
	prompt.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override("font_size",19)
	prompt.add_theme_color_override("font_color",Color("#fff1c5"))
	prompt.add_theme_color_override("font_shadow_color",Color("#17282d"))
	prompt.add_theme_constant_override("shadow_offset_x",2)
	prompt.add_theme_constant_override("shadow_offset_y",2)
	prompt.mouse_filter=Control.MOUSE_FILTER_IGNORE
	layer.add_child(prompt)
	prompt.hide()

func reset() -> void:
	last_f=false
	start_position=game.world_point(mouth.SPAWN)
	initial_inventory=game.inventory_ui.opened_count

func hide_prompt() -> void:
	if is_instance_valid(prompt): prompt.hide()

func take(index: int) -> bool:
	if index<0 or index>=pickups.size() or pickups[index].taken: return false
	var item: Dictionary=pickups[index]
	if game.player.global_position.distance_to(item.node.global_position)>2.6: return false
	if item.kind=="salvage" and game.clinic_system.bag.size()>=8: return false
	match item.kind:
		"medkit","soda": pockets[item.kind]+=1
		"coin": game.credits+=15
		"salvage": game.clinic_system.bag.append({"name":"口腔找到的瓶盖","value":12})
	pickups[index].taken=true
	item.node.hide()
	collected+=1
	game._toast("已拾取："+String(item.label)+" · Tab 查看",Color("#a9f1d5"),2.0)
	return true

func use_supply(kind: String) -> bool:
	if int(pockets.get(kind,0))<=0: return false
	if kind=="medkit":
		if game.hp>=100.0: game._toast("血量已满，补胶包留着下次用",Color("#ffe2ab"),1.6); return false
		game.hp=minf(100.0,game.hp+35.0)
	elif kind=="soda": game.plasma_soda_time=maxf(game.plasma_soda_time,16.0)
	else: return false
	pockets[kind]-=1
	game._toast("补给已使用",Color("#a9f1d5"),1.6)
	return true

func tick(_delta: float) -> void:
	if not mouth.active or game.game_paused or game.inventory_open: hide_prompt(); return
	var pressed := Input.is_physical_key_pressed(KEY_F)
	var edge := pressed and not last_f
	last_f=pressed
	if game.player.global_position.distance_to(start_position)>2.0: completed[0]=true
	if Input.is_physical_key_pressed(KEY_SPACE): completed[1]=true
	if game.primary_attack_cd>0.0 or not game.kaka_hook_phase.is_empty(): completed[2]=true
	if game.kaka_hook_phase=="attached": completed[3]=true
	if game.skill_q_cd>0.0 or game.skill_e_cd>0.0: completed[4]=true
	if collected>0 and game.inventory_ui.opened_count>initial_inventory: completed[5]=true
	var nearest := -1
	var distance := 8.0
	for i in range(stations.size()):
		var d: float = game.player.global_position.distance_to(stations[i].global_position)
		if d<distance: nearest=i; distance=d
	prompt.visible=nearest>=0
	if nearest>=0:
		prompt.text=("✓ " if completed[nearest] else "练习：")+String(LESSONS[nearest][0])+"\n"+String(LESSONS[nearest][1])
	for i in range(pickups.size()):
		if not pickups[i].taken and game.player.global_position.distance_to(pickups[i].node.global_position)<2.6:
			prompt.show()
			prompt.text="[F] 拾取 "+String(pickups[i].label)+"  ·  [Tab] 物品栏\n补给可留到受伤或战斗时使用"
			if edge: take(i)
			break
