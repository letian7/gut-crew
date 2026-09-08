extends CanvasLayer
const NAMES = ["闪仔 SPARK","咔咔 KAKA","泡泡 BUBBLE","菇菇 SHROOM"]
const SKILLS = [["电弧连射","闪电疾行","导电标记","神经风暴"],["三段骨锤","蓄力骨钩","骨墙预览","骨甲冲撞"],["膨胀滚动","蓄力弹跳","分裂诱饵","吞吐炮"],["孢子弹","寄生操控","菌毯","发酵"]]
const INK := Color("f4e9d4")
var game
var root_ui: Control
var health_panel: Panel
var health: ProgressBar
var trail: ProgressBar
var health_number: Label
var identity: Label
var change_label: Label
var warning: Label
var statuses: Label
var revive: ProgressBar
var skills: Array[Dictionary] = []
var enemy_cards: Array[Dictionary] = []
var edge_panels: Array[ColorRect] = []
var last_hp := 100.0
var trail_hp := 100.0
var trail_delay := 0.0
var hit_time := 0.0
var change_time := 0.0
var change_amount := 0.0
var pulse := 0.0

func _style(color: Color, radius := 10) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	return style

func _label(parent: Control, pos: Vector2, size_v: Vector2, font := 17) -> Label:
	var label := Label.new()
	label.position = pos
	label.size = size_v
	label.add_theme_font_size_override("font_size",font)
	label.add_theme_color_override("font_color",INK)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _bar(parent: Control, pos: Vector2, size_v: Vector2, color: Color, background := true) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position = pos
	bar.size = size_v
	bar.max_value = 100
	bar.show_percentage = false
	bar.add_theme_font_size_override("font_size",1)
	bar.add_theme_constant_override("outline_size",0)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg := _style(Color("263a40") if background else Color.TRANSPARENT,2 if size_v.y<10 else 7)
	var fill := _style(color,2 if size_v.y<10 else 7)
	bg.set_content_margin_all(0)
	fill.set_content_margin_all(0)
	bar.add_theme_stylebox_override("background",bg)
	bar.add_theme_stylebox_override("fill",fill)
	parent.add_child(bar)
	bar.size = size_v
	# Theme minimum-size invalidation is deferred when the control enters the tree.
	bar.set_deferred("size",size_v)
	return bar

func build(host) -> void:
	game = host
	name = "CombatHUD23"
	layer = 12
	root_ui = Control.new()
	root_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_ui)
	root_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	health_panel = Panel.new()
	health_panel.size = Vector2(322,116)
	health_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	health_panel.add_theme_stylebox_override("panel",_style(Color(0.055,0.09,0.10,0.92),18))
	root_ui.add_child(health_panel)
	identity = _label(health_panel,Vector2(16,10),Vector2(292,26),18)
	trail = _bar(health_panel,Vector2(16,45),Vector2(290,24),Color("e9bd88"))
	health = _bar(health_panel,Vector2(16,45),Vector2(290,24),Color("80dfb1"),false)
	health_number = _label(health_panel,Vector2(22,44),Vector2(180,26),18)
	health_number.add_theme_color_override("font_outline_color",Color("24383b"))
	health_number.add_theme_constant_override("outline_size",3)
	change_label = _label(health_panel,Vector2(232,42),Vector2(70,28),22)
	change_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	change_label.add_theme_color_override("font_outline_color",Color("35272d"))
	change_label.add_theme_constant_override("outline_size",3)
	warning = _label(health_panel,Vector2(16,77),Vector2(292,27),16)
	revive = _bar(health_panel,Vector2(16,104),Vector2(290,5),Color("c4a4ee"))
	statuses = _label(root_ui,Vector2.ZERO,Vector2(470,50),16)
	statuses.add_theme_color_override("font_outline_color",Color("253038"))
	statuses.add_theme_constant_override("outline_size",3)
	for i in range(4):
		var panel := Panel.new()
		panel.size = Vector2(114,88)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_theme_stylebox_override("panel",_style(Color(0.055,0.09,0.10,0.92),14))
		root_ui.add_child(panel)
		var key := _label(panel,Vector2(10,5),Vector2(94,23),15)
		key.text = ["LMB","RMB","Q","E"][i]
		var title := _label(panel,Vector2(10,29),Vector2(100,22),16)
		var state := _label(panel,Vector2(10,54),Vector2(100,22),14)
		var fill := _bar(panel,Vector2(10,80),Vector2(94,4),Color("80dfb1"))
		skills.append({"panel":panel,"key":key,"title":title,"state":state,"bar":fill})
	for i in range(8):
		var panel := Control.new()
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.size = Vector2(120,42)
		root_ui.add_child(panel)
		var label := _label(panel,Vector2(0,0),Vector2(120,18),12)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_constant_override("outline_size",3)
		var ghost := _bar(panel,Vector2(15,20),Vector2(90,6),Color("ebc6a0"))
		var fill := _bar(panel,Vector2(15,20),Vector2(90,6),Color("ef9c9a"),false)
		var status := _label(panel,Vector2(-15,27),Vector2(150,18),12)
		status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		status.add_theme_constant_override("outline_size",3)
		enemy_cards.append({"panel":panel,"name":label,"trail":ghost,"bar":fill,"status":status,"id":0,"hp":100.0})
	for i in range(4):
		var edge := ColorRect.new()
		edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		edge.color = Color(0.8,0.17,0.24,0)
		root_ui.add_child(edge)
		edge_panels.append(edge)
	game.status_label.modulate.a = 0.0
	game.help_label.position.y = 692
	game.help_label.add_theme_font_size_override("font_size",13)
	last_hp = game.hp
	trail_hp = game.hp
	tick(0)

func _process(delta: float) -> void:
	tick(delta)

func tick(delta: float) -> void:
	if not is_instance_valid(game): return
	var cinematic: bool = game.mission_phase in ["escape","ending","win"] or (is_instance_valid(game.host_boss) and game.host_boss.state == "toy_intro")
	root_ui.visible = game.role_selected and not game.game_paused and not cinematic
	if game.game_paused: return
	if not root_ui.visible:
		last_hp = game.hp
		trail_hp = game.hp
		hit_time = 0.0
		change_time = 0.0
		return
	pulse += delta
	var size_v: Vector2 = get_viewport().get_visible_rect().size
	health_panel.position = Vector2(18,size_v.y-154)
	statuses.position = Vector2(18,size_v.y-210)
	for i in range(4): skills[i].panel.position = Vector2(size_v.x-498+float(i)*120,size_v.y-126)
	var current: float = clampf(game.hp,0.0,100.0)
	var difference := current-last_hp
	if not is_zero_approx(difference):
		if change_time <= 0.0 or signf(change_amount) != signf(difference): change_amount = 0.0
		change_amount += difference
		change_time = 0.8
		if difference < 0:
			hit_time = 0.32
			trail_delay = 0.35
		else:
			trail_hp = current
		last_hp = current
	hit_time = maxf(0.0,hit_time-delta)
	change_time = maxf(0.0,change_time-delta)
	trail_delay = maxf(0.0,trail_delay-delta)
	if trail_delay <= 0: trail_hp = move_toward(trail_hp,current,65.0*delta)
	health.value = current
	trail.value = maxf(current,trail_hp)
	health_number.text = "%d / 100" % int(ceil(current))
	identity.text = "%s Lv.%d · %d C" % [NAMES[game.role_index],game.role_upgrade_level(),game.credits]
	change_label.visible = change_time > 0
	change_label.text = ("+" if change_amount > 0 else "−")+str(int(ceil(absf(change_amount))))
	change_label.modulate = Color("98efc1") if change_amount > 0 else Color("ffb2aa")
	change_label.modulate.a = clampf(change_time*3,0,1)
	var color := Color("ee857e") if current <= 30 else Color("80dfb1")
	(health.get_theme_stylebox("fill") as StyleBoxFlat).bg_color = color
	var knocked: bool = game.ko_time > 0 or current <= 0
	warning.text = "倒地 · 自动重捏 %.1fs" % game.ko_time if knocked else "血量危险 · 找掩护！" if current <= 30 else "安全  |  SYNC %d · 倒地 %d" % [game.synergies,game.defeats]
	warning.modulate = Color("e0c7ff") if knocked else Color("ffba99") if current <= 30 else Color("a7c8c5")
	revive.visible = knocked
	revive.value = clampf(1.0-game.ko_time/0.85,0.0,1.0)*100
	var alpha := minf(0.17,hit_time*0.50)
	if current > 0 and current <= 30: alpha = maxf(alpha,0.035+0.035*(0.5+0.5*sin(pulse*3.0)))
	for i in range(4): edge_panels[i].color.a = alpha
	edge_panels[0].position = Vector2.ZERO
	edge_panels[0].size = Vector2(size_v.x,8)
	edge_panels[1].position = Vector2(0,size_v.y-8)
	edge_panels[1].size = Vector2(size_v.x,8)
	edge_panels[2].position = Vector2.ZERO
	edge_panels[2].size = Vector2(8,size_v.y)
	edge_panels[3].position = Vector2(size_v.x-8,0)
	edge_panels[3].size = Vector2(8,size_v.y)
	_update_statuses()
	_update_skills()
	_update_enemies(delta)

func _update_statuses() -> void:
	var tags: Array[String] = []
	for entry in [["抗酸",game.acid_umbrella_time],["加速汽水",game.plasma_soda_time],["猫薄荷",game.catnip_time],["发酵",game.ferment_time],["无敌",game.invuln]]:
		if float(entry[1]) > 0.05: tags.append("%s %.1fs" % [entry[0],entry[1]])
	if game.mouse_caught and game.mission_phase == "return": tags.append("携带电子老鼠")
	if is_instance_valid(game.bubble_payload): tags.append("已吞入 · E 吐出")
	if game.spark_mark_time > 0: tags.append("标记 %.1fs · Q 瞬移" % game.spark_mark_time)
	statuses.text = "  ·  ".join(tags.slice(0,3))
	if tags.size()>3: statuses.text += "\n"+"  ·  ".join(tags.slice(3,6))

func _update_skills() -> void:
	var cooldowns: Array = [game.primary_attack_cd,game.secondary_attack_cd,game.skill_q_cd,game.skill_e_cd]
	var maximums: Array = [game.PRIMARY_ATTACK_COOLDOWNS[game.role_index],game.SECONDARY_ATTACK_COOLDOWNS[game.role_index],game.Q_COOLDOWNS[game.role_index],game.E_COOLDOWNS[game.role_index]]
	for i in range(4):
		var card := skills[i]
		var cd: float = maxf(0.0,cooldowns[i])
		card.title.text = SKILLS[game.role_index][i]
		card.state.text = "就绪" if cd <= 0 else "%.1fs" % cd
		card.bar.value = (1.0-clampf(cd/maximums[i],0,1))*100
		card.state.modulate = Color("94e5bd") if cd <= 0 else Color("d9baa0")
	if game.ko_time > 0.0:
		for card in skills:
			card.state.text = "重捏中"
			card.bar.value = 0
		return
	if game.primary_hold and game.role_index == 1:
		skills[0].state.text = "蓄力 ×%d" % game.kaka_charge_nails if game.kaka_hammer_stage <= 0 else "骨锤 %d/3段" % game.kaka_hammer_stage
		skills[0].bar.value = game.kaka_charge_time/1.8*100
	elif game.primary_hold and game.role_index == 2:
		skills[0].state.text = "膨胀 %d%%" % int(game.bubble_roll_charge*100)
		skills[0].bar.value = game.bubble_roll_charge*100
	elif game.primary_hold:
		skills[0].state.text = "连续发射"
	if game.secondary_hold:
		if game.role_index == 1:
			skills[1].state.text = "钩锁瞄准 %d%%" % int(game.kaka_hook_charge*100)
			skills[1].bar.value = game.kaka_hook_charge*100
		elif game.role_index == 2:
			skills[1].state.text = "蓄跳 %d%%" % int(game.bubble_jump_charge*100)
			skills[1].bar.value = game.bubble_jump_charge*100
	if game.role_index == 1 and is_instance_valid(game.kaka_wall_preview): skills[2].state.text = "再次 Q 放置"
	if game.role_index == 1 and game.kaka_armor_time > 0: skills[3].state.text = "骨甲 %.1fs" % game.kaka_armor_time
	if game.role_index == 0 and game.spark_mark_time > 0: skills[2].state.text = "再按 Q 瞬移"
	if game.role_index == 2 and is_instance_valid(game.bubble_payload): skills[3].state.text = "E 吐出"

func _update_enemies(delta: float) -> void:
	for card in enemy_cards: card.panel.visible = false
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null: return
	var candidates: Array = []
	for enemy in game.enemies:
		if not is_instance_valid(enemy) or enemy.get_meta("dead",false) or not enemy.is_visible_in_tree(): continue
		if enemy == game.mouse_target or enemy.get_meta("host_boss",false): continue
		var old_label: Label3D = enemy.get_meta("hp_label",null)
		if old_label:
			old_label.modulate.a = 0.0
			old_label.visible = false
		var distance: float = game.player.position.distance_to(enemy.position)
		if distance > 14.0: continue
		var p: Vector3 = enemy.global_position+Vector3.UP*(2.25 if enemy.get_meta("kind","") == "PARASITE" else 1.85)
		if camera.is_position_behind(p): continue
		var screen := camera.unproject_position(p)
		var size_v: Vector2 = get_viewport().get_visible_rect().size
		if screen.x < 65 or screen.x > size_v.x-65 or screen.y < 175 or screen.y > size_v.y-210: continue
		candidates.append({"enemy":enemy,"distance":distance,"screen":screen})
	candidates.sort_custom(func(a,b):return a.distance < b.distance)
	for i in range(mini(8,candidates.size())):
		var entry: Dictionary = candidates[i]
		var enemy: CharacterBody3D = entry.enemy
		var card := enemy_cards[i]
		var ratio: float = clampf(float(enemy.get_meta("hp",0))/maxf(1.0,float(enemy.get_meta("max_hp",1))),0,1)*100
		if card.id != enemy.get_instance_id(): card.hp = ratio
		card.id = enemy.get_instance_id()
		card.hp = maxf(ratio,move_toward(card.hp,ratio,80.0*delta))
		card.bar.value = ratio
		card.trail.value = card.hp
		card.panel.visible = true
		card.panel.position = entry.screen-Vector2(60,42)
		var kind: String = enemy.get_meta("kind","")
		card.name.text = "%s %d/%d" % [{"HAIRBALL":"毛球","PLATELET":"血小板","PARASITE":"寄生虫"}.get(kind,kind),int(ceil(enemy.get_meta("hp",0))),int(enemy.get_meta("max_hp",1))]
		var tag := ""
		for state in [["controlled","操控"],["stun","麻痹"],["pinned","钉住"],["goo_slow","减速"]]:
			var time: float = enemy.get_meta(state[0],0.0)
			if time>0:
				tag = "%s %.1fs" % [state[1],time]
				break
		if float(enemy.get_meta("attack_windup",0))>0: tag = "蓄势！快闪避"
		card.status.text = tag
		card.status.modulate = Color("ffd18b") if "蓄势" in tag else Color("b9e8ed")
