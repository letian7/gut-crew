extends CanvasLayer
## Phase 32: first-person aim language shared by every role.
var game
var brackets: Array[Line2D] = []
var charge_ring: Line2D
var target_dot: Label
var action_label: Label
var pulse := 0.0
var recoil := 0.0
var events := 0

func build(host) -> void:
	game = host
	layer = 13
	name = "FirstPersonAim32"
	for i in range(4):
		var line := Line2D.new()
		line.width = 3.0
		line.antialiased = true
		add_child(line)
		brackets.append(line)
	charge_ring = Line2D.new()
	charge_ring.width = 4.0
	charge_ring.antialiased = true
	add_child(charge_ring)
	target_dot = Label.new()
	target_dot.text = "•"
	target_dot.add_theme_font_size_override("font_size", 30)
	target_dot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	target_dot.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	target_dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(target_dot)
	action_label = Label.new()
	action_label.add_theme_font_size_override("font_size", 17)
	action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action_label.size = Vector2(640, 30)
	action_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(action_label)
	set_process(true)

func trigger(action: String, strength := 0.5) -> void:
	pulse = maxf(pulse, 0.16 + strength * 0.20)
	recoil = maxf(recoil, strength)
	events += 1
	action_label.text = action

func _circle(center: Vector2, radius: float, progress: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var count := maxi(5, int(32.0 * clampf(progress, 0.12, 1.0)))
	for i in range(count + 1):
		var angle := -PI * 0.5 + TAU * progress * float(i) / float(count)
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	return points

func _process(delta: float) -> void:
	pulse = maxf(0.0, pulse - delta)
	recoil = move_toward(recoil, 0.0, delta * 5.5)
	visible = (
		is_instance_valid(game) and game.first_person and game.role_selected
		and not game.game_paused and not game.inventory_open
		and not game._cinematic_locked()
	)
	if not visible: return
	var size := get_viewport().get_visible_rect().size
	var recoil_motion := Vector2(
		sin(game.living_time * 61.0), cos(game.living_time * 53.0)
	) * recoil * 3.5
	var center := size * 0.5 + recoil_motion
	var target = game._get_target(18.0, 0.38)
	var locked := is_instance_valid(target)
	var color: Color = game.ROLE_COLORS[game.role_index]
	if locked: color = color.lightened(0.25)
	var gap := 18.0 - pulse * 26.0 + (7.0 if not locked else 0.0)
	var length := 13.0 + pulse * 32.0
	var corners := [Vector2(-1,-1),Vector2(1,-1),Vector2(1,1),Vector2(-1,1)]
	for i in range(4):
		var corner: Vector2 = corners[i]
		var anchor := center + corner * gap
		brackets[i].points = PackedVector2Array([
			anchor + Vector2(-corner.x * length,0),
			anchor,
			anchor + Vector2(0,-corner.y * length)
		])
		brackets[i].default_color = color
		brackets[i].modulate.a = 0.92 if locked else 0.52
	target_dot.position = center - Vector2(15, 21)
	target_dot.size = Vector2(30, 38)
	target_dot.modulate = color
	target_dot.modulate.a = 0.90 if locked else 0.36
	var charge := 0.0
	if game.role_index == 1:
		if game.secondary_hold:
			charge = game.kaka_hook_charge
		elif game.primary_hold:
			charge = clampf(game.kaka_charge_time / 1.8, 0.0, 1.0)
	charge_ring.visible = charge > 0.01
	charge_ring.points = _circle(center, 42.0 + charge * 7.0, charge)
	charge_ring.default_color = color.lerp(Color.WHITE, charge * 0.35)
	action_label.position = Vector2(center.x - 320.0, center.y + 58.0)
	action_label.modulate = color
	if pulse <= 0.0 and charge <= 0.01:
		action_label.text = "LOCKED" if locked else "SEARCHING"
	elif charge > 0.01:
		if game.secondary_hold:
			action_label.text = "骨钩蓄力 %d%% · 墙体/重型怪：牵引自身" % int(charge * 100.0)
		else:
			action_label.text = "HAMMER STAGE %d" % maxi(1, game.kaka_hammer_stage)

	if game.role_index==1 and game.kaka_hook_phase=="attached":
		action_label.text = "挂绳 %.1fm · 右键长按收绳 / 轻点脱钩 · 空格跃出" % game.grapple.rope_length
	elif game.role_index==1 and game.kaka_hook_phase=="outgoing":
		action_label.text = "骨钩飞行中"

# GODOT_PHASE32_FIRST_PERSON_AIM
