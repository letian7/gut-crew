extends Node3D

const ROLE_NAMES = ["SPARK", "KAKA", "BUBBLE", "SHROOM"]
const ROLE_COLORS = [Color("#ffd83f"), Color("#f2e8d4"), Color("#63dcff"), Color("#b989ff")]
const ROLE_SKILLS = [["Nerve Wire", "Overload"], ["Long Bone", "Bone Pin"], ["Plasma Surf", "Engulf"], ["Fungus Patch", "Ferment"]]
const Q_COOLDOWNS = [3.6, 4.5, 5.4, 4.8]
const E_COOLDOWNS = [7.5, 6.5, 1.2, 6.8]

var player: CharacterBody3D
var camera_pivot: Node3D
var camera_3p: Camera3D
var camera_1p: Camera3D
var spring_arm: SpringArm3D
var body_mesh: MeshInstance3D
var head_mesh: MeshInstance3D
var status_label: Label
var help_label: Label
var view_label: Label
var crosshair: Label
var role_index := 0
var first_person := false
var yaw := 0.0
var pitch := -0.18
var dodge_time := 0.0
var jump_latch := false
var skill_q_cd := 0.0
var skill_e_cd := 0.0
var role_selected := false
var role_panel: Control
var living_time := 0.0
var mounds: Array[MeshInstance3D] = []
var acid_mesh: MeshInstance3D
var drink_wave: MeshInstance3D
var danger_label: Label
var target_label: Label
var enemies: Array[CharacterBody3D] = []
var surf_lanes: Array[Node3D] = []
var bone_structures: Array[Node3D] = []
var fungus_patches: Array[Node3D] = []
var hp := 100.0
var invuln := 0.0
var defeats := 0
var acid_tide_time := 0.0
var acid_next := 8.0
var spasm_time := 0.0
var spasm_next := 12.0
var spasm_dir := 1.0
var drink_time := 0.0
var drink_next := 17.0
var drink_dir := 1.0
var ferment_time := 0.0
var bubble_payload: CharacterBody3D
var hit_shake := 0.0
var damage_shake := 0.0
var mission_phase := "diagnose"
var clue_nodes: Array[Node3D] = []
var clue_done = [false, false, false]
var mouse_target: CharacterBody3D
var mouse_caught := false
var entrance: Node3D
var mucus_routes: Array[Node3D] = []
var mission_label: Label
var interact_label: Label
var capture_bar: ProgressBar
var win_panel: Control
var win_label: Label
var interact_down := false
var interact_progress := 0.0
var round_time := 0.0
var acid_valve: Node3D
var valve_cooldown := 0.0
var swallow_next := 11.0
var swallowed_props: Array[RigidBody3D] = []
var synergies := 0
var combo_best := 0
func _ready() -> void:
	_build_environment()
	_build_enemies()
	_build_player()
	_build_hud()
	_build_mission()
	_set_role(0)
	_build_role_select()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _mat(color: Color, transparent := false) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.88
	if transparent:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return mat

func _build_environment() -> void:
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -35, 0)
	light.light_color = Color("#ffd9cf")
	light.light_energy = 2.2
	light.shadow_enabled = true
	add_child(light)
	var fill := OmniLight3D.new()
	fill.position = Vector3(0, 6, 1)
	fill.light_color = Color("#ff7ba7")
	fill.light_energy = 8.0
	fill.omni_range = 22.0
	add_child(fill)
	_make_static_box(Vector3(0, -0.4, 0), Vector3(30, 0.8, 18), Color("#8d4165"))
	_make_acid(Vector3(0, 0.03, 4.8), Vector2(12, 5.4))
	_make_mound(Vector3(-7, 0.1, -2.2), Vector3(4.5, 1.0, 3.2), Color("#a84c70"))
	_make_mound(Vector3(4.8, 0.1, -3.0), Vector3(5.2, 1.25, 3.6), Color("#7e3c63"))
	_make_mound(Vector3(9, 0.1, 2.2), Vector3(3.8, 0.85, 2.8), Color("#b55778"))
	_make_static_box(Vector3(-4.5, 0.35, 1.0), Vector3(1.8, 0.7, 1.2), Color("#53bce6"))
	_make_static_box(Vector3(4.2, 0.45, 2.6), Vector3(2.0, 0.9, 1.1), Color("#e95b68"))
	_make_drink_wave()
	_build_phase4_map()
	_build_acid_valve()

func _build_phase4_map() -> void:
	_make_static_box(Vector3(-8.2, 0.85, 3.8), Vector3(4.6, 0.55, 2.8), Color("#b95c7b"))
	_make_static_box(Vector3(7.7, 1.0, 4.0), Vector3(4.2, 0.55, 2.5), Color("#a44e72"))
	_make_static_ramp(Vector3(-5.2, 0.45, 3.1), Vector3(5.0, 0.45, 2.0), -16.0, Color("#c46b88"))
	_make_static_ramp(Vector3(5.0, 0.52, 3.2), Vector3(5.2, 0.45, 2.0), 17.0, Color("#b66080"))
	_make_static_box(Vector3(0.0, 0.62, -5.7), Vector3(8.5, 0.32, 1.15), Color("#7f365d"))
	_make_landmark(Vector3(-11.0, 0.0, -5.7), "CARDIA GATE", Color("#ffbd75"))
	_make_landmark(Vector3(10.7, 0.0, -5.6), "PYLORIC FOLD", Color("#a8e5b7"))
	_make_landmark(Vector3(0.0, 0.0, -7.1), "NERVE RIDGE", Color("#f6e86c"))

func _make_static_ramp(pos: Vector3, size: Vector3, rot_x: float, color: Color) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	body.rotation_degrees.x = rot_x
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mi.mesh = box
	mi.material_override = _mat(color)
	body.add_child(mi)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	add_child(body)

func _make_landmark(pos: Vector3, text: String, color: Color) -> void:
	var root := Node3D.new()
	root.position = pos
	var mi := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.42
	cyl.bottom_radius = 0.7
	cyl.height = 3.6
	mi.mesh = cyl
	mi.position.y = 1.8
	var mat := _mat(color)
	mat.emission_enabled = true
	mat.emission = color.darkened(0.5)
	mat.emission_energy_multiplier = 0.9
	mi.material_override = mat
	root.add_child(mi)
	var lab := Label3D.new()
	lab.text = text
	lab.position = Vector3(0, 4.0, 0)
	lab.font_size = 24
	lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	root.add_child(lab)
	add_child(root)

func _build_acid_valve() -> void:
	acid_valve = Node3D.new()
	acid_valve.position = Vector3(-8.8, 0.0, -3.7)
	var ring := MeshInstance3D.new()
	var tor := TorusMesh.new()
	tor.inner_radius = 0.42
	tor.outer_radius = 0.68
	ring.mesh = tor
	ring.rotation.x = PI * 0.5
	ring.position.y = 1.0
	var mat := _mat(Color("#73e6c6"))
	mat.emission_enabled = true
	mat.emission = Color("#177e71")
	mat.emission_energy_multiplier = 1.5
	ring.material_override = mat
	acid_valve.add_child(ring)
	var lab := Label3D.new()
	lab.text = "ACID VALVE"
	lab.position = Vector3(0, 2.0, 0)
	lab.font_size = 22
	lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	acid_valve.add_child(lab)
	acid_valve.set_meta("ring", ring)
	acid_valve.set_meta("label", lab)
	add_child(acid_valve)

func _make_static_box(pos: Vector3, size: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	var mesh_instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.material_override = _mat(color)
	body.add_child(mesh_instance)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)
func _make_mound(pos: Vector3, scale_v: Vector3, color: Color) -> void:
	var m := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 1.0
	sphere.height = 2.0
	m.mesh = sphere
	m.position = pos
	m.scale = scale_v
	m.set_meta("base_scale", scale_v)
	m.material_override = _mat(color)
	add_child(m)
	mounds.append(m)

func _make_drink_wave() -> void:
	drink_wave = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.2, 0.12, 15.5)
	drink_wave.mesh = box
	drink_wave.position = Vector3(-16, 0.18, 0)
	var mat := _mat(Color(0.25, 0.75, 1.0, 0.28), true)
	mat.emission_enabled = true
	mat.emission = Color("#2488aa")
	mat.emission_energy_multiplier = 1.6
	drink_wave.material_override = mat
	drink_wave.visible = false
	add_child(drink_wave)

func _make_acid(pos: Vector3, size: Vector2) -> void:
	var m := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = size
	m.mesh = plane
	m.position = pos
	var mat := _mat(Color(0.62, 0.9, 0.18, 0.72), true)
	mat.emission_enabled = true
	mat.emission = Color("#557d09")
	mat.emission_energy_multiplier = 1.2
	m.material_override = mat
	add_child(m)
	acid_mesh = m

func _build_enemies() -> void:
	_spawn_enemy("HAIRBALL", Vector3(-5.5, 0.2, -0.5), Color("#744b7a"), 80.0, 2.5)
	_spawn_enemy("HAIRBALL", Vector3(6.5, 0.2, -1.8), Color("#744b7a"), 80.0, 2.5)
	_spawn_enemy("PLATELET", Vector3(-1.8, 0.2, 3.3), Color("#e85e67"), 55.0, 3.4)
	_spawn_enemy("PARASITE", Vector3(8.5, 0.2, 3.2), Color("#71d79c"), 120.0, 2.9)

func _spawn_enemy(kind: String, pos: Vector3, color: Color, max_hp: float, speed: float) -> void:
	var e := CharacterBody3D.new()
	e.name = kind
	e.position = pos
	e.set_meta("kind", kind)
	e.set_meta("hp", max_hp)
	e.set_meta("max_hp", max_hp)
	e.set_meta("speed", speed)
	e.set_meta("stun", 0.0)
	e.set_meta("pinned", 0.0)
	e.set_meta("big", 0.0)
	e.set_meta("hit_flash", 0.0)
	e.set_meta("base_color", color)
	e.set_meta("contact_damage", 12.0 if kind == "PARASITE" else (6.0 if kind == "PLATELET" else 9.0))
	e.set_meta("combo_role", -1)
	e.set_meta("combo_t", 0.0)
	e.set_meta("combo_count", 0)
	var mi := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.55 if kind != "PARASITE" else 0.68
	mesh.height = 1.1 if kind != "PARASITE" else 1.55
	mi.mesh = mesh
	mi.position.y = 0.65
	mi.material_override = _mat(color)
	e.add_child(mi)
	e.set_meta("mesh", mi)
	var hp_label := Label3D.new()
	hp_label.position = Vector3(0, 1.75, 0)
	hp_label.font_size = 22
	hp_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	hp_label.text = "%s\n%d/%d" % [kind, int(max_hp), int(max_hp)]
	e.add_child(hp_label)
	e.set_meta("hp_label", hp_label)
	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.5
	shape.height = 1.2
	col.shape = shape
	col.position.y = 0.62
	e.add_child(col)
	add_child(e)
	enemies.append(e)

func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(0, 1.15, 5.5)
	player.floor_snap_length = 0.35
	add_child(player)
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.42
	capsule.height = 1.55
	collision.shape = capsule
	collision.position.y = 0.78
	player.add_child(collision)
	body_mesh = MeshInstance3D.new()
	var body_capsule := CapsuleMesh.new()
	body_capsule.radius = 0.42
	body_capsule.height = 1.2
	body_mesh.mesh = body_capsule
	body_mesh.position.y = 0.75
	player.add_child(body_mesh)
	head_mesh = MeshInstance3D.new()
	var head := SphereMesh.new()
	head.radius = 0.34
	head.height = 0.68
	head_mesh.mesh = head
	head_mesh.position.y = 1.55
	player.add_child(head_mesh)
	camera_pivot = Node3D.new()
	camera_pivot.position = Vector3(0, 1.35, 0)
	player.add_child(camera_pivot)
	spring_arm = SpringArm3D.new()
	spring_arm.spring_length = 5.2
	spring_arm.margin = 0.18
	camera_pivot.add_child(spring_arm)
	camera_3p = Camera3D.new()
	camera_3p.fov = 66.0
	spring_arm.add_child(camera_3p)
	camera_1p = Camera3D.new()
	camera_1p.position = Vector3(0, 0.28, -0.18)
	camera_1p.fov = 72.0
	camera_pivot.add_child(camera_1p)
	camera_3p.current = true
	camera_pivot.rotation.x = pitch

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	status_label = Label.new()
	status_label.position = Vector2(18, 16)
	status_label.add_theme_font_size_override("font_size", 22)
	layer.add_child(status_label)
	view_label = Label.new()
	view_label.position = Vector2(1030, 18)
	view_label.add_theme_font_size_override("font_size", 18)
	layer.add_child(view_label)
	help_label = Label.new()
	help_label.position = Vector2(18, 650)
	help_label.text = "WASD move | Shift sprint | Space jump | RMB/Ctrl dodge | Q/E skills | F/LMB interact | Tab view"
	help_label.add_theme_font_size_override("font_size", 16)
	layer.add_child(help_label)
	crosshair = Label.new()
	crosshair.text = "+"
	crosshair.position = Vector2(635, 348)
	crosshair.add_theme_font_size_override("font_size", 25)
	layer.add_child(crosshair)
	danger_label = Label.new()
	danger_label.position = Vector2(410, 78)
	danger_label.size = Vector2(460, 44)
	danger_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	danger_label.add_theme_font_size_override("font_size", 22)
	danger_label.add_theme_color_override("font_color", Color("#ffe880"))
	layer.add_child(danger_label)
	target_label = Label.new()
	target_label.position = Vector2(490, 390)
	target_label.size = Vector2(300, 34)
	target_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	target_label.add_theme_font_size_override("font_size", 17)
	layer.add_child(target_label)

func _build_role_select() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	role_panel = Control.new()
	role_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(role_panel)
	var shade := ColorRect.new()
	shade.color = Color(0.06, 0.025, 0.08, 0.94)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	role_panel.add_child(shade)
	var title := Label.new()
	title.text = "GUT CREW - SELECT ROLE"
	title.position = Vector2(0, 105)
	title.size = Vector2(1280, 70)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	role_panel.add_child(title)
	var row := HBoxContainer.new()
	row.position = Vector2(115, 230)
	row.add_theme_constant_override("separation", 20)
	role_panel.add_child(row)
	var role_art = [preload("res://assets/spark.png"), preload("res://assets/kaka.png"), preload("res://assets/bubble.png"), preload("res://assets/shroom.png")]
	for i in range(4):
		var card := VBoxContainer.new()
		card.custom_minimum_size = Vector2(245, 300)
		var pic := TextureRect.new()
		pic.custom_minimum_size = Vector2(245, 205)
		pic.texture = role_art[i]
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		card.add_child(pic)
		var button := Button.new()
		button.custom_minimum_size = Vector2(245, 78)
		button.text = ROLE_NAMES[i] + "\n" + ROLE_SKILLS[i][0] + " / " + ROLE_SKILLS[i][1]
		button.add_theme_font_size_override("font_size", 18)
		button.add_theme_color_override("font_color", ROLE_COLORS[i])
		button.pressed.connect(_select_role.bind(i))
		card.add_child(button)
		row.add_child(card)

func _select_role(index: int) -> void:
	_set_role(index)
	role_selected = true
	role_panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _set_role(index: int) -> void:
	role_index = clampi(index, 0, 3)
	var color: Color = ROLE_COLORS[role_index]
	var mat := _mat(color)
	mat.emission_enabled = true
	mat.emission = color.darkened(0.55)
	mat.emission_energy_multiplier = 0.28
	body_mesh.material_override = mat
	head_mesh.material_override = mat.duplicate()
	_update_hud()

func _update_hud() -> void:
	var skills = ROLE_SKILLS[role_index]
	var qtxt := "READY" if skill_q_cd <= 0.0 else "%.1f" % skill_q_cd
	var etxt := "READY" if skill_e_cd <= 0.0 else "%.1f" % skill_e_cd
	var payload_txt := " | PAYLOAD" if role_index == 2 and is_instance_valid(bubble_payload) else ""
	status_label.text = "%s | HP %d | Q %s %s | E %s %s | KOs %d | SYNC %d BEST x%d%s" % [ROLE_NAMES[role_index], int(hp), skills[0], qtxt, skills[1], etxt, defeats, synergies, combo_best, payload_txt]
	view_label.text = "FIRST PERSON" if first_person else "THIRD PERSON"
func _process(delta: float) -> void:
	living_time += delta
	valve_cooldown = maxf(0.0, valve_cooldown - delta)
	swallow_next -= delta
	if swallow_next <= 0.0:
		_spawn_swallowed_prop()
		swallow_next = 18.0 + randf() * 8.0
	_update_acid_valve_visual()
	for i in range(mounds.size()):
		var base: Vector3 = mounds[i].get_meta("base_scale")
		var breathe := 1.0 + sin(living_time * 1.6 + i * 1.3) * 0.06
		mounds[i].scale = Vector3(base.x, base.y * breathe, base.z)
	for i in range(clue_nodes.size()):
		if not clue_done[i]:
			var pulse := 1.0 + sin(living_time * 3.2 + i * 1.7) * 0.12
			clue_nodes[i].scale = Vector3.ONE * pulse
	if entrance:
		var ep := 1.0 + (sin(living_time * 4.0) * 0.06 if mission_phase == "return" else 0.0)
		entrance.scale = Vector3.ONE * ep
	if acid_mesh:
		acid_mesh.position.y = 0.03 + sin(living_time * 1.9) * 0.035
		var am := acid_mesh.material_override as StandardMaterial3D
		if am: am.emission_energy_multiplier = 1.0 + sin(living_time * 2.6) * 0.22
	_update_living_events(delta)
	_update_mission(delta)
	_update_target_ui()
	_tick_zones(delta)
	var self_scale := 1.24 if ferment_time > 0.0 else 1.0
	body_mesh.scale = Vector3.ONE * self_scale
	head_mesh.scale = Vector3.ONE * self_scale
	hit_shake = maxf(0.0, hit_shake - delta * 2.8)
	damage_shake = maxf(0.0, damage_shake - delta * 1.9)
	var shake := hit_shake + damage_shake
	camera_pivot.position.x = sin(living_time * 63.0) * shake * 0.14
	camera_pivot.position.z = cos(living_time * 51.0) * shake * 0.08

func _physics_process(delta: float) -> void:
	if not role_selected:
		player.velocity = Vector3.ZERO
		_update_hud()
		return
	if mission_phase == "win":
		player.velocity = Vector3.ZERO
		_update_hud()
		return
	skill_q_cd = maxf(0.0, skill_q_cd - delta)
	skill_e_cd = maxf(0.0, skill_e_cd - delta)
	dodge_time = maxf(0.0, dodge_time - delta)
	var ix := 0.0
	var iz := 0.0
	if Input.is_key_pressed(KEY_D): ix += 1.0
	if Input.is_key_pressed(KEY_A): ix -= 1.0
	if Input.is_key_pressed(KEY_S): iz += 1.0
	if Input.is_key_pressed(KEY_W): iz -= 1.0
	var move_dir := Vector3(ix, 0, iz)
	if move_dir.length_squared() > 0.01:
		move_dir = Basis(Vector3.UP, yaw) * move_dir.normalized()
	var speed := 9.2 if Input.is_key_pressed(KEY_SHIFT) else 5.8
	if _on_surf_lane(player.position): speed *= 1.65
	if ferment_time > 0.0: speed *= 1.18
	if dodge_time > 0.0: speed = 14.5
	player.velocity.x = move_toward(player.velocity.x, move_dir.x * speed, 30.0 * delta)
	player.velocity.z = move_toward(player.velocity.z, move_dir.z * speed, 30.0 * delta)
	if not player.is_on_floor(): player.velocity.y -= 22.0 * delta
	var jump_down := Input.is_key_pressed(KEY_SPACE)
	if jump_down and not jump_latch and player.is_on_floor(): player.velocity.y = 8.2
	jump_latch = jump_down
	if spasm_time > 0.0: player.velocity.x += spasm_dir * 7.0 * delta
	if drink_time > 0.0 and drink_wave and absf(player.position.x - drink_wave.position.x) < 1.3: player.velocity.x += drink_dir * 15.0 * delta
	player.move_and_slide()
	invuln = maxf(0.0, invuln - delta)
	ferment_time = maxf(0.0, ferment_time - delta)
	_tick_enemies(delta)
	_update_hud()
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * 0.0025
		pitch = clampf(pitch - event.relative.y * 0.0022, -1.05, 0.65)
		player.rotation.y = yaw
		camera_pivot.rotation.x = pitch
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				else: interact_down = true
			else: interact_down = false
		elif event.pressed and event.button_index == MOUSE_BUTTON_RIGHT: _start_dodge()
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_ESCAPE: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			KEY_TAB: _toggle_view()
			KEY_1: _select_role(0)
			KEY_2: _select_role(1)
			KEY_3: _select_role(2)
			KEY_4: _select_role(3)
			KEY_Q: _cast_skill(0)
			KEY_E: _cast_skill(1)
			KEY_CTRL: _start_dodge()
			KEY_R:
				if mission_phase == "win": _replay_round()

func _start_dodge() -> void:
	if dodge_time <= 0.0: dodge_time = 0.28

func _toggle_view() -> void:
	first_person = not first_person
	camera_1p.current = first_person
	camera_3p.current = not first_person
	body_mesh.visible = not first_person
	head_mesh.visible = not first_person
func _cast_skill(slot: int) -> void:
	if not role_selected: return
	if slot == 0:
		if skill_q_cd > 0.0: return
		skill_q_cd = Q_COOLDOWNS[role_index]
	else:
		if skill_e_cd > 0.0: return
		skill_e_cd = E_COOLDOWNS[role_index]
	match role_index:
		0: _skill_spark(slot)
		1: _skill_kaka(slot)
		2: _skill_bubble(slot)
		3: _skill_shroom(slot)
	_spawn_skill_visual(slot)


func _forward() -> Vector3:
	return Vector3.FORWARD.rotated(Vector3.UP, yaw).normalized()

func _get_target(max_dist := 12.0, min_dot := 0.35) -> CharacterBody3D:
	var best: CharacterBody3D
	var best_score := 9999.0
	var f := _forward()
	for e in enemies:
		if not is_instance_valid(e) or e.get_meta("dead", false) or e.get_meta("engulfed", false): continue
		var off := e.global_position - player.global_position
		var d := off.length()
		if d <= 0.01 or d > max_dist: continue
		var dot := f.dot(off.normalized())
		if dot < min_dot: continue
		var mission_bias := -8.0 if mission_phase == "chase" and e == mouse_target else 0.0
		var score := d + (1.0 - dot) * 4.0 + mission_bias
		if score < best_score:
			best_score = score
			best = e
	return best

func _update_target_ui() -> void:
	if not target_label: return
	var e := _get_target(14.0, 0.2)
	if e:
		if e == mouse_target:
			var mstate := "READY TO CAPTURE" if _mouse_controlled() else "ESCAPING"
			target_label.text = "ELECTRONIC MOUSE  " + mstate
		else:
			target_label.text = "%s  HP %d/%d%s%s" % [String(e.get_meta("kind")), int(e.get_meta("hp")), int(e.get_meta("max_hp")), "  STUN" if float(e.get_meta("stun")) > 0.0 else "", "  PINNED" if float(e.get_meta("pinned")) > 0.0 else ""]
		crosshair.add_theme_color_override("font_color", Color("#75f6ff"))
	else:
		target_label.text = ""
		crosshair.add_theme_color_override("font_color", Color.WHITE)

func _damage_enemy(e: CharacterBody3D, amount: float, stun := 0.0, pin := 0.0, impulse := Vector3.ZERO) -> void:
	if not is_instance_valid(e) or e.get_meta("dead", false): return
	if e == mouse_target: amount = 0.0
	if e != mouse_target:
		var combo_t := float(e.get_meta("combo_t", 0.0))
		var last_role := int(e.get_meta("combo_role", -1))
		var chain := int(e.get_meta("combo_count", 0))
		if combo_t > 0.0 and last_role >= 0 and last_role != role_index:
			chain = maxi(2, chain + 1)
			var bonus := 4.0 + float(chain) * 2.0
			amount += bonus
			stun = maxf(stun, 0.28)
			synergies += 1
			combo_best = maxi(combo_best, chain)
			danger_label.text = "SYNC x%d  %s + %s" % [chain, ROLE_NAMES[last_role], ROLE_NAMES[role_index]]
			_spawn_combo_ring(e.global_position + Vector3.UP * 0.8, chain)
		elif combo_t <= 0.0:
			chain = 1
		e.set_meta("combo_role", role_index)
		e.set_meta("combo_t", 2.6)
		e.set_meta("combo_count", maxi(chain, 1))
	var next_hp := maxf(0.0, float(e.get_meta("hp")) - amount)
	e.set_meta("hit_flash", 0.14)
	hit_shake = maxf(hit_shake, 0.16)
	e.set_meta("hp", next_hp)
	e.set_meta("stun", maxf(float(e.get_meta("stun")), stun))
	e.set_meta("pinned", maxf(float(e.get_meta("pinned")), pin))
	e.velocity += impulse
	_spawn_impact(e.global_position + Vector3.UP * 0.7, ROLE_COLORS[role_index])
	_spawn_damage_number(e.global_position + Vector3.UP * 1.45, int(amount))
	if next_hp <= 0.0:
		e.set_meta("dead", true)
		e.collision_layer = 0
		e.collision_mask = 0
		defeats += 1
		var tw := create_tween()
		tw.tween_property(e, "scale", Vector3(1.5, 0.08, 1.5), 0.16)
		tw.tween_property(e, "scale", Vector3.ZERO, 0.22)
		tw.tween_callback(e.queue_free)

func _spawn_combo_ring(pos: Vector3, chain: int) -> void:
	var ring := MeshInstance3D.new()
	var tor := TorusMesh.new()
	tor.inner_radius = 0.72
	tor.outer_radius = 0.92
	ring.mesh = tor
	ring.position = pos
	ring.rotation.x = PI * 0.5
	var color := Color("#ffe36a") if chain < 3 else Color("#ff79da")
	var mat := _mat(Color(color.r, color.g, color.b, 0.72), true)
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 2.8
	ring.material_override = mat
	add_child(ring)
	ring.scale = Vector3.ONE * 0.25
	var tw := create_tween()
	tw.tween_property(ring, "scale", Vector3.ONE * (1.3 + chain * 0.12), 0.28)
	tw.tween_property(ring, "scale", Vector3.ZERO, 0.12)
	tw.tween_callback(ring.queue_free)

func _spawn_damage_number(pos: Vector3, amount: int) -> void:
	var label := Label3D.new()
	label.text = "-%d" % amount
	label.font_size = 36
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color("#fff1a8")
	label.position = pos
	add_child(label)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(label, "position", pos + Vector3.UP * 1.1, 0.55)
	tw.tween_property(label, "modulate:a", 0.0, 0.55)
	tw.chain().tween_callback(label.queue_free)

func _spawn_impact(pos: Vector3, color: Color) -> void:
	var m := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.28
	sphere.height = 0.56
	m.mesh = sphere
	m.position = pos
	var mat := _mat(Color(color.r, color.g, color.b, 0.55), true)
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 2.4
	m.material_override = mat
	add_child(m)
	var tw := create_tween()
	tw.tween_property(m, "scale", Vector3.ONE * 2.4, 0.18)
	tw.tween_property(m, "scale", Vector3.ZERO, 0.16)
	tw.tween_callback(m.queue_free)

func _tick_enemies(delta: float) -> void:
	for e in enemies:
		if not is_instance_valid(e) or e.get_meta("dead", false): continue
		e.set_meta("combo_t", maxf(0.0, float(e.get_meta("combo_t", 0.0)) - delta))
		if e.get_meta("engulfed", false):
			e.global_position = player.global_position + Vector3.UP * 0.7
			e.velocity = Vector3.ZERO
			continue
		if e == mouse_target:
			_tick_mission_mouse(e, delta)
			continue
		var stun := maxf(0.0, float(e.get_meta("stun")) - delta)
		var pinned := maxf(0.0, float(e.get_meta("pinned")) - delta)
		var big := maxf(0.0, float(e.get_meta("big")) - delta)
		e.set_meta("stun", stun)
		e.set_meta("pinned", pinned)
		e.set_meta("big", big)
		var flash := maxf(0.0, float(e.get_meta("hit_flash")) - delta)
		e.set_meta("hit_flash", flash)
		var mi := e.get_meta("mesh") as MeshInstance3D
		var emat := mi.material_override as StandardMaterial3D if mi else null
		if emat:
			emat.emission_enabled = flash > 0.0
			emat.emission = Color.WHITE
			emat.emission_energy_multiplier = 2.2 if flash > 0.0 else 0.0
		var hpl := e.get_meta("hp_label") as Label3D
		if hpl: hpl.text = "%s\n%d/%d" % [String(e.get_meta("kind")), int(e.get_meta("hp")), int(e.get_meta("max_hp"))]
		e.scale = Vector3.ONE * (1.45 if big > 0.0 else 1.0)
		var slow := 0.45 if _on_fungus(e.global_position) else 1.0
		if stun <= 0.0 and pinned <= 0.0:
			var off := player.global_position - e.global_position
			off.y = 0.0
			if off.length() > 0.7:
				var v := off.normalized() * float(e.get_meta("speed")) * slow
				e.velocity.x = move_toward(e.velocity.x, v.x, 12.0 * delta)
				e.velocity.z = move_toward(e.velocity.z, v.z, 12.0 * delta)
		else:
			e.velocity.x = move_toward(e.velocity.x, 0.0, 16.0 * delta)
			e.velocity.z = move_toward(e.velocity.z, 0.0, 16.0 * delta)
		e.velocity.y -= 18.0 * delta
		e.move_and_slide()
		if e.global_position.distance_to(player.global_position) < 1.15 and invuln <= 0.0:
			hp = maxf(0.0, hp - float(e.get_meta("contact_damage")))
			invuln = 0.85
			damage_shake = 0.22
			player.velocity += (player.global_position - e.global_position).normalized() * 5.0
	if hp <= 0.0:
		hp = 100.0
		player.position = Vector3(0, 1.15, 5.5)
		danger_label.text = "CLAY BODY REASSEMBLED"

func _spawn_swallowed_prop() -> void:
	var body := RigidBody3D.new()
	body.position = Vector3(randf_range(-8.0, 8.0), 7.5, randf_range(-6.0, -2.0))
	body.mass = 1.4
	body.linear_velocity = Vector3(randf_range(-1.8, 1.8), -2.5, randf_range(0.2, 1.5))
	body.angular_velocity = Vector3(randf_range(-2.0, 2.0), randf_range(-2.0, 2.0), randf_range(-2.0, 2.0))
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(randf_range(0.7, 1.4), randf_range(0.5, 1.0), randf_range(0.7, 1.5))
	mi.mesh = box
	mi.material_override = _mat([Color("#56c6e9"), Color("#f0837e"), Color("#d7c26b")].pick_random())
	body.add_child(mi)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = box.size
	col.shape = shape
	body.add_child(col)
	add_child(body)
	swallowed_props.append(body)
	if swallowed_props.size() > 6:
		var old: RigidBody3D = swallowed_props.pop_front()
		if is_instance_valid(old): old.queue_free()
	danger_label.text = "SWALLOWED OBJECT INBOUND"

func _update_acid_valve_visual() -> void:
	if not acid_valve: return
	var ring := acid_valve.get_meta("ring") as MeshInstance3D
	var lab := acid_valve.get_meta("label") as Label3D
	if ring:
		ring.rotation.y += 0.012 if valve_cooldown <= 0.0 else 0.003
		var mat := ring.material_override as StandardMaterial3D
		if mat: mat.emission_energy_multiplier = 1.7 if valve_cooldown <= 0.0 else 0.35
	if lab:
		lab.text = "ACID VALVE  READY" if valve_cooldown <= 0.0 else "ACID VALVE  %.0fs" % valve_cooldown

func _use_acid_valve() -> void:
	if valve_cooldown > 0.0: return
	acid_tide_time = 0.0
	acid_next = maxf(acid_next, 13.0)
	valve_cooldown = 22.0
	danger_label.text = "ACID PRESSURE RELEASED"
	if acid_mesh:
		create_tween().tween_property(acid_mesh, "position:y", -0.12, 0.45)

func _update_living_events(delta: float) -> void:
	acid_next -= delta
	spasm_next -= delta
	drink_next -= delta
	acid_tide_time = maxf(0.0, acid_tide_time - delta)
	spasm_time = maxf(0.0, spasm_time - delta)
	drink_time = maxf(0.0, drink_time - delta)
	if acid_next <= 0.0:
		acid_tide_time = 6.0
		acid_next = 18.0
	if spasm_next <= 0.0:
		spasm_time = 3.2
		spasm_dir *= -1.0
		spasm_next = 15.0
	if drink_next <= 0.0:
		drink_time = 4.5
		drink_dir *= -1.0
		drink_next = 22.0
	var tide := sin((1.0 - acid_tide_time / 6.0) * PI) if acid_tide_time > 0.0 else 0.0
	if acid_mesh:
		acid_mesh.position.y = 0.03 + sin(living_time * 1.9) * 0.035 + tide * 0.38
	if drink_wave:
		drink_wave.visible = drink_time > 0.0
		if drink_time > 0.0:
			var progress := 1.0 - drink_time / 4.5
			drink_wave.position.x = lerpf(-16.0, 16.0, progress) if drink_dir > 0.0 else lerpf(16.0, -16.0, progress)
	var warning := ""
	if acid_next < 2.0 and acid_tide_time <= 0.0: warning = "ACID TIDE IN %.1fs" % acid_next
	if acid_tide_time > 0.0: warning = "ACID TIDE - GET TO HIGH GROUND"
	if spasm_next < 1.8 and spasm_time <= 0.0: warning = "STOMACH SPASM IN %.1fs" % spasm_next
	if spasm_time > 0.0: warning = "STOMACH SPASM - HOLD YOUR LINE"
	if drink_next < 1.8 and drink_time <= 0.0: warning = "SWALLOW WAVE IN %.1fs" % drink_next
	if drink_time > 0.0: warning = "SWALLOW WAVE - USE COVER"
	danger_label.text = warning
	if drink_time > 0.0 or drink_next < 1.8: danger_label.add_theme_color_override("font_color", Color("#79ddff"))
	elif spasm_time > 0.0 or spasm_next < 1.8: danger_label.add_theme_color_override("font_color", Color("#ff9fb6"))
	else: danger_label.add_theme_color_override("font_color", Color("#eaff65"))
	var in_acid := absf(player.position.x) < 6.2 and player.position.z > 2.0 and player.position.z < 7.6
	var on_high_ground := player.position.y > 0.82
	if in_acid and tide > 0.22 and not on_high_ground:
		hp = maxf(0.0, hp - 11.0 * delta)
	camera_pivot.rotation.z = sin(living_time * 16.0) * 0.055 if spasm_time > 0.0 else lerpf(camera_pivot.rotation.z, 0.0, minf(1.0, delta * 6.0))

func _point_in_lane(pos: Vector3, lane: Node3D) -> bool:
	var local := lane.to_local(pos)
	return absf(local.x) < 0.9 and absf(local.z) < 3.7

func _on_surf_lane(pos: Vector3) -> bool:
	for lane in surf_lanes:
		if is_instance_valid(lane) and _point_in_lane(pos, lane): return true
	return false

func _near_bone(pos: Vector3, radius: float) -> bool:
	for bone in bone_structures.duplicate():
		if not is_instance_valid(bone):
			bone_structures.erase(bone)
			continue
		if bone.global_position.distance_to(pos) < radius: return true
	return false

func _on_fungus(pos: Vector3) -> bool:
	for patch in fungus_patches:
		if is_instance_valid(patch) and Vector2(pos.x - patch.position.x, pos.z - patch.position.z).length() < float(patch.get_meta("radius")): return true
	return false

func _tick_zones(delta: float) -> void:
	for lane in surf_lanes.duplicate():
		if not is_instance_valid(lane):
			surf_lanes.erase(lane)
			continue
		var ttl := float(lane.get_meta("ttl")) - delta
		lane.set_meta("ttl", ttl)
		if ttl <= 0.0:
			surf_lanes.erase(lane)
			lane.queue_free()
	for patch in fungus_patches.duplicate():
		if not is_instance_valid(patch):
			fungus_patches.erase(patch)
			continue
		var ttl := float(patch.get_meta("ttl")) - delta
		patch.set_meta("ttl", ttl)
		if Vector2(player.position.x - patch.position.x, player.position.z - patch.position.z).length() < float(patch.get_meta("radius")):
			hp = minf(100.0, hp + 5.0 * delta)
		if ttl <= 0.0:
			fungus_patches.erase(patch)
			patch.queue_free()

func _skill_spark(slot: int) -> void:
	if slot == 0:
		var e := _get_target(14.0, 0.12)
		if e: _damage_enemy(e, 28.0, 2.2, 0.0, _forward() * 3.5)
	else:
		for e in enemies:
			if is_instance_valid(e) and not e.get_meta("dead", false) and e.global_position.distance_to(player.global_position) < 5.2:
				_damage_enemy(e, 16.0, 0.75, 0.0, (e.global_position - player.global_position).normalized() * 2.5)
		var reacted := false
		for zone in surf_lanes + fungus_patches:
			if is_instance_valid(zone) and zone.global_position.distance_to(player.global_position) < 6.5:
				zone.set_meta("ttl", float(zone.get_meta("ttl")) + 3.0)
				zone.set_meta("charged", true)
				reacted = true
				for child in zone.get_children():
					if child is MeshInstance3D:
						var mat := child.material_override as StandardMaterial3D
						if mat: mat.emission_energy_multiplier = 2.8
		if reacted:
			synergies += 1
			danger_label.text = "SYNC: OVERCHARGED BIO ZONE"

func _skill_kaka(slot: int) -> void:
	if slot == 0:
		_spawn_bone_bridge()
	else:
		var e := _get_target(10.0, 0.12)
		if e: _damage_enemy(e, 24.0, 0.0, 4.5, _forward() * 2.0)

func _skill_bubble(slot: int) -> void:
	if slot == 0:
		_spawn_surf_lane()
	elif is_instance_valid(bubble_payload):
		bubble_payload.set_meta("engulfed", false)
		bubble_payload.visible = true
		bubble_payload.collision_layer = 1
		bubble_payload.collision_mask = 1
		bubble_payload.global_position = player.global_position + _forward() * 2.0
		_damage_enemy(bubble_payload, 34.0, 0.4, 0.0, _forward() * 11.0)
		bubble_payload = null
	else:
		var e := _get_target(5.2, 0.05)
		if e:
			bubble_payload = e
			e.set_meta("engulfed", true)
			e.visible = false
			e.collision_layer = 0
			e.collision_mask = 0

func _skill_shroom(slot: int) -> void:
	if slot == 0:
		_spawn_fungus_patch()
	else:
		var e := _get_target(6.5, 0.05)
		if e:
			e.set_meta("big", 4.0)
			_damage_enemy(e, 14.0, 0.0, 0.0)
		else:
			ferment_time = 4.0

func _spawn_bone_bridge() -> void:
	var boosted := _on_fungus(player.position)
	var body := StaticBody3D.new()
	body.position = player.position + _forward() * 3.0 + Vector3(0, 0.25, 0)
	body.rotation.y = yaw
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.35, 0.68, 7.2) if boosted else Vector3(1.05, 0.5, 6.0)
	mi.mesh = box
	mi.material_override = _mat(Color("#f2e8d4"))
	body.add_child(mi)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = box.size
	col.shape = shape
	body.add_child(col)
	add_child(body)
	bone_structures.append(body)
	body.scale = Vector3(1, 0.08, 0.08)
	var tw := create_tween()
	tw.tween_property(body, "scale", Vector3.ONE, 0.24 if boosted else 0.32)
	get_tree().create_timer(12.0 if boosted else 9.0).timeout.connect(body.queue_free)
	if boosted:
		synergies += 1
		danger_label.text = "SYNC: FUNGUS-REINFORCED BONE"

func _spawn_surf_lane() -> void:
	var bone_sync := _near_bone(player.position, 5.0)
	var root := Node3D.new()
	root.position = player.position + _forward() * 3.5 + Vector3(0, 0.08, 0)
	root.rotation.y = yaw
	root.set_meta("ttl", 11.0 if bone_sync else 8.0)
	root.set_meta("bone_sync", bone_sync)
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(2.35, 0.08, 8.6) if bone_sync else Vector3(1.7, 0.08, 7.0)
	mi.mesh = box
	var mat := _mat(Color(1.0, 0.25, 0.48, 0.62), true)
	mat.emission_enabled = true
	mat.emission = Color("#c32255")
	mat.emission_energy_multiplier = 1.5
	if bone_sync: mat.emission_energy_multiplier = 2.2
	mi.material_override = mat
	root.add_child(mi)
	add_child(root)
	surf_lanes.append(root)
	if bone_sync:
		synergies += 1
		danger_label.text = "SYNC: BONE-GUIDED PLASMA RAIL"

func _spawn_fungus_patch() -> void:
	var blood_sync := _on_surf_lane(player.position)
	var root := Node3D.new()
	root.position = player.position + Vector3(0, 0.06, 0)
	root.set_meta("ttl", 12.0 if blood_sync else 9.0)
	root.set_meta("radius", 4.1 if blood_sync else 3.2)
	root.set_meta("blood_sync", blood_sync)
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(8.0, 0.06, 8.0) if blood_sync else Vector3(6.2, 0.06, 6.2)
	mi.mesh = box
	var mat := _mat(Color(0.45, 0.92, 0.28, 0.38), true)
	mat.emission_enabled = true
	mat.emission = Color("#2d8a2a")
	mat.emission_energy_multiplier = 2.0 if blood_sync else 1.3
	mi.material_override = mat
	root.add_child(mi)
	add_child(root)
	root.scale = Vector3(0.08, 1, 0.08)
	create_tween().tween_property(root, "scale", Vector3.ONE, 0.3 if blood_sync else 0.36)
	fungus_patches.append(root)
	if blood_sync:
		synergies += 1
		danger_label.text = "SYNC: PLASMA-CARRIED FUNGUS"

func _spawn_skill_visual(slot: int) -> void:
	var pulse := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.55
	sphere.height = 1.1
	pulse.mesh = sphere
	var forward := _forward()
	var target_scale: Vector3 = [Vector3(0.22,0.22,6.0), Vector3(1.0,3.2,1.0), Vector3(3.8,3.8,3.8), Vector3(5.2,0.16,5.2)][role_index]
	var offset := forward * 2.0 if role_index < 2 else Vector3.ZERO
	pulse.position = player.position + Vector3(0, 0.3, 0) + offset
	pulse.rotation.y = yaw
	pulse.scale = target_scale * 0.06
	var color: Color = ROLE_COLORS[role_index]
	if slot == 1: color = color.lightened(0.18)
	var mat := _mat(Color(color.r, color.g, color.b, 0.28), true)
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 1.9
	pulse.material_override = mat
	add_child(pulse)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(pulse, "scale", target_scale, 0.42)
	var active_camera := camera_1p if first_person else camera_3p
	var base_fov := 72.0 if first_person else 66.0
	active_camera.fov = base_fov + 4.0
	tw.tween_property(active_camera, "fov", base_fov, 0.24)
	tw.chain().tween_callback(pulse.queue_free)


func _build_mission() -> void:
	entrance = Node3D.new()
	entrance.name = "ReturnCapsule"
	entrance.position = Vector3(-12.4, 0.1, -0.2)
	var cap_mesh := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 1.1
	cyl.bottom_radius = 1.1
	cyl.height = 2.5
	cap_mesh.mesh = cyl
	cap_mesh.position.y = 1.25
	var cap_mat := _mat(Color("#72dfff"))
	cap_mat.emission_enabled = true
	cap_mat.emission = Color("#176b84")
	cap_mat.emission_energy_multiplier = 1.4
	cap_mesh.material_override = cap_mat
	entrance.add_child(cap_mesh)
	var cap_label := Label3D.new()
	cap_label.text = "RETURN CAPSULE"
	cap_label.position = Vector3(0, 2.9, 0)
	cap_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	entrance.add_child(cap_label)
	add_child(entrance)

	var clue_positions = [Vector3(-7.0, 0.35, -4.5), Vector3(1.2, 0.35, -4.8), Vector3(9.1, 0.35, 1.0)]
	var clue_names = ["ABNORMAL CURRENT", "PLASTIC SCRATCHES", "RHYTHMIC VIBRATION"]
	for i in range(3):
		var root := Node3D.new()
		root.position = clue_positions[i]
		root.set_meta("index", i)
		root.set_meta("done", false)
		var mi := MeshInstance3D.new()
		var orb := SphereMesh.new()
		orb.radius = 0.48
		orb.height = 0.96
		mi.mesh = orb
		var mat := _mat(Color("#ffe36d"))
		mat.emission_enabled = true
		mat.emission = Color("#ffad22")
		mat.emission_energy_multiplier = 2.0
		mi.material_override = mat
		root.add_child(mi)
		root.set_meta("mesh", mi)
		var lab := Label3D.new()
		lab.text = clue_names[i]
		lab.position = Vector3(0, 1.2, 0)
		lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		root.add_child(lab)
		root.set_meta("label", lab)
		add_child(root)
		clue_nodes.append(root)

	_make_mucus_route(Vector3(-2.5, 0.06, -1.7), -0.7)
	_make_mucus_route(Vector3(6.7, 0.06, -2.0), 0.85)
	var layer := CanvasLayer.new()
	add_child(layer)
	mission_label = Label.new()
	mission_label.position = Vector2(290, 122)
	mission_label.size = Vector2(700, 42)
	mission_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mission_label.add_theme_font_size_override("font_size", 21)
	layer.add_child(mission_label)
	interact_label = Label.new()
	interact_label.position = Vector2(390, 435)
	interact_label.size = Vector2(500, 36)
	interact_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	interact_label.add_theme_font_size_override("font_size", 19)
	layer.add_child(interact_label)
	capture_bar = ProgressBar.new()
	capture_bar.position = Vector2(440, 475)
	capture_bar.size = Vector2(400, 18)
	capture_bar.min_value = 0.0
	capture_bar.max_value = 1.0
	capture_bar.show_percentage = false
	capture_bar.visible = false
	layer.add_child(capture_bar)
	_build_win_panel(layer)
	_refresh_mission_ui()

func _build_win_panel(layer: CanvasLayer) -> void:

	win_panel = Control.new()
	win_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	win_panel.visible = false
	layer.add_child(win_panel)
	var shade := ColorRect.new()
	shade.color = Color(0.04, 0.02, 0.055, 0.9)
	shade.position = Vector2(300, 175)
	shade.size = Vector2(680, 370)
	win_panel.add_child(shade)
	var title := Label.new()
	title.text = "TREATMENT COMPLETE"
	title.position = Vector2(340, 215)
	title.size = Vector2(600, 62)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	win_panel.add_child(title)
	win_label = Label.new()
	win_label.position = Vector2(390, 300)
	win_label.size = Vector2(500, 110)
	win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_label.add_theme_font_size_override("font_size", 21)
	win_panel.add_child(win_label)
	var again := Button.new()
	again.text = "RUN AGAIN  [R]"
	again.position = Vector2(515, 440)
	again.size = Vector2(250, 62)
	again.pressed.connect(_replay_round)
	win_panel.add_child(again)

func _make_mucus_route(pos: Vector3, rot_y: float) -> void:

	var root := Node3D.new()
	root.position = pos
	root.rotation.y = rot_y
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(2.2, 0.05, 6.2)
	mi.mesh = box
	var mat := _mat(Color(0.95, 0.25, 0.68, 0.34), true)
	mat.emission_enabled = true
	mat.emission = Color("#9d2b72")
	mat.emission_energy_multiplier = 1.25
	mi.material_override = mat
	root.add_child(mi)
	add_child(root)
	mucus_routes.append(root)

func _clue_count() -> int:
	var count := 0
	for done in clue_done:
		if done: count += 1
	return count

func _refresh_mission_ui() -> void:
	if not mission_label: return
	match mission_phase:
		"diagnose": mission_label.text = "DIAGNOSE  %d/3  - inspect glowing anomalies" % _clue_count()
		"chase":
			var md := player.global_position.distance_to(mouse_target.global_position) if is_instance_valid(mouse_target) else 0.0
			mission_label.text = "CHASE  - electronic mouse  %.1fm" % md
		"return":
			var rd := player.global_position.distance_to(entrance.global_position) if entrance else 0.0
			mission_label.text = "RETURN  - capsule  %.1fm" % rd
		"win": mission_label.text = "TREATMENT COMPLETE"

func _update_mission(delta: float) -> void:

	if not role_selected: return
	if mission_phase != "win": round_time += delta
	if mission_phase == "return" and mouse_caught and is_instance_valid(mouse_target):
		mouse_target.visible = true
		mouse_target.global_position = player.global_position - _forward() * 0.9 + Vector3.UP * 0.9
		mouse_target.velocity = Vector3.ZERO
	var holding := interact_down or Input.is_key_pressed(KEY_F)
	var prompt := ""
	var action := ""
	var duration := 0.0
	var action_index := -1
	if mission_phase == "diagnose":
		for i in range(clue_nodes.size()):
			if clue_done[i]: continue
			if player.global_position.distance_to(clue_nodes[i].global_position) < 1.9:
				prompt = "HOLD F / LMB  DIAGNOSE"
				action = "clue"
				action_index = i
				duration = 0.45
				break
	elif mission_phase == "chase" and is_instance_valid(mouse_target):
		var md := player.global_position.distance_to(mouse_target.global_position)
		if md < 2.0:
			if _mouse_controlled():
				prompt = "HOLD F / LMB  CAPTURE"
				action = "capture"
				duration = 0.72
			else:
				prompt = "CONTROL TARGET WITH Q/E FIRST"
	elif mission_phase == "return" and entrance:
		if player.global_position.distance_to(entrance.global_position) < 2.35:
			prompt = "HOLD F / LMB  DELIVER TO CAPSULE"
			action = "deliver"
			duration = 0.55

	if action == "" and acid_valve and player.global_position.distance_to(acid_valve.global_position) < 2.0:
		if valve_cooldown <= 0.0:
			prompt = "HOLD F / LMB  RELEASE ACID PRESSURE"
			action = "valve"
			duration = 0.55
		else:
			prompt = "ACID VALVE COOLING  %.0fs" % valve_cooldown
	interact_label.text = prompt
	if action != "" and holding:
		interact_progress += delta
		capture_bar.visible = true
		capture_bar.value = clampf(interact_progress / duration, 0.0, 1.0)
		crosshair.scale = Vector2.ONE * (1.0 + capture_bar.value * 0.35)
		interact_label.add_theme_color_override("font_color", Color("#a7f5ff"))
		if interact_progress >= duration:
			interact_progress = 0.0
			capture_bar.value = 0.0
			match action:
				"clue": _complete_clue(action_index)
				"capture": _catch_mouse()
				"deliver": _win_round()
				"valve": _use_acid_valve()
	else:
		crosshair.scale = Vector2.ONE
		interact_label.add_theme_color_override("font_color", Color.WHITE)
		interact_progress = maxf(0.0, interact_progress - delta * 3.0)
		capture_bar.visible = interact_progress > 0.02 and action != ""
		if duration > 0.0: capture_bar.value = clampf(interact_progress / duration, 0.0, 1.0)
	_refresh_mission_ui()

func _complete_clue(index: int) -> void:
	if index < 0 or index >= clue_done.size() or clue_done[index]: return
	clue_done[index] = true
	var root := clue_nodes[index]
	root.set_meta("done", true)
	var mi := root.get_meta("mesh") as MeshInstance3D
	if mi:
		var mat := mi.material_override as StandardMaterial3D
		if mat:
			mat.albedo_color = Color("#6c765f")
			mat.emission_energy_multiplier = 0.15
	var lab := root.get_meta("label") as Label3D
	if lab: lab.text = "DIAGNOSED"
	if _clue_count() >= 3:
		mission_phase = "chase"
		_spawn_mission_mouse()
		danger_label.text = "FOREIGN OBJECT CONFIRMED"

func _spawn_mission_mouse() -> void:
	if is_instance_valid(mouse_target): return
	_spawn_enemy("TOY_MOUSE", Vector3(8.6, 0.25, -1.5), Color("#9cf26b"), 9999.0, 6.6)
	mouse_target = enemies[-1]
	mouse_target.set_meta("contact_damage", 0.0)
	mouse_target.set_meta("fake_phase", 0.0)
	_decorate_mouse(mouse_target)
	var lab := mouse_target.get_meta("hp_label") as Label3D
	if lab: lab.text = "ELECTRONIC MOUSE"


func _decorate_mouse(e: CharacterBody3D) -> void:
	var base := e.get_meta("mesh") as MeshInstance3D
	if base:
		base.scale = Vector3(1.15, 0.68, 1.45)
		base.position.y = 0.58
		base.material_override = _mat(Color("#9cf26b"))
	var dark := _mat(Color("#3d2940"))
	for sx in [-1.0, 1.0]:
		var wheel := MeshInstance3D.new()
		var wm := CylinderMesh.new()
		wm.top_radius = 0.2
		wm.bottom_radius = 0.2
		wm.height = 0.16
		wheel.mesh = wm
		wheel.rotation.z = PI * 0.5
		wheel.position = Vector3(0.5 * sx, 0.3, 0.12)
		wheel.material_override = dark
		e.add_child(wheel)
		var ear := MeshInstance3D.new()
		var em := SphereMesh.new()
		em.radius = 0.22
		em.height = 0.44
		ear.mesh = em
		ear.scale = Vector3(0.7, 1.15, 0.55)
		ear.position = Vector3(0.3 * sx, 1.08, -0.24)
		ear.material_override = _mat(Color("#f3a3c5"))
		e.add_child(ear)

	var nose := MeshInstance3D.new()
	var nm := SphereMesh.new()
	nm.radius = 0.12
	nm.height = 0.24
	nose.mesh = nm
	nose.position = Vector3(0, 0.58, -0.82)
	var nose_mat := _mat(Color("#ff5b77"))
	nose_mat.emission_enabled = true
	nose_mat.emission = Color("#c61c45")
	nose_mat.emission_energy_multiplier = 1.7
	nose.material_override = nose_mat
	e.add_child(nose)
	var tail := MeshInstance3D.new()
	var tm := CylinderMesh.new()
	tm.top_radius = 0.055
	tm.bottom_radius = 0.055
	tm.height = 1.25
	tail.mesh = tm
	tail.rotation.x = PI * 0.5
	tail.rotation.z = 0.18
	tail.position = Vector3(0.18, 0.48, 0.95)
	tail.material_override = _mat(Color("#f0a3bd"))
	e.add_child(tail)

func _mouse_controlled() -> bool:
	if not is_instance_valid(mouse_target): return false
	if bubble_payload == mouse_target: return true
	if float(mouse_target.get_meta("stun")) > 0.0: return true
	if float(mouse_target.get_meta("pinned")) > 0.0: return true
	return _on_fungus(mouse_target.global_position)

func _catch_mouse() -> void:
	if not is_instance_valid(mouse_target): return
	if bubble_payload == mouse_target: bubble_payload = null
	mouse_target.set_meta("engulfed", false)
	mouse_target.visible = true
	mouse_target.collision_layer = 0
	mouse_target.collision_mask = 0
	mouse_caught = true
	mission_phase = "return"
	interact_down = false
	danger_label.text = "TARGET SECURED - RETURN TO CAPSULE"

func _win_round() -> void:
	if mission_phase != "return": return
	mission_phase = "win"
	if is_instance_valid(mouse_target): mouse_target.visible = false
	win_panel.visible = true
	win_label.text = "Electronic mouse removed
Time  %.1fs
KOs  %d   Sync  %d   Best x%d
Patient stabilized" % [round_time, defeats, synergies, combo_best]
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	interact_down = false
	capture_bar.visible = false
	interact_label.text = ""

func _replay_round() -> void:
	get_tree().reload_current_scene()

func _mouse_on_mucus(pos: Vector3) -> bool:
	for route in mucus_routes:
		if not is_instance_valid(route): continue
		var local := route.to_local(pos)
		if absf(local.x) < 1.15 and absf(local.z) < 3.2: return true
	return false

func _tick_mission_mouse(e: CharacterBody3D, delta: float) -> void:
	if mission_phase != "chase":
		e.velocity = Vector3.ZERO
		return
	var stun := maxf(0.0, float(e.get_meta("stun")) - delta)
	var pinned := maxf(0.0, float(e.get_meta("pinned")) - delta)
	e.set_meta("stun", stun)
	e.set_meta("pinned", pinned)
	var slowed := _on_fungus(e.global_position)
	var route_boost := 1.38 if _mouse_on_mucus(e.global_position) else 1.0
	if stun > 0.0 or pinned > 0.0:
		e.velocity.x = move_toward(e.velocity.x, 0.0, 22.0 * delta)
		e.velocity.z = move_toward(e.velocity.z, 0.0, 22.0 * delta)
	else:
		var away := e.global_position - player.global_position
		away.y = 0.0
		if away.length() < 0.2: away = Vector3.RIGHT
		var side := Vector3(-away.z, 0, away.x).normalized()
		var feint := sin(living_time * 5.4 + e.global_position.x * 0.7) * 0.82
		var flee_dir := (away.normalized() + side * feint).normalized()
		var speed := 6.6 * route_boost * (0.48 if slowed else 1.0)
		e.velocity.x = move_toward(e.velocity.x, flee_dir.x * speed, 24.0 * delta)
		e.velocity.z = move_toward(e.velocity.z, flee_dir.z * speed, 24.0 * delta)
	e.velocity.y -= 18.0 * delta
	e.move_and_slide()
	var planar := Vector2(e.velocity.x, e.velocity.z)
	if planar.length() > 0.4: e.rotation.y = atan2(-e.velocity.x, -e.velocity.z)
	e.position.x = clampf(e.position.x, -13.3, 13.3)
	e.position.z = clampf(e.position.z, -7.6, 7.6)

	if drink_time > 0.0 and drink_wave and absf(e.position.x - drink_wave.position.x) < 1.35:
		e.velocity.x += drink_dir * 8.0 * delta
	var lab := e.get_meta("hp_label") as Label3D
	if lab:
		var state := ""
		if pinned > 0.0: state = "  PINNED"
		elif stun > 0.0: state = "  STUNNED"
		elif slowed: state = "  SLOWED"
		elif route_boost > 1.0: state = "  SHORTCUT BOOST"
		lab.text = "ELECTRONIC MOUSE" + state

# GODOT_PHASE2_GAMEPLAY
# GODOT_PHASE3_MISSION
# GODOT_PHASE3_POLISH
# GODOT_PHASE4_MAP_SYNC
# GODOT_PHASE4_ZONE_SYNC
# GODOT_PHASE2_POLISH

# GODOT_POLISH_V1

# GODOT_ROLE_SELECT_V1

# GODOT_ROLE_CARDS_V1
