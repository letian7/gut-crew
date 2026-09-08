extends CanvasLayer
const ShopData = preload("res://scripts/shop_factory.gd")
const ClinicData = preload("res://scripts/clinic_system.gd")
## Phase 30: readable field inventory for coins, salvage and temporary gear.
var game
var shade: ColorRect
var panel: PanelContainer
var summary: Label
var active_items: Label
var treasure: Label
var upgrades: Label
var catalog: Label
var supply_text: Label
var refresh_clock := 0.0
var opened_count := 0

func _label(parent: Node, text_: String, size_: int, color := Color("#f3ead8")) -> Label:
	var label := Label.new()
	label.text = text_
	label.add_theme_font_size_override("font_size", size_)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
	return label

func build(host) -> void:
	game = host
	name = "FieldInventory30"
	layer = 38
	shade = ColorRect.new()
	shade.color = Color(0.025, 0.018, 0.035, 0.84)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)
	panel = PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -440
	panel.offset_top = -300
	panel.offset_right = 440
	panel.offset_bottom = 300
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#142126")
	style.border_color = Color("#79d9c5")
	style.set_border_width_all(3)
	style.set_corner_radius_all(18)
	style.content_margin_left = 26
	style.content_margin_right = 26
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", style)
	shade.add_child(panel)
	var columns := VBoxContainer.new()
	columns.add_theme_constant_override("separation", 9)
	panel.add_child(columns)
	var header := HBoxContainer.new()
	columns.add_child(header)
	var title := _label(header, "急诊物品栏  /  FIELD INVENTORY", 28, Color("#9af0da"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var close := Button.new()
	close.text = "关闭 [TAB]"
	close.custom_minimum_size = Vector2(132, 42)
	close.pressed.connect(close_inventory)
	header.add_child(close)
	summary = _label(columns, "", 18, Color("#ffe186"))
	var separator := HSeparator.new()
	columns.add_child(separator)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 20)
	columns.add_child(body)
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(400, 430)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(left)
	_label(left, "正在生效的临时装备", 20, Color("#72e8ff"))
	active_items = _label(left, "", 17)
	active_items.custom_minimum_size.y = 60
	supply_text = _label(left,"",16)
	var supplies := HBoxContainer.new()
	left.add_child(supplies)
	for kind in ["medkit","soda"]:
		var use := Button.new()
		use.text = "使用补胶包 +35HP" if kind=="medkit" else "喝血浆汽水 16秒"
		use.pressed.connect(_use_training_supply.bind(kind))
		supplies.add_child(use)
	_label(left, "胃内寻宝袋  ·  最大 8 件", 20, Color("#ffcd72"))
	treasure = _label(left, "", 16)
	treasure.custom_minimum_size.y = 170
	var sell := Button.new()
	sell.text = "在回收站远程估价并出售"
	sell.custom_minimum_size.y = 40
	sell.pressed.connect(_sell_treasure)
	left.add_child(sell)
	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(400, 430)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right)
	_label(right, "四职业强化", 20, Color("#caa8ff"))
	upgrades = _label(right, "", 16)
	upgrades.custom_minimum_size.y = 142
	_label(right, "BODY MART 商品说明", 20, Color("#9af0da"))
	catalog = _label(right, "", 15)
	catalog.custom_minimum_size.y = 210
	_label(columns, "Tab 打开/关闭  ·  V 切换视角  ·  物品栏打开时急诊现场暂停", 15, Color("#9daeb1"))
	visible = false
	set_process(true)

func open_inventory() -> void:
	if visible or not game.role_selected: return
	visible = true
	game.inventory_open = true
	opened_count += 1
	refresh()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close_inventory() -> void:
	if not visible: return
	visible = false
	game.inventory_open = false
	if game.role_selected and not game.game_paused and not game._cinematic_locked():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func toggle() -> void:
	if visible: close_inventory()
	else: open_inventory()

func _sell_treasure() -> void:
	if not is_instance_valid(game.clinic_system): return
	if game.clinic_system.bag.is_empty():
		game._toast("寻宝袋是空的：去胃酸池钓点奇怪东西。", Color("#ffcf76"), 2.0)
	else:
		var earned: int = game.clinic_system.sell_bag()
		game._toast("物品栏回收完成：+%d BioCoins" % earned, Color("#ffe46b"), 2.2)
	refresh()
func _active_text() -> String:
	var rows: Array[String] = []
	if game.acid_umbrella_time > 0.0:
		rows.append("胃酸伞  %.1fs  ·  胃酸伤害 -82%% / 抗水流" % game.acid_umbrella_time)
	if game.plasma_soda_time > 0.0:
		rows.append("血浆汽水  %.1fs  ·  速度 +28%% / 冷却恢复 x1.55" % game.plasma_soda_time)
	if game.catnip_time > 0.0:
		rows.append("猫薄荷诱饵  %.1fs  ·  吸引附近野怪" % game.catnip_time)
	if rows.is_empty(): return "无。去找 BODY MART 的搞笑细菌补货。"
	return "\n".join(rows)

func _treasure_text() -> String:
	if not is_instance_valid(game.clinic_system) or game.clinic_system.bag.is_empty():
		return "空袋  ·  胃酸池里可能钓出旧硬币、胃石，或者会打嗝的小酸鱼。"
	var rows: Array[String] = []
	for item in game.clinic_system.bag:
		rows.append("• %s  /  %d C" % [String(item.get("name", "未知异物")), int(item.get("value", 0))])
	return "\n".join(rows)

func _upgrade_text() -> String:
	if not is_instance_valid(game.clinic_system): return "尚未接入急诊强化台"
	var rows: Array[String] = []
	for i in range(4):
		rows.append("%s  Lv.%d  ·  %s" % [ClinicData.JOBS[i], game.clinic_system.levels[i], ClinicData.PERKS[i]])
	return "\n".join(rows)
func _catalog_text() -> String:
	var rows: Array[String] = []
	for i in range(ShopData.ITEM_NAMES.size()):
		var description: String = String(ShopData.ITEM_DESCRIPTIONS[i]) if i < ShopData.ITEM_DESCRIPTIONS.size() else "细菌老板拒绝解释。"
		rows.append("%s  %d C\n%s" % [ShopData.ITEM_NAMES[i], ShopData.ITEM_COSTS[i], description])
	return "\n".join(rows)

func _use_training_supply(kind: String) -> void:
	if is_instance_valid(game.mouth_intro.training): game.mouth_intro.training.use_supply(kind)
	refresh()

func refresh() -> void:
	if not is_instance_valid(game): return
	var bag_count: int = int(game.clinic_system.bag.size()) if is_instance_valid(game.clinic_system) else 0
	var bag_value: int = int(game.clinic_system.bag_value()) if is_instance_valid(game.clinic_system) else 0
	summary.text = "BIOCOINS  %d C     寻宝袋  %d/8     估值  %d C     商店购买  %d 次" % [game.credits, bag_count, bag_value, game.purchases]
	active_items.text = _active_text()
	if is_instance_valid(game.mouth_intro.training):
		var stock: Dictionary = game.mouth_intro.training.pockets
		supply_text.text = "随身补给：补胶包 %d · 血浆汽水 %d" % [stock.medkit,stock.soda]
	treasure.text = _treasure_text()
	upgrades.text = _upgrade_text()
	catalog.text = _catalog_text()

func _process(delta: float) -> void:
	if not visible: return
	refresh_clock -= delta
	if refresh_clock <= 0.0:
		refresh_clock = 0.16
		refresh()
# GODOT_PHASE30_FIELD_INVENTORY
