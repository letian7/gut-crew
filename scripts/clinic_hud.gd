extends Control
var clinic
func build(system) -> void:
	clinic = system
	mouse_filter = MOUSE_FILTER_IGNORE
	position = Vector2(18,132)
	size = Vector2(252,192)
func _process(_delta: float) -> void:
	visible = clinic.active()
	if visible: queue_redraw()
func _draw() -> void:
	if not is_instance_valid(clinic): return
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035,0.085,0.085,0.88)
	style.border_color = Color("629f94")
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	draw_style_box(style,Rect2(Vector2.ZERO,size))
	var font := ThemeDB.fallback_font
	var role: int = clinic.game.role_index
	draw_string(font,Vector2(12,25),"急诊班 / CARE CREW",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("adf2d4"))
	draw_string(font,Vector2(12,49),"%s  Lv.%d" % [clinic.JOBS[role],clinic.levels[role]],HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("f7ead5"))
	draw_string(font,Vector2(12,72),"救助 %d/3   清洁 %d/60" % [clinic.completed,clinic.clean_cells],HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("c9e2d4"))
	draw_string(font,Vector2(12,95),"背包 %d/8 · 可卖 %d C" % [clinic.bag.size(),clinic.bag_value()],HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("ffe5a1"))
	var title := "绿十字救助 · 蓝点钓宝"
	var caption := "F 工作 / 1–4 换职业"
	var needle := -1.0
	var window := Vector2(0.28,0.68)
	if clinic.fish_site>=0:
		title = "等咬钩…" if clinic.fish_state=="waiting" else "收线 %d/3 · 失误 %d/3" % [clinic.fish_hits,clinic.fish_tension]
		caption = "绿色区域按 F · 移开收竿"
		if clinic.fish_state=="reel": needle = fposmod(clinic.fish_clock*0.65,1.0)
	elif clinic.context_site>=0:
		var site: Dictionary = clinic.sites[clinic.context_site]
		title = site.title
		if site.stage=="clean": caption = "清洁 %d%% · F 冲洗 / 泡泡滚动" % int(clinic.clean_fraction(clinic.context_site)*100)
		elif site.stage=="care" and site.kind!="cargo":
			caption = "治疗 %d/3 · 绿区按 F" % site.hits
			needle = clinic.needle()
			window = clinic.care_window(clinic.context_site)
		elif site.stage=="care": caption = "咔咔搬走异物 → 医疗废物箱"
		elif site.stage=="healthy": caption = "已治愈 ✓ 压力降低"
		else: caption = "长按 F 诊断 · 闪仔更快"
	draw_string(font,Vector2(12,121),title,HORIZONTAL_ALIGNMENT_LEFT,230,14,Color("a8f3dd"))
	draw_string(font,Vector2(12,145),caption,HORIZONTAL_ALIGNMENT_LEFT,230,12,Color("e7e4ce"))
	if needle>=0.0:
		var bar_pos := Vector2(get_viewport_rect().size.x*0.5-130,408)-position
		draw_style_box(style,Rect2(bar_pos-Vector2(5,5),Vector2(270,30)))
		draw_rect(Rect2(bar_pos,Vector2(260,20)),Color("3e5153"))
		draw_rect(Rect2(bar_pos+Vector2(260*window.x,0),Vector2(260*(window.y-window.x),20)),Color("6ed1a0"))
		draw_line(bar_pos+Vector2(260*needle,-4),bar_pos+Vector2(260*needle,24),Color.WHITE,3.0)
		draw_string(font,Vector2(12,176),"看屏幕中间 · 一次一收线/治疗",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("91a8a0"))
	else:
		draw_string(font,Vector2(12,176),"本局升级 · 不影响职业切换",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("91a8a0"))
	if clinic.clean_flash>0:
		var pop := Vector2(get_viewport_rect().size.x*0.5+70,368)-position
		draw_string(font,pop,"洁净 +%d  /  +%d C" % [clinic.clean_streak,clinic.clean_streak],HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("b3ffe4"))
