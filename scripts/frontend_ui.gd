extends RefCounted

const INK := Color("#fff5dc")
const MUTED := Color("#d5b6c8")
const PLUM := Color("#351025")
const CARD := Color("#551b3f")
const CARD_DARK := Color("#2a0d25")
const PINK := Color("#ff668f")
const YELLOW := Color("#ffd83f")
const CYAN := Color("#63dcff")
const GREEN := Color("#8dec95")

static func _box(color: Color, radius := 18, border_color := Color.TRANSPARENT, border := 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_width_left = border
	style.border_width_top = border
	style.border_width_right = border
	style.border_width_bottom = border
	style.border_color = border_color
	style.shadow_color = Color(0.05, 0.01, 0.04, 0.55)
	style.shadow_size = 12
	return style
static func _label(parent: Control, text: String, pos: Vector2, size: Vector2, font_size: int, color := INK, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.size = size
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color("#22091c"))
	label.add_theme_constant_override("outline_size", 5)
	parent.add_child(label)
	return label

static func _button(parent: Control, text: String, pos: Vector2, size: Vector2, callback: Callable, accent := YELLOW) -> Button:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = size
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", Color("#27101e"))
	button.add_theme_color_override("font_hover_color", Color("#160812"))
	button.add_theme_stylebox_override("normal", _box(accent, 15))
	button.add_theme_stylebox_override("hover", _box(accent.lightened(0.16), 15, Color.WHITE, 2))
	button.add_theme_stylebox_override("pressed", _box(accent.darkened(0.12), 15))
	button.add_theme_stylebox_override("focus", _box(Color.TRANSPARENT, 15, Color.WHITE, 3))
	button.pressed.connect(callback)
	parent.add_child(button)
	return button
static func _screen(root: Control, color: Color) -> Control:
	var screen := Control.new()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.visible = false
	root.add_child(screen)
	var shade := ColorRect.new()
	shade.color = color
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	screen.add_child(shade)
	return screen

static func _panel(parent: Control, pos: Vector2, size: Vector2, color := CARD, radius := 24, border_color := Color("#8e3d6a")) -> Panel:
	var panel := Panel.new()
	panel.position = pos
	panel.size = size
	panel.add_theme_stylebox_override("panel", _box(color, radius, border_color, 2))
	parent.add_child(panel)
	return panel

static func _add_floaters(screen: Control, store: Array) -> void:
	var specs = [
		[Vector2(-70, 80), Vector2(330, 96), Color("#7f274f"), -0.22, 0.0],
		[Vector2(1020, 80), Vector2(330, 130), Color("#723158"), 0.18, 1.7],
		[Vector2(910, 575), Vector2(430, 95), Color("#82294d"), -0.12, 3.2],
		[Vector2(-120, 585), Vector2(380, 88), Color("#602650"), 0.15, 4.5]
	]
	for spec in specs:
		var blob := Panel.new()
		blob.position = spec[0]
		blob.size = spec[1]
		blob.rotation = spec[3]
		blob.mouse_filter = Control.MOUSE_FILTER_IGNORE
		blob.add_theme_stylebox_override("panel", _box(spec[2], 46))
		blob.set_meta("base_y", blob.position.y)
		blob.set_meta("phase", spec[4])
		screen.add_child(blob)
		store.append(blob)
static func build(host: Node, callbacks: Dictionary) -> Dictionary:
	var data := {}
	var layer := CanvasLayer.new()
	layer.name = "FrontendLayer"
	layer.layer = 40
	host.add_child(layer)
	var root := Control.new()
	root.name = "FrontendRoot"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)
	data["root"] = root
	var floaters: Array = []
	data["floaters"] = floaters

	var main := _screen(root, Color("#26091f"))
	data["main"] = main
	_add_floaters(main, floaters)
	_label(main, "GUT CREW", Vector2(82, 72), Vector2(650, 82), 62, INK)
	_label(main, "巨兽急诊班", Vector2(88, 144), Vector2(520, 52), 30, YELLOW)
	_label(main, "每一具身体里，都藏着一段没说完的故事。", Vector2(90, 202), Vector2(680, 42), 19, MUTED)
	var tag := _panel(main, Vector2(88, 272), Vector2(575, 78), Color("#451535"), 18, Color("#a44776"))
	_label(tag, "当前病例  CASE 01", Vector2(20, 8), Vector2(260, 28), 15, CYAN)
	_label(tag, "《最后一声晚安》· 收容所猫莫奇", Vector2(20, 32), Vector2(540, 36), 21, INK)
	var menu_card := _panel(main, Vector2(785, 116), Vector2(390, 470), CARD_DARK, 30, Color("#a64b7a"))
	_label(menu_card, "急诊控制台", Vector2(34, 28), Vector2(320, 42), 27, INK)
	_label(menu_card, "EMERGENCY CONSOLE", Vector2(36, 66), Vector2(310, 26), 14, PINK)
	var start := _button(menu_card, "开始游戏  START", Vector2(34, 120), Vector2(322, 66), callbacks["start"], YELLOW)
	_button(menu_card, "选项 / 设置  OPTIONS", Vector2(34, 204), Vector2(322, 58), callbacks["settings"], CYAN)
	_button(menu_card, "退出游戏  EXIT", Vector2(34, 280), Vector2(322, 58), callbacks["quit"], PINK)
	_label(menu_card, "ESC 退出  ·  鼠标/方向键选择", Vector2(34, 370), Vector2(322, 32), 14, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	data["main_start"] = start
	var portraits := _panel(main, Vector2(86, 390), Vector2(620, 225), Color("#3b122f"), 24, Color("#793157"))
	var role_art = [load("res://assets/spark.png"), load("res://assets/kaka.png"), load("res://assets/bubble.png"), load("res://assets/shroom.png")]
	for i in range(4):
		var pic := TextureRect.new()
		pic.position = Vector2(14 + i * 150, 10)
		pic.size = Vector2(142, 154)
		pic.texture = role_art[i]
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		portraits.add_child(pic)
		var names = ["闪仔 SPARK", "咔咔 KAKA", "泡泡 BUBBLE", "菇菇 SHROOM"]
		_label(portraits, names[i], Vector2(8 + i * 150, 166), Vector2(148, 34), 13, [YELLOW, INK, CYAN, Color("#c49bff")][i], HORIZONTAL_ALIGNMENT_CENTER)
		_label(portraits, ["神经诊疗 / 供能", "搬运异物 / 固定", "冲洗污渍 / 消毒", "菌疗敷药 / 修复"][i], Vector2(8+i*150,195),Vector2(148,24),11,MUTED,HORIZONTAL_ALIGNMENT_CENTER)

	var levels := _screen(root, Color("#2a0a22"))
	data["levels"] = levels
	_add_floaters(levels, floaters)
	_label(levels, "选择病例 / SELECT CASE", Vector2(0, 58), Vector2(1280, 62), 38, INK, HORIZONTAL_ALIGNMENT_CENTER)
	_label(levels, "每张大地图由器官小关卡、身体事件与隐藏路线组成", Vector2(0, 112), Vector2(1280, 32), 17, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	var case_specs = [
		["CASE 01 · 猫", "最后一声晚安", "胃中枢 · 毛球森林 · 肠道迷宫 · 肺泡/神经支线", YELLOW, true],
		["CASE 02 · 青蛙", "沼气肺囊", "跳跃器官 · 舌头风暴", GREEN, false],
		["CASE 03 · 鲸", "深海循环系统", "高压血流 · 声呐迷航", CYAN, false]
	]
	for i in range(3):
		var x := 105.0 + i * 365.0
		var card := _panel(levels, Vector2(x, 195), Vector2(335, 360), Color("#461536"), 25, case_specs[i][3])
		_label(card, case_specs[i][0], Vector2(22, 24), Vector2(290, 36), 18, case_specs[i][3])
		_label(card, case_specs[i][1], Vector2(22, 74), Vector2(290, 54), 27, INK)
		_label(card, case_specs[i][2], Vector2(22, 135), Vector2(290, 64), 15, MUTED)
		var status := "可出诊  READY" if case_specs[i][4] else "研发中  IN DEVELOPMENT"
		_label(card, status, Vector2(22, 218), Vector2(290, 36), 15, case_specs[i][3])
		if case_specs[i][4]:
			_button(card, "选择此病例", Vector2(22, 278), Vector2(290, 56), callbacks["choose_cat"], case_specs[i][3])
		else:
			var lock := Button.new()
			lock.text = "🔒 尚未开放"
			lock.position = Vector2(22, 278)
			lock.size = Vector2(290, 56)
			lock.disabled = true
			card.add_child(lock)
	_button(levels, "← 返回主界面", Vector2(105, 604), Vector2(230, 54), callbacks["back"], PINK)
	var settings := _screen(root, Color("#26091f"))
	data["settings"] = settings
	_add_floaters(settings, floaters)
	var settings_card := _panel(settings, Vector2(330, 70), Vector2(620, 585), CARD_DARK, 28, Color("#a64b7a"))
	_label(settings_card, "选项 / 设置", Vector2(38, 26), Vector2(540, 44), 32, INK)
	_label(settings_card, "OPTIONS · 当前会话即时生效", Vector2(40, 68), Vector2(520, 28), 14, PINK)
	_label(settings_card, "主音量  MASTER VOLUME", Vector2(42, 122), Vector2(360, 32), 17, INK)
	var volume := HSlider.new()
	volume.position = Vector2(42, 160)
	volume.size = Vector2(430, 28)
	volume.min_value = 0
	volume.max_value = 100
	volume.value = 80
	volume.value_changed.connect(callbacks["volume"])
	settings_card.add_child(volume)
	data["volume"] = volume
	data["volume_value"] = _label(settings_card, "80%", Vector2(490, 151), Vector2(85, 38), 17, CYAN, HORIZONTAL_ALIGNMENT_RIGHT)
	_label(settings_card, "鼠标灵敏度  MOUSE SENSITIVITY", Vector2(42, 218), Vector2(410, 32), 17, INK)
	var sensitivity := HSlider.new()
	sensitivity.position = Vector2(42, 256)
	sensitivity.size = Vector2(430, 28)
	sensitivity.min_value = 50
	sensitivity.max_value = 180
	sensitivity.value = 100
	sensitivity.value_changed.connect(callbacks["sensitivity"])
	settings_card.add_child(sensitivity)
	data["sensitivity"] = sensitivity
	data["sensitivity_value"] = _label(settings_card, "1.00x", Vector2(490, 247), Vector2(85, 38), 17, CYAN, HORIZONTAL_ALIGNMENT_RIGHT)
	_label(settings_card, "第三人称视野  CAMERA FOV", Vector2(42, 314), Vector2(380, 32), 17, INK)
	var fov := HSlider.new()
	fov.position = Vector2(42, 352)
	fov.size = Vector2(430, 28)
	fov.min_value = 58
	fov.max_value = 82
	fov.value = 68
	fov.value_changed.connect(callbacks["fov"])
	settings_card.add_child(fov)
	data["fov"] = fov
	data["fov_value"] = _label(settings_card, "68°", Vector2(490, 343), Vector2(85, 38), 17, CYAN, HORIZONTAL_ALIGNMENT_RIGHT)
	var fullscreen := CheckButton.new()
	fullscreen.text = "全屏模式  FULLSCREEN"
	fullscreen.position = Vector2(42, 410)
	fullscreen.size = Vector2(310, 44)
	fullscreen.add_theme_font_size_override("font_size", 17)
	fullscreen.toggled.connect(callbacks["fullscreen"])
	settings_card.add_child(fullscreen)
	data["fullscreen"] = fullscreen
	_label(settings_card, "界面语言：简体中文 + English labels", Vector2(42, 466), Vector2(500, 30), 15, MUTED)
	_button(settings_card, "保存并返回  BACK", Vector2(42, 515), Vector2(536, 52), callbacks["settings_back"], YELLOW)

	var pause := _screen(root, Color(0.08, 0.02, 0.07, 0.86))
	data["pause"] = pause
	var pause_card := _panel(pause, Vector2(405, 68), Vector2(470, 590), CARD_DARK, 30, Color("#b34c7e"))
	_label(pause_card, "急诊暂停", Vector2(34, 24), Vector2(402, 48), 34, INK, HORIZONTAL_ALIGNMENT_CENTER)
	_label(pause_card, "PAUSED · 身体事件已冻结", Vector2(34, 70), Vector2(402, 28), 14, CYAN, HORIZONTAL_ALIGNMENT_CENTER)
	_button(pause_card, "继续急诊  RESUME", Vector2(54, 126), Vector2(362, 60), callbacks["resume"], YELLOW)
	_button(pause_card, "选项 / 设置", Vector2(54, 204), Vector2(362, 54), callbacks["pause_settings"], CYAN)
	_button(pause_card, "重新选择关卡", Vector2(54, 276), Vector2(362, 54), callbacks["pause_levels"], GREEN)
	_button(pause_card, "返回主界面", Vector2(54, 348), Vector2(362, 54), callbacks["pause_main"], Color("#e9b8cf"))
	_button(pause_card, "退出游戏", Vector2(54, 420), Vector2(362, 54), callbacks["pause_quit"], PINK)
	_label(pause_card, "ESC 继续游戏", Vector2(54, 510), Vector2(362, 34), 15, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	var quit := _screen(root, Color(0.04, 0.01, 0.035, 0.94))
	data["quit"] = quit
	var quit_card := _panel(quit, Vector2(385, 205), Vector2(510, 310), CARD_DARK, 28, PINK)
	_label(quit_card, "结束本次急诊？", Vector2(35, 30), Vector2(440, 50), 30, INK, HORIZONTAL_ALIGNMENT_CENTER)
	_label(quit_card, "EXIT GUT CREW", Vector2(35, 78), Vector2(440, 28), 15, PINK, HORIZONTAL_ALIGNMENT_CENTER)
	_label(quit_card, "未完成的当局进度不会保留。", Vector2(35, 124), Vector2(440, 34), 16, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	_button(quit_card, "取消  CANCEL", Vector2(35, 204), Vector2(205, 58), callbacks["quit_no"], CYAN)
	_button(quit_card, "确认退出  EXIT", Vector2(270, 204), Vector2(205, 58), callbacks["quit_yes"], PINK)
	return data

static func show_screen(data: Dictionary, screen_name: String) -> void:
	data["root"].visible = true
	for name in ["main", "levels", "settings", "pause", "quit"]:
		data[name].visible = name == screen_name
	if screen_name == "main":
		data["main_start"].grab_focus()

static func hide_all(data: Dictionary) -> void:
	if data.has("root"):
		data["root"].visible = false

static func animate(data: Dictionary, time: float) -> void:
	if data.is_empty() or not data["root"].visible:
		return
	for floater in data.get("floaters", []):
		if is_instance_valid(floater):
			var base_y: float = floater.get_meta("base_y")
			var phase: float = floater.get_meta("phase")
			floater.position.y = base_y + sin(time * 0.75 + phase) * 9.0
