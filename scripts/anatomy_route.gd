extends Node3D
## Phase 29: anatomical, sequential route through one cat's digestive tract.
const Art = preload("res://scripts/organ_world_factory.gd")
const CHAPTERS = [
	{"title":"第一关 · 贲门黏膜室","goal":"检查被吞入的毛球样本"},
	{"title":"第二关 · 幽门窦","goal":"稳定痉挛并打开幽门"},
	{"title":"第三关 · 十二指肠弯道","goal":"确认异物去向，追踪电子老鼠"}
]
var game
var gates: Array[Dictionary] = []
var route_label: Label
var last_chapter := -1
var clock := 0.0
var enabled := true

func build(host) -> void:
	game = host
	name = "CatDigestiveRoute29"
	enabled = not (DisplayServer.get_name()=="headless" and float(game.world_scale)<2.0)
	set_meta("linear_route",true)
	set_meta("chapter_count",CHAPTERS.size())
	set_meta("anatomy_order",["mouth","pharynx","esophagus","cardia","gastric_body","pyloric_antrum","duodenum","colon_exit"])
	if not enabled:
		set_process(false)
		return
	_retheme_legacy_organs()
	_build_anatomy()
	_make_gate("PyloricAntrumGate",Vector3(0,2.7,-7.45),1,"幽门窦括约肌")
	_make_gate("DuodenumGate",Vector3(18,2.7,-4.45),2,"十二指肠入口")
	_build_ui()
	refresh(true)

func _retheme_legacy_organs() -> void:
	# Preserve old nodes for regression compatibility, but remove anatomically wrong lung imagery.
	for node in game.find_children("Alveolus*","MeshInstance3D",true,false):
		node.visible = false
	for node in game.find_children("SynapseNode*","MeshInstance3D",true,false):
		node.visible = false
	var old_bellows: Node = game.find_child("AlveoliBellows",true,false)
	if is_instance_valid(old_bellows): old_bellows.visible = false

func _label(text: String, pos: Vector3, color: Color, size_v := 24) -> Label3D:
	var label := Label3D.new()
	label.text = text
	label.position = game.world_point(pos)
	label.font_size = size_v
	label.pixel_size = 0.007
	label.outline_size = 7
	label.modulate = color
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.visibility_range_end = 65.0
	add_child(label)
	return label

func _build_anatomy() -> void:
	_label("食道末端 → 贲门\nESOPHAGUS → CARDIA",Vector3(0,5.8,12.5),Color("ffd0bd"),26)
	_label("胃体 · 消化与急诊中枢\nGASTRIC BODY",Vector3(0,5.3,1.0),Color("ffc0d0"),28)
	_label("幽门窦 · 蠕动增压区\nPYLORIC ANTRUM",Vector3(0,4.7,-11.2),Color("d9b8ff"),25)
	_label("十二指肠 · 胆汁汇入口\nDUODENUM",Vector3(18,4.5,-8.7),Color("ffd09f"),25)
	# Cardia and pylorus are thick circular muscle rings, not doors made of metal.
	for entry in [
		{"p":Vector3(0,3.0,10.7),"s":Vector3(3.1,3.1,0.55),"c":Color("d77b91"),"n":"CardiaMuscleRing"},
		{"p":Vector3(0,2.9,-7.55),"s":Vector3(2.9,2.9,0.60),"c":Color("ba6687"),"n":"PylorusMuscleRing"}]:
		var ring := Art.torus(self,entry.n,game.world_point(entry.p),entry.s,entry.c,Vector3(PI*0.5,0,0))
		ring.set_meta("digestive_anatomy",true)
	# Longitudinal esophageal folds guide the descent into the stomach.
	for i in range(8):
		var a := TAU*float(i)/8.0
		var p: Vector3 = game.world_point(Vector3(cos(a)*2.5,4.0,11.0+sin(a)*0.5))
		Art.capsule(self,"EsophagealFold%02d"%i,p,Vector3(0.20,2.8,0.20),Color("ce7890").lightened(float(i%2)*0.05))
	# Gastric rugae: broad, irregular folds that flatten toward the pylorus.
	for i in range(14):
		var x := -15.0+float(i)*2.3
		var z := 3.8+sin(float(i)*1.7)*1.3
		var fold := Art.capsule(self,"GastricRuga%02d"%i,game.world_point(Vector3(x,0.55,z)),Vector3(0.24*game.world_scale,0.22,2.4*game.world_scale),Color("c86d89"),Vector3(PI*0.5,0,0.15*sin(i)))
		fold.set_meta("digestive_anatomy",true)
	# Gastric pits and mucus beads make the mucosa readable without realistic gore.
	for z in range(4):
		for x in range(9):
			var p := Vector3(-16.0+x*4.0,0.34,-4.0+z*2.4)
			var pit := Art.sphere(self,"GastricPit29_%d_%d"%[x,z],game.world_point(p),Vector3(0.28,0.09,0.28),Color("8f3e68"))
			pit.set_meta("digestive_anatomy",true)
	# Duodenal villi and bile-marked ridges.
	for i in range(28):
		var col := i%7
		var row := i/7
		var p: Vector3 = game.world_point(Vector3(14.8+col*1.05,0.75,-11.4+row*1.45))
		var villus := Art.capsule(self,"DuodenalVillus%02d"%i,p,Vector3(0.20,0.52+0.08*(i%3),0.20),Color("e59aaa"))
		villus.rotation.z = sin(i*1.3)*0.18
	for i in range(6):
		Art.capsule(self,"BileRidge%02d"%i,game.world_point(Vector3(14.5+i*1.35,0.32,-6.2)),Vector3(0.16,0.12,1.2*game.world_scale),Color("9da94a"))

func _make_gate(id: String, authored: Vector3, unlock_count: int, title: String) -> void:
	var root := Node3D.new()
	root.name = id
	root.position = game.world_point(authored)
	add_child(root)
	var flaps: Array[Node3D] = []
	var width: float = 5.15*float(game.world_scale)
	for i in range(11):
		var x: float = -width*0.5+width*float(i)/10.0
		var flap := Art.capsule(root,"MuscleFlap%02d"%i,Vector3(x,0,0),Vector3(0.30*game.world_scale,2.45,0.32*game.world_scale),Color("b85d7c").lightened(0.025*(i%3)))
		flap.rotation.z = sin(float(i)*1.2)*0.06
		flaps.append(flap)
	var body := StaticBody3D.new()
	body.name = "LockedSphincterCollision"
	body.collision_layer = 5
	body.collision_mask = 0
	root.add_child(body)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(width,5.0,0.72*game.world_scale)
	collision.shape = shape
	body.add_child(collision)
	var label := Label3D.new()
	label.position = Vector3(0,3.5,0)
	label.font_size = 24
	label.pixel_size = 0.007
	label.outline_size = 7
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	root.add_child(label)
	gates.append({"root":root,"collision":collision,"flaps":flaps,"unlock":unlock_count,"title":title,"open":false,"label":label})

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 24
	add_child(layer)
	route_label = Label.new()
	route_label.position = Vector2(310,82)
	route_label.size = Vector2(660,38)
	route_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	route_label.add_theme_font_size_override("font_size",17)
	route_label.add_theme_color_override("font_color",Color("ffe3cd"))
	route_label.add_theme_color_override("font_outline_color",Color("301926"))
	route_label.add_theme_constant_override("outline_size",6)
	route_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(route_label)

func can_use_clue(index: int) -> bool:
	return game.mission_phase=="diagnose" and index==game._clue_count()

func refresh(initial := false) -> void:
	var chapter: int = mini(game._clue_count(),CHAPTERS.size())
	for i in range(game.clue_nodes.size()):
		game.clue_nodes[i].visible = game.mission_phase!="diagnose" or i<=chapter
	for gate in gates:
		var should_open: bool = chapter>=int(gate.unlock) or game.mission_phase!="diagnose"
		var collision: CollisionShape3D = gate.collision
		collision.set_deferred("disabled",should_open or not game.is_processing())
		for flap in gate.flaps: flap.visible = not should_open
		var label: Label3D = gate.label
		label.text = "%s\n%s" % [gate.title,"开放 ✓" if should_open else "完成上一关后开放"]
		label.modulate = Color("9fffd1") if should_open else Color("ffbd9f")
		if should_open and not bool(gate.open) and not initial:
			game._toast("关卡完成！%s 已舒张，下一段消化道开放" % gate.title,Color("a8ffe0"),3.0)
		gate.open = should_open
	if chapter!=last_chapter:
		last_chapter = chapter
		if chapter<CHAPTERS.size() and not initial:
			game._toast(CHAPTERS[chapter].title+" · "+CHAPTERS[chapter].goal,Color("ffe0b7"),3.0)
	if chapter<CHAPTERS.size():
		route_label.text = "猫体内路线  %d/3  ·  %s  ·  %s" % [chapter+1,CHAPTERS[chapter].title,CHAPTERS[chapter].goal]
	else:
		route_label.text = "消化道诊断完成  ·  幽门已开放  ·  追踪电子老鼠"

func _process(delta: float) -> void:
	if not is_instance_valid(game): return
	clock += delta
	visible = not game.mouth_intro.active and game.mission_phase not in ["host_boss","ending","win"]
	route_label.visible = game.role_selected and not game.game_paused and game.mission_phase in ["diagnose","chase","return"]
	if game.game_paused: return
	refresh()
	for i in range(gates.size()):
		if bool(gates[i].open): continue
		var root: Node3D = gates[i].root
		root.scale.y = 1.0+sin(clock*3.0+i)*0.04
