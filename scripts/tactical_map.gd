extends Control
const Terrain = preload("res://scripts/terrain_world.gd")
var game
var map_rect := Rect2(12,32,194,130)
var bounds := Rect2(-130,-90,260,180)
var dots: Array[Dictionary] = []
var refresh := 0.0
var stage := ""

func build(host) -> void:
	game = host
	name = "TacticalMap26"
	size = Vector2(218,188)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	tick(0.0)

func project_point(p: Vector3) -> Vector2:
	var normalized := (Vector2(p.x,p.z)-bounds.position)/bounds.size
	return map_rect.position+normalized*map_rect.size

func tick(delta: float) -> void:
	position = Vector2(get_viewport_rect().size.x-size.x-18,62)
	visible = game.role_selected and not game.game_paused and game.mission_phase in ["mouth","diagnose","chase","return","host_boss"]
	if not visible: return
	refresh -= delta
	if refresh > 0.0: return
	refresh = 0.10
	dots.clear()
	stage = "mouth" if game.mouth_intro.active else ("boss" if game.mission_phase == "host_boss" else "body")
	if stage == "mouth":
		bounds = Rect2(-6*game.world_scale,33*game.world_scale,12*game.world_scale,35*game.world_scale)
		dots.append({"pos":game.world_point(Vector3(0,0,35)),"kind":"goal"})
	elif stage == "boss":
		bounds = Rect2(-11,-8,22,18)
		if is_instance_valid(game.host_boss): dots.append({"pos":game.host_boss.target.position,"kind":"boss"})
	else:
		bounds = Rect2(-26*game.world_scale,-18*game.world_scale,52*game.world_scale,36*game.world_scale)
		for e in game.enemies:
			if not is_instance_valid(e) or e.get_meta("dead",false) or e.get_meta("engulfed",false): continue
			if not bounds.has_point(Vector2(e.position.x,e.position.z)): continue
			var kind := "enemy"
			if e == game.mouse_target: kind = "goal"
			elif float(e.get_meta("controlled",0.0)) > 0.0: kind = "ally"
			dots.append({"pos":e.position,"kind":kind})
		for i in range(game.clue_nodes.size()):
			if not game.clue_done[i]: dots.append({"pos":game.clue_nodes[i].position,"kind":"goal"})
		dots.append({"pos":game.entrance.position,"kind":"capsule"})
		dots.append({"pos":game.shop_root.position,"kind":"shop"})
		if is_instance_valid(game.clinic_system):
			for site in game.clinic_system.sites:
				if site.stage!="healthy": dots.append({"pos":site.root.global_position,"kind":"care"})
			for spot in game.clinic_system.fishing_spots:
				if spot.left>0: dots.append({"pos":spot.root.global_position,"kind":"fish"})
	queue_redraw()

func _process(delta: float) -> void:
	if is_instance_valid(game): tick(delta)

func _draw() -> void:
	if not is_instance_valid(game): return
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.045,0.07,0.085,0.92)
	style.set_corner_radius_all(14)
	style.border_color = Color("637475")
	style.set_border_width_all(1)
	draw_style_box(style,Rect2(Vector2.ZERO,size))
	var font := ThemeDB.fallback_font
	draw_string(font,Vector2(14,22),"小地图 · "+("猫嘴" if stage=="mouth" else ("巨猫" if stage=="boss" else "体内")),HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("eae5cf"))
	draw_rect(map_rect,Color("332b3b"))
	if stage == "body":
		for room in Terrain.ROOMS:
			var r: Rect2 = room.rect
			var a := project_point(game.world_point(Vector3(r.position.x,0,r.position.y)))
			var b := project_point(game.world_point(Vector3(r.end.x,0,r.end.y)))
			draw_rect(Rect2(a,b-a),Color("5f516a"))
		for link in Terrain.LINKS:
			draw_line(project_point(game.world_point(link.a)),project_point(game.world_point(link.b)),Color("958697"),3.0,true)
		var acid_start := project_point(game.world_point(Vector3(-6.2,0,2)))
		var acid_end := project_point(game.world_point(Vector3(6.2,0,7.6)))
		draw_rect(Rect2(acid_start,acid_end-acid_start),Color("6b7940"))
		draw_line(project_point(game.world_point(Vector3(-7,0,7))),project_point(game.world_point(Vector3(7,0,7))),Color("d6c5a3"),2.0,true)
	elif stage == "mouth":
		draw_line(map_rect.get_center()+Vector2(0,-55),map_rect.get_center()+Vector2(0,55),Color("a37685"),20,true)
	for dot in dots:
		var p := project_point(dot.pos).clamp(map_rect.position+Vector2.ONE*4,map_rect.end-Vector2.ONE*4)
		var color := Color("ff5363")
		match dot.kind:
			"goal": color = Color("ffdf73")
			"ally": color = Color("b691ff")
			"capsule": color = Color("73e7ed")
			"shop": color = Color("9deba4")
			"care": color = Color("a0ffcb")
			"fish": color = Color("76baff")
		draw_circle(p,4.8 if dot.kind == "boss" else 3.0,color)
		if dot.kind == "care":
			draw_line(p+Vector2(-4,0),p+Vector2(4,0),color,2.0)
			draw_line(p+Vector2(0,-4),p+Vector2(0,4),color,2.0)
	var p := project_point(game.player.position).clamp(map_rect.position+Vector2.ONE*5,map_rect.end-Vector2.ONE*5)
	var forward := Vector2(-sin(game.yaw),-cos(game.yaw))
	var right := Vector2(-forward.y,forward.x)
	draw_colored_polygon(PackedVector2Array([p+forward*6,p-forward*4+right*4,p-forward*4-right*4]),Color("efffff"))
	draw_string(font,Vector2(12,179),"红敌人 黄目标 绿救助 蓝钓宝",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("c7c6b8"))
