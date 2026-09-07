extends Node3D

const ROLE_NAMES = ["SPARK", "KAKA", "BUBBLE", "SHROOM"]
const ROLE_COLORS = [Color("#ffd83f"), Color("#f2e8d4"), Color("#63dcff"), Color("#b989ff")]
const ROLE_SKILLS = [["Conductive Mark", "Neural Storm"], ["Long Bone", "Bone Charge"], ["Split Decoy", "Regurgitate"], ["Fungus Network", "Ferment Burst"]]
const Q_COOLDOWNS = [5.0, 4.5, 7.0, 5.0]
const E_COOLDOWNS = [8.0, 6.5, 6.0, 7.5]
const PRIMARY_ATTACK_COOLDOWNS = [0.16, 0.24, 1.0, 0.36]
const PRIMARY_ATTACK_RANGES = [12.5, 14.0, 2.2, 10.5]
const SECONDARY_ATTACK_COOLDOWNS = [2.8, 2.6, 3.0, 4.0]
const PRIMARY_ATTACK_NAMES = ["ARC STREAM", "BONE NAILS", "MEGA ROLL", "SPORE BLOOM"]
const SECONDARY_ATTACK_NAMES = ["LIGHTNING FORM", "BONE HOOK", "PLASMA SLING", "PUPPET THREAD"]
const ROLE_VISUAL_SCALES = [0.90, 0.92, 0.91, 0.88]
const CharacterFactory = preload("res://scripts/character_factory.gd")
const MapFactory = preload("res://scripts/map_factory.gd")
const SkillVFX = preload("res://scripts/skill_vfx.gd")
const EnemyFactory = preload("res://scripts/enemy_factory.gd")
const NetworkState = preload("res://scripts/network_state.gd")
const ShopFactory = preload("res://scripts/shop_factory.gd")
const FrontendUI = preload("res://scripts/frontend_ui.gd")
const WorldExpansionFactory = preload("res://scripts/world_expansion_factory.gd")
const StomachAnatomyFactory = preload("res://scripts/stomach_anatomy_factory.gd")
const OrganWorldFactory = preload("res://scripts/organ_world_factory.gd")
const HostBoss = preload("res://scripts/host_boss.gd")
const TerrainWorld = preload("res://scripts/terrain_world.gd")
const CharacterArt = preload("res://scripts/art18_character.gd")
const EnvironmentArt = preload("res://scripts/art18_environment.gd")

var player: CharacterBody3D
var camera_pivot: Node3D
var camera_3p: Camera3D
var camera_1p: Camera3D
var spring_arm: SpringArm3D
var body_mesh: MeshInstance3D
var head_mesh: MeshInstance3D
var character_visual: Node3D
var first_person_viewmodel: Node3D
var inventory_ui: CanvasLayer
var inventory_open := false
var map_visual_root: Node3D
var world_expansion_root: Node3D
var stomach_anatomy_root: Node3D
var organ_world_root: Node3D
var organ_world_data: Dictionary = {}
var organ_props: Array[Node3D] = []
var organ_prop_uses := 0
var host_boss
var terrain_world
var anim_cast_time := 0.0
var anim_cast_slot := 0
var anim_hurt_time := 0.0
var anim_reassemble_time := 0.0
var anim_land_time := 0.0
var ko_time := 0.0
var was_on_floor := false
var status_label: Label
var help_label: Label
var view_label: Label
var crosshair: Label
var role_index := 0
var first_person := true
var yaw := 0.0
var pitch := -0.18
var dodge_time := 0.0
var jump_latch := false
var skill_q_cd := 0.0
var skill_e_cd := 0.0
var primary_attack_cd := 0.0
var secondary_attack_cd := 0.0
var primary_hold := false
var secondary_hold := false
var kaka_charge_time := 0.0
var kaka_charge_nails := 0
var kaka_charge_visual: Node3D
var kaka_rush_time := 0.0
var kaka_rush_hits: Dictionary = {}
var bone_projectiles: Array[Node3D] = []
var bubble_roll_charge := 0.0
var bubble_roll_time := 0.0
var bubble_roll_power := 0.0
var bubble_roll_hits: Dictionary = {}
var bubble_jump_charge := 0.0
var bubble_airborne := false
var bubble_jump_elapsed := 0.0
var bubble_decoy: Node3D
var bubble_decoy_time := 0.0
var spark_mark_target: Node3D
var spark_mark_position := Vector3.ZERO
var spark_mark_visual: Node3D
var spark_mark_time := 0.0
var clay_corpses: Array[CharacterBody3D] = []
var puppet_command_target: CharacterBody3D
var hit_confirm_time := 0.0
var hit_confirm_damage := 0
var hit_confirm_kill := false
var combat_flow := 0
var combat_flow_time := 0.0
var role_selected := false
var role_panel: Control
var living_time := 0.0
var mounds: Array[MeshInstance3D] = []
var acid_mesh: MeshInstance3D
var drink_wave: MeshInstance3D
var danger_label: Label
var target_label: Label
var toast_label: Label
var toast_time := 0.0
var story_label: Label
var story_time := 0.0
var story_chapter := 0
var enemies: Array[CharacterBody3D] = []
var surf_lanes: Array[Node3D] = []
var bone_structures: Array[Node3D] = []
var fungus_patches: Array[Node3D] = []
var hp := 100.0
var invuln := 0.0
var dodge_success_lock := 0.0
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
var interact_action_key := ""
var interact_requires_release := false
var round_time := 0.0
var acid_valve: Node3D
var valve_cooldown := 0.0
var swallow_next := 11.0
var swallowed_props: Array[RigidBody3D] = []
var synergies := 0
var combo_best := 0
var credits := 30
var purchases := 0
var shop_root: Node3D
var shop_pads: Array[Node3D] = []
var acid_umbrella_time := 0.0
var plasma_soda_time := 0.0
var catnip_time := 0.0
var catnip_beacon: Node3D
var front_ui: Dictionary = {}
var game_paused := false
var current_front_screen := "main"
var settings_from_pause := false
var quit_return_screen := "main"
var mouse_sensitivity := 1.0
var camera_fov := 68.0
var selected_level_id := "cat_stomach"
var mouth_intro: Node3D
var escape_finale: Node3D
var vertical_stomach: Node3D
var combat_hud: CanvasLayer
var world_scale := 1.0
var world_layout: Node
var tactical_map: Control
var impact_feedback: Control
var clinic_system: Node3D
var anatomy_route: Node3D
static var reload_front_target := "main"
func _ready() -> void:
	_build_environment()
	_build_enemies()
	_build_player()
	_build_hud()
	_build_mission()
	_build_shop()
	mouth_intro = preload("res://scripts/mouth_entry.gd").new()
	add_child(mouth_intro)
	mouth_intro.build(self)
	vertical_stomach = preload("res://scripts/vertical_stomach.gd").new()
	add_child(vertical_stomach)
	vertical_stomach.build()
	_set_role(0)
	_build_role_select()
	role_panel.visible = false
	_build_frontend()
	_show_front(reload_front_target if reload_front_target in ["main", "levels"] else "main")
	reload_front_target = "main"
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	combat_hud = preload("res://scripts/combat_hud.gd").new()
	add_child(combat_hud)
	combat_hud.build(self)
	world_layout = preload("res://scripts/world_scale.gd").new()
	add_child(world_layout)
	world_layout.build(self)
	var tactical_layer := CanvasLayer.new()
	tactical_layer.layer = 14
	add_child(tactical_layer)
	tactical_map = preload("res://scripts/tactical_map.gd").new()
	tactical_layer.add_child(tactical_map)
	tactical_map.build(self)
	var impact_layer := CanvasLayer.new()
	impact_layer.layer = 15
	add_child(impact_layer)
	impact_feedback = preload("res://scripts/impact_feedback.gd").new()
	impact_layer.add_child(impact_feedback)
	impact_feedback.build(self)
	clinic_system = preload("res://scripts/clinic_system.gd").new()
	add_child(clinic_system)
	clinic_system.build(self)
	anatomy_route = preload("res://scripts/anatomy_route.gd").new()
	add_child(anatomy_route)
	anatomy_route.build(self)
	first_person_viewmodel = preload("res://scripts/first_person_viewmodel.gd").new()
	camera_1p.add_child(first_person_viewmodel)
	first_person_viewmodel.build(self)
	inventory_ui = preload("res://scripts/inventory_ui.gd").new()
	add_child(inventory_ui)
	inventory_ui.build(self)

func role_upgrade_level(index := -1) -> int:
	if not is_instance_valid(clinic_system): return 0
	return int(clinic_system.levels[role_index if index<0 else clampi(index,0,3)])

func clinic_recovery_count() -> int:
	return int(clinic_system.completed) if is_instance_valid(clinic_system) else 0

func world_point(p: Vector3) -> Vector3:
	return p * Vector3(world_scale,1.0,world_scale)

func authored_point(p: Vector3) -> Vector3:
	return p / Vector3(world_scale,1.0,world_scale)

func _mat(color: Color, transparent := false) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.88
	if transparent:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return mat

func _build_environment() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#351025")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#d97696")
	env.ambient_light_energy = 0.58
	world_env.environment = env
	add_child(world_env)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -35, 0)
	light.light_color = Color("#ffd9cf")
	light.light_energy = 2.2
	light.shadow_enabled = true
	add_child(light)
	var fill := OmniLight3D.new()
	fill.position = Vector3(0, 6, 1)
	fill.light_color = Color("#ff7ba7")
	fill.light_energy = 5.5
	fill.omni_range = 34.0
	add_child(fill)
	_make_static_box(Vector3(0, -0.4, 0), Vector3(46, 0.8, 28), Color("#8d4165"))
	_make_acid(Vector3(0, 0.03, 4.8), Vector2(12, 5.4))
	_make_mound(Vector3(-8.0, 0.1, -2.45), Vector3(3.25, 0.72, 2.30), Color("#a84c70"))
	_make_mound(Vector3(5.9, 0.1, -3.35), Vector3(3.75, 0.90, 2.60), Color("#7e3c63"))
	_make_mound(Vector3(10.0, 0.1, 2.65), Vector3(2.75, 0.62, 2.00), Color("#b55778"))
	_make_static_box(Vector3(-4.5, 0.35, 1.0), Vector3(1.8, 0.7, 1.2), Color("#53bce6"))
	_make_static_box(Vector3(4.2, 0.45, 2.6), Vector3(2.0, 0.9, 1.1), Color("#e95b68"))
	_make_drink_wave()
	_build_phase4_map()
	_build_acid_valve()
	map_visual_root = MapFactory.build(self)
	world_expansion_root = WorldExpansionFactory.build(self)
	stomach_anatomy_root = StomachAnatomyFactory.build(self)
	organ_world_data = OrganWorldFactory.build(self)
	organ_world_root = organ_world_data.get("root") as Node3D
	for prop in organ_world_data.get("props", []):
		organ_props.append(prop as Node3D)
	terrain_world = TerrainWorld.new()
	terrain_world.name = "ConnectedOrganTerrain"
	add_child(terrain_world)
	terrain_world.build(self)
	map_visual_root.get_node("StomachShell").visible = false
	EnvironmentArt.apply(self)

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
	mi.visible = false
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
	var blocker := StaticBody3D.new()
	blocker.name = "CameraBlocker"
	blocker.position = pos
	blocker.collision_layer = 2
	blocker.collision_mask = 0
	var bc := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(scale_v.x * 1.55, maxf(0.6, scale_v.y * 1.5), scale_v.z * 1.55)
	bc.shape = bs
	blocker.add_child(bc)
	add_child(blocker)
	mounds.append(m)

func _make_drink_wave() -> void:
	drink_wave = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.2, 0.12, 25.0)
	drink_wave.mesh = box
	drink_wave.position = Vector3(-24, 0.18, 0)
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
	var mat := _mat(Color(0.18, 0.82, 0.04, 0.74), true)
	mat.emission_enabled = true
	mat.emission = Color("#5ef52a")
	mat.emission_energy_multiplier = 1.75
	m.material_override = mat
	add_child(m)
	acid_mesh = m

func _build_enemies() -> void:
	_spawn_enemy("HAIRBALL", Vector3(-5.5, 0.2, -0.5), Color("#744b7a"), 80.0, 2.5)
	_spawn_enemy("HAIRBALL", Vector3(6.5, 0.2, -1.8), Color("#744b7a"), 80.0, 2.5)
	_spawn_enemy("PLATELET", Vector3(-1.8, 0.2, 3.3), Color("#e85e67"), 55.0, 3.4)
	_spawn_enemy("PARASITE", Vector3(8.5, 0.2, 3.2), Color("#71d79c"), 120.0, 2.9)
	_spawn_enemy("HAIRBALL", Vector3(-18.5, 0.2, -4.5), Color("#8a557e"), 92.0, 2.45, true, "FOREIGN BODY GRAVEYARD")
	_spawn_enemy("PARASITE", Vector3(-16.5, 0.2, 4.5), Color("#70c986"), 130.0, 2.75, true, "FOREIGN BODY GRAVEYARD")
	_spawn_enemy("PLATELET", Vector3(17.0, 0.2, -4.0), Color("#ed6d73"), 64.0, 3.25, true, "PLATELET CHECKPOINT")
	_spawn_enemy("PLATELET", Vector3(19.0, 0.2, 4.4), Color("#d94e66"), 64.0, 3.35, true, "PLATELET CHECKPOINT")
	_spawn_enemy("PARASITE", Vector3(-4.5, 0.2, -11.0), Color("#78e1a7"), 138.0, 2.8, true, "NERVE CHOIR")
	_spawn_enemy("HAIRBALL", Vector3(4.5, 0.2, -10.5), Color("#6c477c"), 96.0, 2.55, true, "NERVE CHOIR")
	for spec in organ_world_data.get("enemy_specs", []):
		_spawn_enemy(String(spec["kind"]), spec["pos"] as Vector3, spec["accent"] as Color, float(spec["hp"]), float(spec["speed"]), true, String(spec["territory"]))
		var spawned := enemies[-1]
		OrganWorldFactory.decorate_enemy(spawned, String(spec["display_name"]), spec["accent"] as Color, String(spec["trait"]))

func _spawn_enemy(kind: String, pos: Vector3, color: Color, max_hp: float, speed: float, wild := false, territory := "") -> void:
	var e := CharacterBody3D.new()
	e.name = kind
	e.position = pos
	e.set_meta("kind", kind)
	e.set_meta("hp", max_hp)
	e.set_meta("max_hp", max_hp)
	e.set_meta("speed", speed)
	e.set_meta("home", pos)
	e.set_meta("wild_spawn", wild)
	e.set_meta("territory", territory)
	e.set_meta("aggro_radius", 7.5)
	e.set_meta("stun", 0.0)
	e.set_meta("pinned", 0.0)
	e.set_meta("big", 0.0)
	e.set_meta("hit_flash", 0.0)
	e.set_meta("base_color", color)
	e.set_meta("contact_damage", 12.0 if kind == "PARASITE" else (6.0 if kind == "PLATELET" else 9.0))
	e.set_meta("combo_role", -1)
	e.set_meta("combo_t", 0.0)
	e.set_meta("combo_count", 0)
	e.set_meta("attack_windup", 0.0)
	e.set_meta("attack_cd", 0.0)
	e.set_meta("goo_slow", 0.0)
	e.set_meta("controlled", 0.0)
	e.set_meta("control_attack_cd", 0.0)
	e.set_meta("bone_pins", 0)
	var built: Dictionary = EnemyFactory.build(e, kind)
	var visual := built["visual"] as Node3D
	var mi := built["main_mesh"] as MeshInstance3D
	e.set_meta("visual", visual)
	e.set_meta("mesh", mi)
	var hp_label := Label3D.new()
	hp_label.position = Vector3(0, 2.05 if kind == "PARASITE" else 1.82, 0)
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
	capsule.radius = 0.39
	capsule.height = 1.46
	collision.shape = capsule
	collision.position.y = 0.73
	player.add_child(collision)
	character_visual = Node3D.new()
	character_visual.name = "RoleVisual"
	player.add_child(character_visual)
	var role_parts: Dictionary = CharacterFactory.build_role(character_visual, 0)
	body_mesh = role_parts["body"] as MeshInstance3D
	head_mesh = role_parts["head"] as MeshInstance3D
	camera_pivot = Node3D.new()
	camera_pivot.position = Vector3(0, 1.48, 0)
	player.add_child(camera_pivot)
	spring_arm = SpringArm3D.new()
	spring_arm.spring_length = 5.85
	spring_arm.margin = 0.18
	spring_arm.collision_mask = 3
	camera_pivot.add_child(spring_arm)
	camera_3p = Camera3D.new()
	camera_3p.fov = 68.0
	spring_arm.add_child(camera_3p)
	camera_1p = Camera3D.new()
	camera_1p.position = Vector3(0, 0.28, -0.18)
	camera_1p.fov = 72.0
	camera_1p.near = 0.03
	camera_pivot.add_child(camera_1p)
	camera_1p.current = true
	camera_3p.current = false
	camera_pivot.rotation.x = pitch

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	status_label = Label.new()
	status_label.position = Vector2(18, 16)
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color("eee5d3"))
	var status_back := Panel.new()
	status_back.position = Vector2(-10,-8)
	status_back.size = Vector2(720,90)
	status_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_back.show_behind_parent = true
	var status_style := StyleBoxFlat.new()
	status_style.bg_color = Color(0.075,0.105,0.11,0.86)
	status_style.set_corner_radius_all(8)
	status_back.add_theme_stylebox_override("panel",status_style)
	status_label.add_child(status_back)
	layer.add_child(status_label)
	view_label = Label.new()
	view_label.position = Vector2(1030, 18)
	view_label.add_theme_font_size_override("font_size", 18)
	layer.add_child(view_label)
	help_label = Label.new()
	help_label.position = Vector2(18, 650)
	help_label.text = "WASD move | LMB primary / RMB secondary | Q/E skills | F interact | Ctrl dodge | Tab inventory | V view | Esc menu"
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
	toast_label = Label.new()
	toast_label.position = Vector2(390, 175)
	toast_label.size = Vector2(500, 42)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.add_theme_font_size_override("font_size", 20)
	toast_label.add_theme_color_override("font_color", Color("#fff0a8"))
	toast_label.visible = false
	layer.add_child(toast_label)

func _toast(text: String, color := Color("#fff0a8"), time := 2.2) -> void:
	if not toast_label: return
	toast_label.text = text
	toast_label.add_theme_color_override("font_color", color)
	toast_label.visible = true
	toast_time = time
	toast_label.scale = Vector2(0.86, 0.86)
	create_tween().tween_property(toast_label, "scale", Vector2.ONE, 0.14)

func _tick_toast(delta: float) -> void:
	if not toast_label: return
	toast_time = maxf(0.0, toast_time - delta)
	toast_label.visible = toast_time > 0.0

func _tick_combat_feedback(delta: float) -> void:
	hit_confirm_time = maxf(0.0, hit_confirm_time - delta)
	combat_flow_time = maxf(0.0, combat_flow_time - delta)
	if combat_flow_time <= 0.0:
		combat_flow = 0
	if hit_confirm_time <= 0.0:
		hit_confirm_kill = false

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
		card.custom_minimum_size = Vector2(245, 330)
		var pic := TextureRect.new()
		pic.custom_minimum_size = Vector2(245, 205)
		pic.texture = role_art[i]
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		card.add_child(pic)
		var button := Button.new()
		button.custom_minimum_size = Vector2(245, 104)
		button.text = ROLE_NAMES[i] + "\nQ " + ROLE_SKILLS[i][0] + " / E " + ROLE_SKILLS[i][1] + "\nLMB " + PRIMARY_ATTACK_NAMES[i] + " / RMB " + SECONDARY_ATTACK_NAMES[i]
		button.add_theme_font_size_override("font_size", 15)
		button.add_theme_color_override("font_color", ROLE_COLORS[i])
		button.pressed.connect(_select_role.bind(i))
		card.add_child(button)
		row.add_child(card)

func _select_role(index: int, with_mouth_intro := true) -> void:
	var was_selected := role_selected
	_set_role(index)
	role_selected = true
	game_paused = false
	role_panel.visible = false
	FrontendUI.hide_all(front_ui)
	current_front_screen = ""
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if not was_selected:
		_story_beat("CASE 01: THE LAST GOODNIGHT  //  MOCHI. SHELTER CAT. SEVEN DAYS WITHOUT FOOD. SCAN: ONE TOY MOUSE.", 8.0, 0)
	if with_mouth_intro and not was_selected: mouth_intro.begin()

func _set_role(index: int) -> void:
	_cancel_phase11_holds()
	role_index = clampi(index, 0, 3)
	var role_parts: Dictionary = CharacterFactory.build_role(character_visual, role_index)
	body_mesh = role_parts["body"] as MeshInstance3D
	head_mesh = role_parts["head"] as MeshInstance3D
	character_visual.visible = not first_person
	if is_instance_valid(first_person_viewmodel): first_person_viewmodel.rebuild(role_index)
	if is_instance_valid(clinic_system): clinic_system.decorate_role()
	_update_hud()

func _update_hud() -> void:
	var skills = ROLE_SKILLS[role_index]
	var qtxt := "READY" if skill_q_cd <= 0.0 else "%.1f" % skill_q_cd
	var etxt := "READY" if skill_e_cd <= 0.0 else "%.1f" % skill_e_cd
	var ptxt := "READY" if primary_attack_cd <= 0.0 else "%.1f" % primary_attack_cd
	var stxt := "READY" if secondary_attack_cd <= 0.0 else "%.1f" % secondary_attack_cd
	if role_index == 0 and spark_mark_time > 0.0: qtxt = "RECALL"
	if role_index == 1 and primary_hold: ptxt = "CHARGE x%d" % kaka_charge_nails
	if role_index == 2 and primary_hold: ptxt = "GROW %d%%" % int(bubble_roll_charge * 100.0)
	if role_index == 2 and secondary_hold: stxt = "AIM %d%%" % int(bubble_jump_charge * 100.0)
	if role_index == 2 and is_instance_valid(bubble_payload): etxt = "EJECT"
	var payload_txt := " | PAYLOAD" if role_index == 2 and is_instance_valid(bubble_payload) else ""
	var flow_txt := " | FLOW x%d" % combat_flow if combat_flow_time > 0.0 and combat_flow > 1 else ""
	var item_txt := ""
	if acid_umbrella_time > 0.0: item_txt += " | UMB %.0fs" % acid_umbrella_time
	if plasma_soda_time > 0.0: item_txt += " | SODA %.0fs" % plasma_soda_time
	if catnip_time > 0.0: item_txt += " | CATNIP %.0fs" % catnip_time
	status_label.text = "%s | HP %d | CREDITS %d | KOs %d | SYNC %d BEST x%d%s%s\nLMB %s %s | RMB %s %s\nQ %s %s | E %s %s%s" % [ROLE_NAMES[role_index], int(hp), credits, defeats, synergies, combo_best, payload_txt, flow_txt, PRIMARY_ATTACK_NAMES[role_index], ptxt, SECONDARY_ATTACK_NAMES[role_index], stxt, skills[0], qtxt, skills[1], etxt, item_txt]
	view_label.text = "FIRST PERSON" if first_person else "THIRD PERSON"
func _process(delta: float) -> void:
	living_time += delta
	_tick_camera_trauma(delta)
	FrontendUI.animate(front_ui, living_time)
	_tick_toast(delta)
	_tick_story(delta)
	if not role_selected or game_paused or inventory_open:
		return
	if mission_phase == "escape":
		escape_finale.tick(delta)
		return
	terrain_world.tick(delta)
	if mouth_intro.active:
		mouth_intro.tick(delta)
		round_time += delta
		_update_gamepad_look(delta)
		_tick_zones(delta)
		_animate_role_model(delta)
		target_label.text = ""
		return
	if mission_phase in ["host_boss", "ending"]:
		host_boss.tick(delta)
		_tick_combat_feedback(delta)
		_tick_fun_items(delta)
		if mission_phase == "host_boss":
			round_time += delta
			_tick_zones(delta)
			_update_gamepad_look(delta)
			_update_target_ui()
			_animate_role_model(delta)
		return
	if mission_phase == "win":
		return
	_tick_combat_feedback(delta)
	_tick_fun_items(delta)
	ShopFactory.animate(shop_root, living_time)
	valve_cooldown = maxf(0.0, valve_cooldown - delta)
	swallow_next -= delta
	if swallow_next <= 0.0:
		_spawn_swallowed_prop()
		swallow_next = 18.0 + randf() * 8.0
	_update_acid_valve_visual()
	_update_gamepad_look(delta)
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
		if am: am.emission_energy_multiplier = 0.30 + sin(living_time * 2.6) * 0.07
	_update_living_events(delta)
	var map_danger: float = 1.0 if acid_tide_time > 0.0 or spasm_time > 0.0 or drink_time > 0.0 else 0.0
	MapFactory.animate(map_visual_root, living_time, map_danger)
	WorldExpansionFactory.animate(world_expansion_root, living_time)
	StomachAnatomyFactory.animate(stomach_anatomy_root, living_time, map_danger)
	OrganWorldFactory.animate(organ_world_root, organ_props, living_time, delta, map_danger)
	_update_mission(delta)
	_update_target_ui()
	_tick_zones(delta)
	_animate_role_model(delta)

func _tick_camera_trauma(delta: float) -> void:
	if not is_instance_valid(camera_pivot): return
	hit_shake = maxf(0.0, hit_shake - delta * 2.8)
	damage_shake = maxf(0.0, damage_shake - delta * 1.55)
	var trauma := clampf(hit_shake + damage_shake, 0.0, 1.0)
	if game_paused or inventory_open or not role_selected: trauma = 0.0
	var squared := trauma * trauma
	camera_pivot.position.x = sin(living_time * 67.0) * squared * 0.31
	camera_pivot.position.z = cos(living_time * 53.0) * squared * 0.18
	camera_pivot.rotation.z = sin(living_time * 71.0 + 0.7) * squared * 0.032
	if is_instance_valid(camera_1p): camera_1p.h_offset = cos(living_time * 61.0) * squared * 0.045
	if is_instance_valid(camera_3p): camera_3p.h_offset = cos(living_time * 61.0) * squared * 0.025

func _player_hurt_feedback(amount: float, origin := Vector3.ZERO, directional := true) -> void:
	var strength := clampf(amount / 24.0, 0.22, 0.82)
	damage_shake = maxf(damage_shake, strength)
	anim_hurt_time = maxf(anim_hurt_time, 0.24 + strength * 0.12)
	if is_instance_valid(impact_feedback): impact_feedback.report_hurt(origin, directional, amount)

func _part(name: String) -> Node3D:
	return character_visual.get_node_or_null(name) as Node3D if character_visual else null

func _set_limb(name: String, rot_x: float, rot_z: float) -> void:
	var part := _part(name)
	if part:
		part.rotation.x = rot_x
		part.rotation.z = rot_z

func _follow_limb_end(limb_name: String, follower_name: String, local_y: float) -> void:
	var limb := _part(limb_name)
	var follower := _part(follower_name)
	if limb and follower:
		follower.position = limb.transform * Vector3(0.0, local_y, 0.0)

func _animate_role_model(delta: float) -> void:
	if not character_visual: return
	anim_cast_time = maxf(0.0, anim_cast_time - delta)
	anim_hurt_time = maxf(0.0, anim_hurt_time - delta)
	anim_reassemble_time = maxf(0.0, anim_reassemble_time - delta)
	anim_land_time = maxf(0.0, anim_land_time - delta)
	var clay_tick: float = floorf(living_time * 12.0) / 12.0
	var move_speed: float = Vector2(player.velocity.x, player.velocity.z).length()
	var move_ratio: float = clampf(move_speed / 9.2, 0.0, 1.0)
	var step: float = sin(clay_tick * (8.5 + move_ratio * 3.0)) * move_ratio
	var idle: float = sin(clay_tick * 2.6)
	var grow: float = 1.24 if ferment_time > 0.0 else 1.0
	var model_scale: float = ROLE_VISUAL_SCALES[role_index]
	var sx: float = grow * model_scale
	var sy: float = grow * model_scale
	if role_index == 2:
		var bubble_growth: float = bubble_roll_charge if primary_hold else (bubble_roll_power if bubble_roll_time > 0.0 else 0.0)
		sx *= (1.0 + idle * 0.025) * (1.0 + bubble_growth * 0.62)
		sy *= (1.0 - idle * 0.035) * (1.0 + bubble_growth * 0.38)
		if secondary_hold:
			sx *= 1.0 + bubble_jump_charge * 0.35
			sy *= 1.0 - bubble_jump_charge * 0.45
	character_visual.rotation.x = -0.38 if kaka_rush_time > 0.0 else 0.0
	if anim_land_time > 0.0:
		var land_wave: float = sin(clampf(anim_land_time / 0.22, 0.0, 1.0) * PI)
		sx *= 1.0 + land_wave * 0.12
		sy *= 1.0 - land_wave * 0.22
	if ko_time > 0.0:
		sx *= 1.58
		sy *= 0.10
	elif anim_hurt_time > 0.0:
		sx *= 1.13
		sy *= 0.78
	if anim_reassemble_time > 0.0:
		var rebuild: float = clampf(1.0 - anim_reassemble_time / 0.9, 0.0, 1.0)
		sx *= lerpf(0.18, 1.0, rebuild)
		sy *= lerpf(0.08, 1.0, rebuild)
	character_visual.scale = Vector3(sx, sy, sx)
	character_visual.position.y = idle * 0.018 + absf(step) * 0.045
	character_visual.rotation.z = step * 0.035
	if ko_time > 0.0:
		character_visual.position.y = -0.50
		character_visual.rotation.z = sin(clay_tick * 4.0) * 0.04
	if dodge_time > 0.0:
		character_visual.rotation.z = (1.0 - dodge_time / 0.28) * TAU
	match role_index:
		0:
			_set_limb("SparkArmL", step * 0.72, -0.28)
			_set_limb("SparkArmR", -step * 0.72, 0.28)
			_set_limb("SparkLegL", -step * 0.62, 0.0)
			_set_limb("SparkLegR", step * 0.62, 0.0)
		1:
			_set_limb("KakaArmL", step * 0.58, -0.14)
			_set_limb("KakaArmR", -step * 0.58, 0.14)
			_set_limb("KakaLegL", -step * 0.48, 0.0)
			_set_limb("KakaLegR", step * 0.48, 0.0)
		3:
			_set_limb("ShroomArmL", step * 0.52, -0.22)
			_set_limb("ShroomArmR", -step * 0.52, 0.22)
	if not player.is_on_floor():
		for leg_name in ["SparkLegL","SparkLegR","KakaLegL","KakaLegR"]:
			var leg := _part(leg_name)
			if leg: leg.rotation.x = -0.58
	_apply_role_secondary_motion(clay_tick, idle)
	_apply_cast_pose()
	_apply_face_expression()
	_follow_limb_end("SparkArmL", "SparkGloveL", -0.62)
	_follow_limb_end("SparkArmR", "SparkGloveR", -0.62)
	_follow_limb_end("KakaArmL", "KakaFistL", -0.60)
	_follow_limb_end("KakaArmR", "KakaFistR", -0.60)
	_follow_limb_end("SparkProngL", "SparkPlugTipL", 0.56)
	_follow_limb_end("SparkProngR", "SparkPlugTipR", 0.56)
	CharacterArt.sync(character_visual, role_index)

func _apply_role_secondary_motion(clay_tick: float, idle: float) -> void:
	var head := _part(["SparkHead","KakaHead","BubbleHead","ShroomFace"][role_index])
	if head:
		head.rotation.y = idle * 0.035
		head.rotation.x = 0.0
	if role_index == 0:
		var pl := _part("SparkProngL")
		var pr := _part("SparkProngR")
		if pl:
			pl.rotation.z = sin(clay_tick * 5.2) * 0.065
			pl.scale = Vector3(0.10,0.52,0.10)
		if pr:
			pr.rotation.z = -sin(clay_tick * 5.2) * 0.065
			pr.scale = Vector3(0.10,0.52,0.10)
	elif role_index == 2:
		var core := _part("BubbleCore")
		if core: core.scale = Vector3(0.30,0.40,0.24) * (1.0 + idle * 0.06)
	elif role_index == 3:
		var cap := _part("ShroomCap")
		if cap:
			cap.rotation.z = sin(clay_tick * 3.6) * 0.055
			cap.rotation.y = idle * 0.025
			cap.scale = Vector3(1.42,0.48,1.30)
			var rim := _part("ShroomCapRim")
			if rim:
				rim.rotation.z = cap.rotation.z
				rim.rotation.y = cap.rotation.y

func _apply_cast_pose() -> void:
	if anim_cast_time <= 0.0: return
	var strength: float = sin(clampf(anim_cast_time / 0.42, 0.0, 1.0) * PI)
	match role_index:
		0:
			_set_limb("SparkArmL", -1.05 * strength, -0.28)
			_set_limb("SparkArmR", -1.05 * strength, 0.28)
		1:
			if anim_cast_slot == 0:
				_set_limb("KakaArmL", 0.0, -0.14 - strength * 1.0)
				_set_limb("KakaArmR", 0.0, 0.14 + strength * 1.0)
			else: _set_limb("KakaArmR", -1.45 * strength, 0.14)
		2:
			var pulse: float = 1.0 + strength * (0.16 if anim_cast_slot == 1 else 0.09)
			character_visual.scale.x *= pulse
			character_visual.scale.z *= pulse
			character_visual.scale.y *= 1.0 - strength * 0.10
		3:
			_set_limb("ShroomArmL", 0.0, -0.22 - strength * 0.65)
			_set_limb("ShroomArmR", 0.0, 0.22 + strength * 0.65)
			var cap := _part("ShroomCap")
			if cap:
				cap.scale = Vector3(1.42,0.48,1.30) * (1.0 + strength * 0.10)
				cap.rotation.y += strength * 0.16
				var rim := _part("ShroomCapRim")
				if rim: rim.scale = Vector3(0.96,0.16,0.88) * (1.0 + strength * 0.10)
	_apply_cast_pose_v2(strength)

func _apply_cast_pose_v2(strength: float) -> void:
	var head_names := ["SparkHead","KakaHead","BubbleHead","ShroomFace"]
	var head := _part(head_names[role_index])
	if head: head.rotation.x = -strength * (0.12 if anim_cast_slot == 0 else 0.20)
	match role_index:
		0:
			for n in ["SparkProngL","SparkProngR"]:
				var pr := _part(n); if pr: pr.scale.y = 0.52 * (1.0 + strength * 0.18)
		1:
			var wrench := _part("KakaWrenchHead"); if wrench: wrench.rotation.z += strength * 0.45
		2:
			var core := _part("BubbleCore"); if core: core.scale = Vector3(0.30,0.40,0.24) * (1.0 + strength * 0.30)
		3:
			for n in ["ShroomSporeL","ShroomSporeR"]:
				var sp := _part(n); if sp: sp.position.y += strength * 0.10

func _apply_face_expression() -> void:
	var cast_strength: float = 0.0
	if anim_cast_time > 0.0: cast_strength = sin(clampf(anim_cast_time / 0.42, 0.0, 1.0) * PI)
	var hurt: float = 1.0 if anim_hurt_time > 0.0 else 0.0
	var mouth_names := ["SparkMouth","KakaMouth","BubbleMouth","ShroomMouth"]
	var bases: Array[Vector3] = [Vector3(0.22,0.055,0.055),Vector3(0.34,0.07,0.04),Vector3(0.18,0.045,0.045),Vector3(0.16,0.04,0.04)]
	var mouth := _part(mouth_names[role_index])
	if mouth:
		mouth.scale = bases[role_index]
		mouth.scale.y *= 1.0 + cast_strength * 1.4 + hurt * 1.2
		mouth.scale.x *= 1.0 - hurt * 0.24
	if role_index == 0:
		var bl := _part("SparkBrowL"); var br := _part("SparkBrowR")
		if bl: bl.rotation.z = -0.14 - cast_strength * 0.16 + hurt * 0.24
		if br: br.rotation.z = 0.14 + cast_strength * 0.16 - hurt * 0.24
	elif role_index == 1:
		var bl := _part("KakaBrowL"); var br := _part("KakaBrowR")
		if bl: bl.rotation.z = -0.10 - cast_strength * 0.12 + hurt * 0.20
		if br: br.rotation.z = 0.10 + cast_strength * 0.12 - hurt * 0.20

func _update_gamepad_look(delta: float) -> void:
	if not role_selected or mission_phase == "win": return
	var pads := Input.get_connected_joypads()
	if pads.is_empty(): return
	var pad: int = pads[0]
	var rx := Input.get_joy_axis(pad, JOY_AXIS_RIGHT_X)
	var ry := Input.get_joy_axis(pad, JOY_AXIS_RIGHT_Y)
	if absf(rx) < 0.16: rx = 0.0
	if absf(ry) < 0.16: ry = 0.0
	yaw -= rx * 2.25 * delta
	pitch = clampf(pitch - ry * 1.85 * delta, -1.05, 0.65)
	player.rotation.y = yaw
	camera_pivot.rotation.x = pitch

func _physics_process(delta: float) -> void:
	if mission_phase == "escape" or (is_instance_valid(host_boss) and host_boss.state == "toy_intro"):
		player.velocity = Vector3.ZERO
		_update_hud()
		return
	if mouth_intro.active and mouth_intro.swallow_time >= 0.0:
		player.velocity = Vector3.ZERO
		_update_hud()
		return
	if not role_selected or game_paused or inventory_open:
		player.velocity = Vector3.ZERO
		_update_hud()
		return
	if mission_phase in ["win", "ending"]:
		player.velocity = Vector3.ZERO
		_update_hud()
		return
	if ko_time > 0.0:
		ko_time = maxf(0.0, ko_time - delta)
		player.velocity = Vector3.ZERO
		if ko_time <= 0.0:
			hp = 100.0
			if mission_phase == "host_boss" and is_instance_valid(host_boss):
				host_boss.retry()
			else:
				player.position = mouth_intro.safe if mouth_intro.active else terrain_world.last_safe
			anim_reassemble_time = 0.9
			_toast("CLAY BODY RE-KNEADED", Color("#ffd6ec"), 2.2)
		_update_hud()
		return
	var cooldown_rate: float = 1.55 if plasma_soda_time > 0.0 else 1.0
	cooldown_rate *= 1.0+0.12*role_upgrade_level()
	skill_q_cd = maxf(0.0, skill_q_cd - delta * cooldown_rate)
	skill_e_cd = maxf(0.0, skill_e_cd - delta * cooldown_rate)
	primary_attack_cd = maxf(0.0, primary_attack_cd - delta * cooldown_rate)
	secondary_attack_cd = maxf(0.0, secondary_attack_cd - delta * cooldown_rate)
	_tick_phase11(delta)
	dodge_time = maxf(0.0, dodge_time - delta)
	dodge_success_lock = maxf(0.0, dodge_success_lock - delta)
	var ix := 0.0
	var iz := 0.0
	if Input.is_key_pressed(KEY_D): ix += 1.0
	if Input.is_key_pressed(KEY_A): ix -= 1.0
	if Input.is_key_pressed(KEY_S): iz += 1.0
	if Input.is_key_pressed(KEY_W): iz -= 1.0
	var pads := Input.get_connected_joypads()
	var pad_sprint := false
	if not pads.is_empty():
		var pad: int = pads[0]
		var lx := Input.get_joy_axis(pad, JOY_AXIS_LEFT_X)
		var ly := Input.get_joy_axis(pad, JOY_AXIS_LEFT_Y)
		if absf(lx) > 0.18: ix += lx
		if absf(ly) > 0.18: iz += ly
		pad_sprint = Input.is_joy_button_pressed(pad, JOY_BUTTON_LEFT_STICK)
	var move_dir := Vector3(ix, 0, iz)
	if move_dir.length_squared() > 0.01:
		move_dir = Basis(Vector3.UP, yaw) * move_dir.normalized()
	var speed := 9.2 if Input.is_key_pressed(KEY_SHIFT) or pad_sprint else 5.8
	if _on_surf_lane(player.position): speed *= 1.65
	if ferment_time > 0.0: speed *= 1.18
	if plasma_soda_time > 0.0: speed *= 1.28
	if dodge_time > 0.0: speed = 14.5
	if kaka_rush_time > 0.0:
		speed = 18.5
		move_dir = _forward()
	elif bubble_roll_time > 0.0:
		speed = 10.5 + bubble_roll_power * 8.5
		if move_dir.length_squared() <= 0.01: move_dir = _forward()
	if is_instance_valid(clinic_system): speed *= clinic_system.movement_multiplier()
	player.velocity.x = move_toward(player.velocity.x, move_dir.x * speed, 30.0 * delta)
	player.velocity.z = move_toward(player.velocity.z, move_dir.z * speed, 30.0 * delta)
	if not player.is_on_floor(): player.velocity.y -= 22.0 * delta
	var jump_down := Input.is_key_pressed(KEY_SPACE)
	if not pads.is_empty(): jump_down = jump_down or Input.is_joy_button_pressed(pads[0], JOY_BUTTON_A)
	if jump_down and not jump_latch and player.is_on_floor(): player.velocity.y = 10.2 if plasma_soda_time > 0.0 else 8.2
	jump_latch = jump_down
	if spasm_time > 0.0: player.velocity.x += spasm_dir * 7.0 * delta
	if drink_time > 0.0 and _in_drink_wave(player.position): player.velocity.x += drink_dir * (21.0 if acid_umbrella_time > 0.0 else 15.0) * delta
	player.move_and_slide()
	if mission_phase == "host_boss":
		host_boss.keep_in_arena()
	else:
		terrain_world.keep_inside()
	var now_on_floor: bool = player.is_on_floor()
	_phase11_after_move(delta, now_on_floor)
	if now_on_floor and not was_on_floor and living_time > 0.25:
		anim_land_time = 0.22
		SkillVFX.spawn_landing(self, player.global_position, ROLE_COLORS[role_index])
	was_on_floor = now_on_floor
	invuln = maxf(0.0, invuln - delta)
	ferment_time = maxf(0.0, ferment_time - delta)
	if not mouth_intro.active: _tick_enemies(delta)
	_update_hud()
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_ESCAPE:
		_handle_escape()
		get_viewport().set_input_as_handled()
		return
	if not role_selected:
		if role_panel and role_panel.visible and event is InputEventKey and event.pressed and not event.echo:
			match event.physical_keycode:
				KEY_1: _select_role(0)
				KEY_2: _select_role(1)
				KEY_3: _select_role(2)
				KEY_4: _select_role(3)
		return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_TAB:
		if is_instance_valid(inventory_ui): inventory_ui.toggle()
		get_viewport().set_input_as_handled()
		return
	if inventory_open or game_paused or _cinematic_locked():
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * 0.0025 * mouse_sensitivity
		pitch = clampf(pitch - event.relative.y * 0.0022 * mouse_sensitivity, -1.05, 0.65)
		player.rotation.y = yaw
		camera_pivot.rotation.x = pitch
	elif event is InputEventMouseButton:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed: _primary_pressed()
			else: _primary_released()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed: _secondary_pressed()
			else: _secondary_released()
	elif event is InputEventJoypadButton and event.pressed:
		match event.button_index:
			JOY_BUTTON_B: _start_dodge()
			JOY_BUTTON_X: _cast_skill(0)
			JOY_BUTTON_Y: _cast_skill(1)
			JOY_BUTTON_RIGHT_SHOULDER: _toggle_view()
			JOY_BUTTON_DPAD_UP: _select_role(0)
			JOY_BUTTON_DPAD_RIGHT: _select_role(1)
			JOY_BUTTON_DPAD_DOWN: _select_role(2)
			JOY_BUTTON_DPAD_LEFT: _select_role(3)
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_V: _toggle_view()
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
	if dodge_time <= 0.0:
		dodge_time = 0.28
		invuln = maxf(invuln, 0.22)

func _toggle_view() -> void:
	first_person = not first_person
	camera_1p.current = first_person
	camera_3p.current = not first_person
	character_visual.visible = not first_person
	if is_instance_valid(first_person_viewmodel): first_person_viewmodel.refresh_visibility()
	_update_hud()
func _cast_skill(slot: int) -> void:
	if _cinematic_locked(): return
	if not role_selected or game_paused or mission_phase == "win": return
	if role_index == 0 and slot == 0:
		if spark_mark_time <= 0.0 and skill_q_cd > 0.0: return
		anim_cast_time = 0.42
		anim_cast_slot = slot
		_skill_spark(slot)
		_spawn_skill_visual(slot)
		return
	if role_index == 2 and slot == 1:
		if not is_instance_valid(bubble_payload) and skill_e_cd > 0.0: return
		anim_cast_time = 0.42
		anim_cast_slot = slot
		_skill_bubble(slot)
		_spawn_skill_visual(slot)
		return
	if slot == 0:
		if skill_q_cd > 0.0: return
		skill_q_cd = Q_COOLDOWNS[role_index]
	else:
		if skill_e_cd > 0.0: return
		skill_e_cd = E_COOLDOWNS[role_index]
	anim_cast_time = 0.42
	anim_cast_slot = slot
	match role_index:
		0: _skill_spark(slot)
		1: _skill_kaka(slot)
		2: _skill_bubble(slot)
		3: _skill_shroom(slot)
	_spawn_skill_visual(slot)


func _safe_skill_destination(point: Vector3) -> Vector3:
	if mission_phase == "host_boss":
		point.x = clampf(point.x,-10.6,10.6)
		point.z = clampf(point.z,-7.3,8.8)
		return point
	return terrain_world.constrain_point(point)

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
		elif _is_host_boss(e):
			target_label.text = "MOCHI / PANIC %d — RESCUE TARGET" % int(ceil(host_boss.panic))
		else:
			target_label.text = "%s  HP %d/%d%s%s" % [String(e.get_meta("kind")), int(e.get_meta("hp")), int(e.get_meta("max_hp")), "  STUN" if float(e.get_meta("stun")) > 0.0 else "", "  PINNED" if float(e.get_meta("pinned")) > 0.0 else ""]
	else:
		target_label.text = ""
	if hit_confirm_time > 0.0:
		crosshair.text = "X"
		crosshair.scale = Vector2.ONE * (1.28 if hit_confirm_kill else 1.12)
		crosshair.add_theme_color_override("font_color", Color("#ff7b8f") if hit_confirm_kill else ROLE_COLORS[role_index])
	else:
		crosshair.text = "+"
		crosshair.scale = Vector2.ONE
		crosshair.add_theme_color_override("font_color", Color("#75f6ff") if e else Color.WHITE)

func _damage_enemy(e: CharacterBody3D, amount: float, stun := 0.0, pin := 0.0, impulse := Vector3.ZERO, show_hit_vfx := true) -> void:
	if not is_instance_valid(e) or e.get_meta("dead", false): return
	if _is_host_boss(e):
		host_boss.apply_hit(amount, maxf(stun, pin), role_index)
		if show_hit_vfx:
			SkillVFX.spawn_hit(self, e.global_position + Vector3.UP, ROLE_COLORS[role_index], role_index)
		return
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
			credits += 4
			combo_best = maxi(combo_best, chain)
			_toast("SYNC x%d  %s + %s  +4C" % [chain, ROLE_NAMES[last_role], ROLE_NAMES[role_index]], Color("#ffdd65"), 2.0)
			_spawn_combo_ring(e.global_position + Vector3.UP * 0.8, chain)
			SkillVFX.spawn_sync_pair(self, e.global_position + Vector3.UP * 0.12, chain, last_role, role_index, ROLE_COLORS[last_role], ROLE_COLORS[role_index])
		elif combo_t <= 0.0:
			chain = 1
		e.set_meta("combo_role", role_index)
		e.set_meta("combo_t", 2.6)
		e.set_meta("combo_count", maxi(chain, 1))
	var next_hp := maxf(0.0, float(e.get_meta("hp")) - amount)
	if amount > 0.0:
		impact_feedback.report_hit(minf(amount,float(e.get_meta("hp"))),next_hp<=0.0)
		e.set_meta("impact_freeze",0.025 if role_index==0 else 0.05)
		combat_flow = mini(99, combat_flow + 1) if combat_flow_time > 0.0 else 1
		combat_flow_time = 1.35
		hit_confirm_time = 0.15 if next_hp > 0.0 else 0.24
		hit_confirm_damage = int(amount)
		hit_confirm_kill = next_hp <= 0.0
	e.set_meta("hit_flash", 0.14)
	if amount > 0.0:
		hit_shake = maxf(hit_shake,[0.035,0.11,0.13,0.065][role_index])
	e.set_meta("hp", next_hp)
	e.set_meta("stun", maxf(float(e.get_meta("stun")), stun))
	e.set_meta("pinned", maxf(float(e.get_meta("pinned")), pin))
	e.velocity += impulse
	if show_hit_vfx:
		SkillVFX.spawn_hit(self, e.global_position + Vector3.UP * 0.7, ROLE_COLORS[role_index], role_index)
	_spawn_damage_number(e.global_position + Vector3.UP * 1.45, int(amount))
	if next_hp <= 0.0:
		e.set_meta("dead", true)
		e.collision_layer = 0
		e.collision_mask = 0
		defeats += 1
		credits += 6
		var death_kind := String(e.get_meta("kind"))
		EnemyFactory.spawn_death(self, death_kind, e.global_position)
		var squash := Vector3(1.5,0.08,1.5)
		if death_kind == "PLATELET": squash = Vector3(1.7,0.12,1.1)
		elif death_kind == "PARASITE": squash = Vector3(0.72,1.65,0.72)
		var tw := create_tween()
		tw.tween_property(e, "scale", squash, 0.16)
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
	if amount <= 0: return
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
		if mission_phase in ["host_boss", "ending", "win"]:
			continue
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
		var old_attack: float = float(e.get_meta("attack_windup", 0.0))
		var attack_windup: float = maxf(0.0, old_attack - delta)
		var attack_cd: float = maxf(0.0, float(e.get_meta("attack_cd", 0.0)) - delta)
		var goo_slow := maxf(0.0, float(e.get_meta("goo_slow", 0.0)) - delta)
		var controlled := maxf(0.0, float(e.get_meta("controlled", 0.0)) - delta)
		var control_attack_cd := maxf(0.0, float(e.get_meta("control_attack_cd", 0.0)) - delta)
		if controlled > 0.0:
			attack_windup = 0.0
			old_attack = 0.0
		e.set_meta("stun", stun)
		e.set_meta("pinned", pinned)
		e.set_meta("big", big)
		e.set_meta("goo_slow", goo_slow)
		e.set_meta("controlled", controlled)
		e.set_meta("control_attack_cd", control_attack_cd)
		var flash := maxf(0.0, float(e.get_meta("hit_flash")) - delta)
		e.set_meta("hit_flash", flash)
		var flash_visual := e.get_meta("visual") as Node3D
		EnemyFactory.set_hit_flash(flash_visual, flash > 0.0)
		var mi := e.get_meta("mesh") as MeshInstance3D
		var emat := mi.material_override as StandardMaterial3D if mi else null
		if emat:
			emat.emission_enabled = flash > 0.0
			emat.emission = Color.WHITE
			emat.emission_energy_multiplier = 2.2 if flash > 0.0 else 0.0
		var hpl := e.get_meta("hp_label") as Label3D
		if hpl:
			var chain := int(e.get_meta("combo_count", 0))
			var ctag := "  SYNC x%d" % chain if chain > 1 and float(e.get_meta("combo_t", 0.0)) > 0.0 else ""
			var attack_tag := "  WINDUP!" if attack_windup > 0.0 else ""
			var control_tag := ("  PUPPET OVERDRIVE!" if big > 0.0 else "  PUPPET!") if controlled > 0.0 else ("  GOO-SLOWED" if goo_slow > 0.0 else "")
			var spore_count := int(e.get_meta("spore_stacks", 0))
			var spore_tag := "  SPORE x%d" % spore_count if spore_count > 0 else ""
			var mark_tag := "  CONDUCTOR" if e == spark_mark_target else ""
			var bone_count := int(e.get_meta("bone_pins", 0))
			var bone_tag := "  BONE x%d" % bone_count if bone_count > 0 else ""
			var kind_name := String(e.get_meta("display_name", e.get_meta("kind")))
			var wild_tag := "  WILD" if bool(e.get_meta("wild_spawn", false)) else ""
			hpl.text = "%s%s%s%s%s%s%s%s\n%d/%d" % [kind_name, wild_tag, ctag, attack_tag, control_tag, spore_tag, mark_tag, bone_tag, int(e.get_meta("hp")), int(e.get_meta("max_hp"))]
			hpl.modulate = Color("#b989ff") if controlled > 0.0 else ((Color(1.0,0.82,0.35) if kind_name == "PLATELET" else (Color(0.86,0.55,1.0) if kind_name == "HAIRBALL" else Color(0.65,1.0,0.48))) if attack_windup > 0.0 else Color.WHITE)
		e.scale = Vector3.ONE * (1.45 if big > 0.0 else 1.0)
		var slow := 0.35 if goo_slow > 0.0 else (0.45 if _on_fungus(e.global_position) else 1.0)
		var control_target: CharacterBody3D = _control_target_for(e) if controlled > 0.0 else null
		if stun <= 0.0 and pinned <= 0.0 and attack_windup <= 0.0:
			var has_chase_target := true
			var chase_target := player.global_position
			var is_wild := bool(e.get_meta("wild_spawn", false))
			var home: Vector3 = e.get_meta("home", e.global_position)
			var aggro_radius := float(e.get_meta("aggro_radius", 7.5))
			var engaged := e.global_position.distance_to(player.global_position) <= aggro_radius or float(e.get_meta("combo_t", 0.0)) > 0.0
			if is_wild and not engaged:
				chase_target = home
				has_chase_target = e.global_position.distance_to(home) > 0.7
			if controlled > 0.0:
				has_chase_target = is_instance_valid(control_target)
				if has_chase_target: chase_target = control_target.global_position
			elif bubble_decoy_time > 0.0 and is_instance_valid(bubble_decoy):
				chase_target = bubble_decoy.global_position
			elif catnip_time > 0.0 and is_instance_valid(catnip_beacon):
				chase_target = catnip_beacon.global_position
			var off := chase_target - e.global_position
			off.y = 0.0
			if has_chase_target and off.length() > 0.7:
				var v := off.normalized() * float(e.get_meta("speed")) * slow
				e.velocity.x = move_toward(e.velocity.x, v.x, 12.0 * delta)
				e.velocity.z = move_toward(e.velocity.z, v.z, 12.0 * delta)
			else:
				e.velocity.x = move_toward(e.velocity.x, 0.0, 16.0 * delta)
				e.velocity.z = move_toward(e.velocity.z, 0.0, 16.0 * delta)
		else:
			e.velocity.x = move_toward(e.velocity.x, 0.0, 16.0 * delta)
			e.velocity.z = move_toward(e.velocity.z, 0.0, 16.0 * delta)
		e.velocity.y -= 18.0 * delta
		e.move_and_slide()
		if controlled > 0.0 and is_instance_valid(control_target) and e.global_position.distance_to(control_target.global_position) < 1.55 and control_attack_cd <= 0.0:
			var overdrive := big > 0.0
			control_attack_cd = 0.68 if overdrive else 0.85
			SkillVFX.spawn_basic_attack(self, 3, overdrive, e.global_position + Vector3.UP * 0.7, control_target.global_position + Vector3.UP * 0.7)
			_damage_enemy(control_target, 17.0 if overdrive else 11.0, 0.24 if overdrive else 0.12, 0.0, (control_target.global_position - e.global_position).normalized() * (5.2 if overdrive else 3.5), false)
			if overdrive:
				SkillVFX.spawn_spore_bloom(self, control_target.global_position, 1.3)
			e.set_meta("control_attack_cd", control_attack_cd)
		var enemy_visual := e.get_meta("visual") as Node3D
		var dist_to_player: float = e.global_position.distance_to(player.global_position)
		if controlled <= 0.0 and old_attack > 0.0 and attack_windup <= 0.0:
			if dist_to_player < 1.45 and invuln <= 0.0:
				var received_damage := float(e.get_meta("contact_damage"))
				hp = maxf(0.0, hp - received_damage)
				_player_hurt_feedback(received_damage, e.global_position, true)
				invuln = 0.85
				player.velocity += (player.global_position - e.global_position).normalized() * 5.8
				var biome_trait := String(e.get_meta("biome_trait", ""))
				match biome_trait:
					"tangle":
						player.velocity.x *= 0.24
						player.velocity.z *= 0.24
						_toast("FUR TANGLED: movement snagged", Color("#d6a8e2"), 1.2)
					"gnaw":
						hp = maxf(0.0, hp - 2.0)
						_toast("BILE NIP: armor softened", Color("#d8dc6b"), 1.2)
					"bounce":
						player.velocity.y = 9.5
						_toast("AIR SAC POP: launched!", Color("#a8eaff"), 1.2)
					"shock":
						skill_q_cd += 0.65
						skill_e_cd += 0.65
						_toast("STATIC BITE: cooldown scrambled", Color("#8cbaff"), 1.2)
				EnemyFactory.spawn_attack_hit(self, String(e.get_meta("kind")), e.global_position + Vector3.UP * 0.45)
			elif dist_to_player < 1.45 and dodge_time > 0.0 and dodge_success_lock <= 0.0:
				dodge_success_lock = 0.38
				hit_shake = maxf(hit_shake, 0.08)
				SkillVFX.spawn_dodge_success(self, player.global_position, ROLE_COLORS[role_index])
				_toast("PERFECT DODGE", ROLE_COLORS[role_index], 1.0)
		elif controlled <= 0.0 and old_attack <= 0.0 and attack_cd <= 0.0 and dist_to_player < 1.65 and stun <= 0.0 and pinned <= 0.0:
			attack_windup = 0.36
			attack_cd = 1.15
			EnemyFactory.spawn_attack_telegraph(self, String(e.get_meta("kind")), e.global_position)
			if hpl:
				var wind_kind: String = String(e.get_meta("kind"))
				hpl.text = "%s  WINDUP!\n%d/%d" % [wind_kind, int(e.get_meta("hp")), int(e.get_meta("max_hp"))]
				hpl.modulate = Color(1.0,0.82,0.35) if wind_kind == "PLATELET" else (Color(0.86,0.55,1.0) if wind_kind == "HAIRBALL" else Color(0.65,1.0,0.48))
		e.set_meta("attack_windup", attack_windup)
		e.set_meta("attack_cd", attack_cd)
		var attack_pose: float = 1.0 - clampf(attack_windup / 0.36, 0.0, 1.0) if old_attack > 0.0 else 0.0
		var impact_freeze := maxf(0.0,float(e.get_meta("impact_freeze",0.0))-delta)
		e.set_meta("impact_freeze",impact_freeze)
		if impact_freeze <= 0.0:
			EnemyFactory.animate(enemy_visual, String(e.get_meta("kind")), living_time, e.velocity, stun > 0.0, pinned > 0.0, attack_pose)
		EnemyFactory.apply_control_pose(enemy_visual, stun, pinned, slow)
	if hp <= 0.0 and ko_time <= 0.0:
		ko_time = 0.85
		anim_hurt_time = 0.30
		player.velocity = Vector3.ZERO
		SkillVFX.spawn_ko_splat(self, player.global_position, ROLE_COLORS[role_index])
		_toast("CLAY BODY DOWN!", Color("#ff9fca"), 1.0)

func _spawn_swallowed_prop() -> void:
	var body := RigidBody3D.new()
	body.position = world_point(Vector3(randf_range(-19.0, 19.0), 7.5, randf_range(-10.5, 6.0)))
	body.mass = 1.4
	body.linear_velocity = Vector3(randf_range(-1.8, 1.8), -2.5, randf_range(0.2, 1.5))
	body.angular_velocity = Vector3(randf_range(-2.0, 2.0), randf_range(-2.0, 2.0), randf_range(-2.0, 2.0))
	var prop_kind: int = randi() % 4
	var prop_sizes: Array[Vector3] = [Vector3(1.45,0.72,0.82),Vector3(1.20,0.68,1.20),Vector3(1.15,0.72,0.95),Vector3(1.35,0.62,0.72)]
	var prop_size: Vector3 = prop_sizes[prop_kind]
	MapFactory.build_swallowed_prop(body, prop_kind)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = prop_size
	col.shape = shape
	body.add_child(col)
	add_child(body)
	swallowed_props.append(body)
	if swallowed_props.size() > 6:
		var old: RigidBody3D = swallowed_props.pop_front()
		if is_instance_valid(old): old.queue_free()
	_toast("SWALLOWED OBJECT INBOUND", Color("#7edcff"), 2.6)

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
	_toast("ACID PRESSURE RELEASED", Color("#7ff0c8"), 2.4)
	if acid_mesh:
		create_tween().tween_property(acid_mesh, "position:y", -0.12, 0.45)

func _in_drink_wave(pos: Vector3) -> bool:
	if not is_instance_valid(drink_wave): return false
	# Visual slab plus one capsule radius, and only the lowland water surface.
	return absf(pos.x-drink_wave.position.x) < 0.6*world_scale+0.7 and absf(pos.z) < 12.5*world_scale and pos.y < drink_wave.position.y+0.9

func _update_living_events(delta: float) -> void:
	acid_next -= delta
	spasm_next -= delta
	drink_next -= delta
	acid_tide_time = maxf(0.0, acid_tide_time - delta)
	spasm_time = maxf(0.0, spasm_time - delta)
	drink_time = maxf(0.0, drink_time - delta)
	if acid_next <= 0.0:
		acid_tide_time = 6.0
		acid_next = 18.0+3.0*clinic_recovery_count()
		SkillVFX.spawn_body_event(self, "acid")
	if spasm_next <= 0.0:
		spasm_time = 3.2
		spasm_dir *= -1.0
		spasm_next = 15.0+2.0*clinic_recovery_count()
		SkillVFX.spawn_body_event(self, "spasm", spasm_dir)
	if drink_next <= 0.0:
		drink_time = 4.5
		drink_dir *= -1.0
		drink_next = 22.0
		SkillVFX.spawn_body_event(self, "drink", drink_dir)
	var tide := sin((1.0 - acid_tide_time / 6.0) * PI) if acid_tide_time > 0.0 else 0.0
	if acid_mesh:
		acid_mesh.position.y = 0.03 + sin(living_time * 1.9) * 0.035 + tide * 0.38
	if drink_wave:
		drink_wave.visible = drink_time > 0.0
		if drink_time > 0.0:
			var progress := 1.0 - drink_time / 4.5
			drink_wave.position.x = world_scale * (lerpf(-24.0, 24.0, progress) if drink_dir > 0.0 else lerpf(24.0, -24.0, progress))
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
	var map_pos := authored_point(player.position)
	var in_acid := absf(map_pos.x) < 6.2 and map_pos.z > 2.0 and map_pos.z < 7.6
	var on_high_ground := player.position.y > 0.82
	if in_acid and tide > 0.22 and not on_high_ground:
		hp = maxf(0.0, hp - 11.0 * delta * (1.0-0.12*clinic_recovery_count()) * (0.18 if acid_umbrella_time > 0.0 else 1.0))
		anim_hurt_time = maxf(anim_hurt_time, 0.08)
	camera_pivot.rotation.z = sin(living_time * 16.0) * 0.055 if spasm_time > 0.0 else lerpf(camera_pivot.rotation.z, 0.0, minf(1.0, delta * 6.0))

func _point_in_lane(pos: Vector3, lane: Node3D) -> bool:
	var local := lane.to_local(pos)
	return absf(local.x) < 0.9 and absf(local.z) < 3.7

func _on_surf_lane(pos: Vector3) -> bool:
	for lane in surf_lanes:
		if is_instance_valid(lane) and _point_in_lane(pos, lane): return true
	return false

func _prune_freed_nodes(items: Array) -> void:
	for index in range(items.size()-1,-1,-1):
		if not is_instance_valid(items[index]): items.remove_at(index)

func _near_bone(pos: Vector3, radius: float) -> bool:
	_prune_freed_nodes(bone_structures)
	for bone in bone_structures.duplicate():
		if not is_instance_valid(bone): continue
		if bone.global_position.distance_to(pos) < radius: return true
	return false

func _on_fungus(pos: Vector3) -> bool:
	for patch in fungus_patches:
		if is_instance_valid(patch) and Vector2(pos.x - patch.position.x, pos.z - patch.position.z).length() < float(patch.get_meta("radius")): return true
	return false

func _tick_zones(delta: float) -> void:
	_prune_freed_nodes(surf_lanes)
	_prune_freed_nodes(fungus_patches)
	for lane in surf_lanes.duplicate():
		if not is_instance_valid(lane): continue
		var ttl := float(lane.get_meta("ttl")) - delta
		lane.set_meta("ttl", ttl)
		SkillVFX.animate_zone(lane, living_time, bool(lane.get_meta("charged", false)))
		if ttl <= 0.0:
			surf_lanes.erase(lane)
			lane.queue_free()
	for patch in fungus_patches.duplicate():
		if not is_instance_valid(patch): continue
		var ttl := float(patch.get_meta("ttl")) - delta
		patch.set_meta("ttl", ttl)
		SkillVFX.animate_zone(patch, living_time, bool(patch.get_meta("charged", false)))
		if Vector2(player.position.x - patch.position.x, player.position.z - patch.position.z).length() < float(patch.get_meta("radius")):
			hp = minf(100.0, hp + (5.0+2.0*role_upgrade_level(3)) * delta)
		if ttl <= 0.0:
			fungus_patches.erase(patch)
			patch.queue_free()

func _skill_spark(slot: int) -> void:
	if slot == 0:
		_spark_conductive_mark_or_teleport()
	else:
		_spark_neural_storm()

func _skill_kaka(slot: int) -> void:
	if slot == 0:
		_spawn_bone_bridge()
	else:
		_start_kaka_charge()

func _skill_bubble(slot: int) -> void:
	if slot == 0:
		_spawn_bubble_decoy()
	else:
		_bubble_regurgitate()

func _skill_shroom(slot: int) -> void:
	if slot == 0:
		_spawn_fungus_patch()
	else:
		_shroom_ferment_burst()

func _spawn_bone_bridge() -> void:
	var boosted := _on_fungus(player.position)
	var body := StaticBody3D.new()
	body.position = player.position + _forward() * 3.0 + Vector3(0, 0.25, 0)
	body.rotation.y = yaw
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.35, 0.68, 7.2) if boosted else Vector3(1.05, 0.5, 6.0)
	mi.mesh = box
	mi.material_override = _mat(Color(0.95,0.91,0.83,0.16), true)
	body.add_child(mi)
	SkillVFX.decorate_bone(body, boosted)
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
		_toast("SYNC: FUNGUS-REINFORCED BONE", Color("#c8ff8a"), 2.0)

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
	var mat := _mat(Color(1.0, 0.25, 0.48, 0.24), true)
	mat.emission_enabled = true
	mat.emission = Color("#c32255")
	mat.emission_energy_multiplier = 1.5
	if bone_sync: mat.emission_energy_multiplier = 2.2
	mi.material_override = mat
	root.add_child(mi)
	SkillVFX.decorate_lane(root, bone_sync)
	add_child(root)
	surf_lanes.append(root)
	if bone_sync:
		synergies += 1
		_toast("SYNC: BONE-GUIDED PLASMA RAIL", Color("#ff83a8"), 2.0)

func _spawn_fungus_patch() -> void:
	var blood_sync := _on_surf_lane(player.position)
	var bone_sync := _near_bone(player.position, 5.0)
	var networked := blood_sync or bone_sync
	var root := Node3D.new()
	root.position = player.position + Vector3(0, 0.06, 0)
	root.set_meta("ttl", 14.0 if networked else 11.0)
	root.set_meta("radius", 4.5 if networked else 3.6)
	root.set_meta("blood_sync", blood_sync)
	root.set_meta("bone_sync", bone_sync)
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(9.0, 0.06, 9.0) if networked else Vector3(7.2, 0.06, 7.2)
	mi.mesh = box
	var mat := _mat(Color(0.45, 0.92, 0.28, 0.22), true)
	mat.emission_enabled = true
	mat.emission = Color("#2d8a2a")
	mat.emission_energy_multiplier = 2.2 if networked else 1.5
	mi.material_override = mat
	root.add_child(mi)
	SkillVFX.decorate_fungus(root, blood_sync)
	add_child(root)
	root.scale = Vector3(0.08, 1, 0.08)
	create_tween().tween_property(root, "scale", Vector3.ONE, 0.3 if blood_sync else 0.36)
	fungus_patches.append(root)
	if blood_sync:
		synergies += 1
		_toast("SYNC: PLASMA-CARRIED FUNGUS", Color("#95ff7f"), 2.0)

func _spawn_skill_visual(slot: int) -> void:
	var target_pos: Vector3 = player.global_position + _forward() * 8.0 + Vector3.UP * 0.8
	var target_enemy := _get_target(14.0, 0.05)
	if is_instance_valid(target_enemy): target_pos = target_enemy.global_position + Vector3.UP * 0.7
	SkillVFX.spawn_cast(self, role_index, slot, player.global_position + Vector3.UP * 0.85, _forward(), target_pos)
	var active_camera := camera_1p if first_person else camera_3p
	var base_fov := minf(camera_fov + 4.0, 90.0) if first_person else camera_fov
	active_camera.fov = base_fov + (5.5 if slot == 1 else 3.5)
	create_tween().tween_property(active_camera, "fov", base_fov, 0.24)

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
	preload("res://scripts/art19_creatures.gd").attach(entrance,"CAPSULE")
	entrance.get_node("Art19Model").position.y = 0.40
	cap_label.position.y = 3.35

	var clue_positions = [Vector3(-18.0, 0.55, 8.8), Vector3(0.0, 0.50, -11.2), Vector3(18.0, 0.55, -8.7)]
	var clue_names = ["第一关 · 贲门毛球样本", "第二关 · 幽门痉挛信号", "第三关 · 十二指肠异物痕迹"]
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
	_make_mucus_route(Vector3(-15.2, 0.06, 0.8), -1.35)
	_make_mucus_route(Vector3(15.0, 0.06, -0.4), 1.32)
	_make_mucus_route(Vector3(0.0, 0.06, -8.4), 0.0)
	var layer := CanvasLayer.new()
	add_child(layer)
	mission_label = Label.new()
	mission_label.position = Vector2(290, 122)
	mission_label.size = Vector2(700, 42)
	mission_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mission_label.add_theme_font_size_override("font_size", 21)
	layer.add_child(mission_label)
	story_label = Label.new()
	story_label.position = Vector2(310, 160)
	story_label.size = Vector2(660, 42)
	story_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_label.add_theme_font_size_override("font_size", 16)
	story_label.add_theme_color_override("font_color", Color("#9feadf"))
	story_label.visible = false
	layer.add_child(story_label)
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
	shade.position = Vector2(300, 130)
	shade.size = Vector2(680, 485)
	win_panel.add_child(shade)
	var title := Label.new()
	title.text = "TREATMENT COMPLETE"
	title.position = Vector2(340, 165)
	title.size = Vector2(600, 62)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	win_panel.add_child(title)
	win_label = Label.new()
	win_label.position = Vector2(340, 235)
	win_label.size = Vector2(600, 250)
	win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_label.add_theme_font_size_override("font_size", 17)
	win_panel.add_child(win_label)
	var again := Button.new()
	again.text = "RUN AGAIN  [R]"
	again.position = Vector2(515, 520)
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

func _story_beat(text: String, duration := 5.5, chapter := -1) -> void:
	if chapter >= 0:
		story_chapter = chapter
	if not story_label:
		return
	story_label.text = text
	story_label.visible = true
	story_label.modulate.a = 1.0
	story_time = duration

func _tick_story(delta: float) -> void:
	if game_paused: return
	story_time = maxf(0.0, story_time - delta)
	if not story_label:
		return
	story_label.visible = story_time > 0.0
	story_label.modulate.a = clampf(story_time, 0.0, 1.0)

func _clue_count() -> int:
	var count := 0
	for done in clue_done:
		if done: count += 1
	return count

func _refresh_mission_ui() -> void:
	if not mission_label: return
	match mission_phase:
		"diagnose": mission_label.text = "WHY DID MOCHI SWALLOW IT?  %d/3 clues" % _clue_count()
		"chase":
			var md := player.global_position.distance_to(mouse_target.global_position) if is_instance_valid(mouse_target) else 0.0
			mission_label.text = "SAVE THE RECORDING  - memory mouse  %.1fm" % md
		"return":
			var rd := player.global_position.distance_to(entrance.global_position) if entrance else 0.0
			mission_label.text = "带电子老鼠返回撤离胶囊 · 肠道排出路线  %.1fm" % rd
		"win": mission_label.text = "TREATMENT COMPLETE"

func _update_mission(delta: float) -> void:

	if not role_selected: return
	if mission_phase in ["host_boss", "ending", "win", "escape"]:
		interact_label.text = ""
		capture_bar.visible = false
		interact_progress = 0.0
		return
	if mission_phase != "win": round_time += delta
	if mission_phase == "return" and mouse_caught and is_instance_valid(mouse_target):
		mouse_target.visible = true
		mouse_target.global_position = player.global_position - _forward() * 0.9 + Vector3.UP * 0.9
		mouse_target.velocity = Vector3.ZERO
	var holding := interact_down or Input.is_key_pressed(KEY_F)
	var pads := Input.get_connected_joypads()
	if not pads.is_empty(): holding = holding or Input.is_joy_button_pressed(pads[0], JOY_BUTTON_LEFT_SHOULDER)
	var prompt := ""
	var action := ""
	var duration := 0.0
	var action_index := -1
	if mission_phase == "diagnose":
		for i in range(clue_nodes.size()):
			if clue_done[i]: continue
			if is_instance_valid(anatomy_route) and not anatomy_route.can_use_clue(i): continue
			if player.global_position.distance_to(clue_nodes[i].global_position) < 1.9:
				prompt = "HOLD F  DIAGNOSE"
				action = "clue"
				action_index = i
				duration = 0.45
				break
	elif mission_phase == "chase" and is_instance_valid(mouse_target):
		var md := player.global_position.distance_to(mouse_target.global_position)
		if md < 2.0:
			if _mouse_controlled():
				prompt = "HOLD F  CAPTURE"
				action = "capture"
				duration = 0.72
			else:
				prompt = "CONTROL TARGET WITH Q/E FIRST"
	elif mission_phase == "return" and entrance:
		if player.global_position.distance_to(entrance.global_position) < 2.35:
			prompt = "长按 F：启动蠕动撤离 · 从排泄出口离开"
			action = "deliver"
			duration = 0.55

	# Story capture/diagnosis/evacuation wins when a mouse wanders into a care area.
	if is_instance_valid(clinic_system):
		if action == "" and clinic_system.handle_interaction(delta,holding):
			interact_requires_release = holding
			_refresh_mission_ui()
			return
		elif action != "":
			clinic_system.last_held = holding
			clinic_system.context_site = -1
	if action == "" and acid_valve and player.global_position.distance_to(acid_valve.global_position) < 2.0:
		if valve_cooldown <= 0.0:
			prompt = "HOLD F  RELEASE ACID PRESSURE"
			action = "valve"
			duration = 0.55
		else:
			prompt = "ACID VALVE COOLING  %.0fs" % valve_cooldown
	if action == "":
		var organ_index := _nearest_organ_prop()
		if organ_index >= 0:
			var organ_prop := organ_props[organ_index]
			var prop_cooldown := float(organ_prop.get_meta("cooldown", 0.0))
			if prop_cooldown > 0.0:
				prompt = "ORGAN PROP COOLING  %.0fs" % prop_cooldown
			else:
				prompt = String(organ_prop.get_meta("prompt", "HOLD F  USE ORGAN PROP")).replace("F  ", "HOLD F  ")
				action = "organ_prop"
				action_index = organ_index
				duration = 0.45
	if action == "":
		var shop_index: int = _nearest_shop_item()
		if shop_index >= 0:
			prompt = "长按 F 购买：%s  %d C · %s" % [ShopFactory.ITEM_DISPLAY_NAMES[shop_index],ShopFactory.ITEM_COSTS[shop_index],ShopFactory.ITEM_DESCRIPTIONS[shop_index]]
			action = "shop"
			action_index = shop_index
			duration = 0.35
	var action_key := "%s:%d" % [action, action_index]
	if action_key != interact_action_key:
		interact_action_key = action_key
		interact_progress = 0.0
	if not holding:
		interact_requires_release = false
	if interact_requires_release and action != "":
		interact_label.text = "RELEASE F TO INTERACT AGAIN"
		interact_label.add_theme_color_override("font_color", Color("#ffe36b"))
		crosshair.scale = Vector2.ONE
		capture_bar.visible = false
		interact_progress = 0.0
		_refresh_mission_ui()
		return
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
				"deliver": _begin_escape_finale()
				"valve": _use_acid_valve()
				"organ_prop": _use_organ_prop(action_index)
				"shop": _buy_item(action_index)
			interact_requires_release = true
	else:
		crosshair.scale = Vector2.ONE
		interact_label.add_theme_color_override("font_color", Color.WHITE)
		interact_progress = maxf(0.0, interact_progress - delta * 3.0)
		capture_bar.visible = interact_progress > 0.02 and action != ""
		if duration > 0.0: capture_bar.value = clampf(interact_progress / duration, 0.0, 1.0)
	_refresh_mission_ui()

func _nearest_organ_prop() -> int:
	if not is_instance_valid(player):
		return -1
	var best_index := -1
	var best_distance := 2.35
	for i in range(organ_props.size()):
		var prop := organ_props[i]
		if not is_instance_valid(prop):
			continue
		var distance := player.global_position.distance_to(prop.global_position)
		if distance < best_distance:
			best_distance = distance
			best_index = i
	return best_index

func _use_organ_prop(index: int) -> void:
	if index < 0 or index >= organ_props.size():
		return
	var prop := organ_props[index]
	if not is_instance_valid(prop) or float(prop.get_meta("cooldown", 0.0)) > 0.0:
		return
	var prop_type := String(prop.get_meta("prop_type", ""))
	var used_count := int(prop.get_meta("used_count", 0))
	prop.set_meta("used_count", used_count + 1)
	prop.set_meta("cooldown", 11.0)
	organ_prop_uses += 1
	if used_count == 0:
		credits += 6
	match prop_type:
		"groomer":
			_calm_biome_enemies("HAIRBALL FOREST", prop.global_position, 6.0, 0.0)
			_toast("GROOMING TURBINE: tangles combed  +6C" if used_count == 0 else "GROOMING TURBINE: tangles combed", Color("#ffe07d"), 2.4)
		"gut_drum":
			_calm_biome_enemies("INTESTINAL MAZE", prop.global_position, 2.8, 12.0)
			_toast("PERISTALSIS DRUM: maze contraction  +6C" if used_count == 0 else "PERISTALSIS DRUM: maze contraction", Color("#ff9ac4"), 2.4)
		"bellows":
			player.velocity.y = 14.5
			plasma_soda_time = maxf(plasma_soda_time, 7.0)
			invuln = maxf(invuln, 0.65)
			_toast("ALVEOLI BELLOWS: balloon launch  +6C" if used_count == 0 else "ALVEOLI BELLOWS: balloon launch", Color("#a5ecff"), 2.4)
		"relay_to_forest":
			player.global_position = world_point(Vector3(14.5, 1.25, 9.2))
			plasma_soda_time = maxf(plasma_soda_time, 8.0)
			invuln = maxf(invuln, 0.8)
			_toast("SYNAPSE FAST TRAVEL: HAIRBALL FOREST", Color("#79dfff"), 2.2)
		"relay_to_nerve":
			player.global_position = world_point(Vector3(0.0, 1.25, -11.2))
			plasma_soda_time = maxf(plasma_soda_time, 8.0)
			invuln = maxf(invuln, 0.8)
			_toast("SYNAPSE FAST TRAVEL: NERVE HIGHWAY", Color("#79dfff"), 2.2)

func _calm_biome_enemies(territory: String, origin: Vector3, stun_time: float, damage: float) -> void:
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.get_meta("dead", false):
			continue
		if String(enemy.get_meta("territory", "")) != territory:
			continue
		enemy.set_meta("stun", maxf(float(enemy.get_meta("stun", 0.0)), stun_time))
		enemy.set_meta("goo_slow", maxf(float(enemy.get_meta("goo_slow", 0.0)), stun_time))
		if damage > 0.0:
			var impulse := enemy.global_position - origin
			impulse.y = 0.0
			_damage_enemy(enemy, damage, stun_time, 0.0, impulse.normalized() * 7.5)

func _complete_clue(index: int) -> void:
	if index < 0 or index >= clue_done.size() or clue_done[index]: return
	clue_done[index] = true
	credits += 12
	_toast("DIAGNOSIS COMPLETE  +12C", Color("#8ef7dc"), 1.8)
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
	var clue_story := [
		"CLUE 1  //  NO CHEW MARKS. MOCHI CARRIED THE TOY GENTLY — THEN SWALLOWED IT WHOLE.",
		"CLUE 2  //  NOT A SHORT CIRCUIT: A CHILD'S RECORDING. EVERY CHIRP SLOWS MOCHI'S HEART.",
		"CLUE 3  //  THE PLATELETS BUILT A CRADLE, NOT A PRISON. HER BODY WAS TRYING TO KEEP IT SAFE."
	]
	_story_beat(clue_story[index], 6.5, index + 1)
	if _clue_count() >= 3:
		mission_phase = "chase"
		_spawn_mission_mouse()
		danger_label.text = "VOICE MEMORY LOCATED — ACID CORROSION CRITICAL"
		_story_beat("FALSE DIAGNOSIS  //  THE TOY WAS NEVER ATTACKING MOCHI. SHE SWALLOWED IT TO STOP SOMEONE THROWING IT AWAY.", 9.0, 4)

func _spawn_mission_mouse() -> void:
	if is_instance_valid(mouse_target): return
	_spawn_enemy("TOY_MOUSE", world_point(Vector3(18.0, 0.55, -8.7)), Color("#9cf26b"), 9999.0, 6.6)
	mouse_target = enemies[-1]
	mouse_target.set_meta("contact_damage", 0.0)
	mouse_target.set_meta("fake_phase", 0.0)
	mouse_target.set_meta("burst_time", 0.0)
	mouse_target.set_meta("burst_cd", 1.2)
	mouse_target.set_meta("fake_stop", 0.0)
	_decorate_mouse(mouse_target)
	var lab := mouse_target.get_meta("hp_label") as Label3D
	if lab: lab.text = "MEMORY MOUSE  //  00:03 AUDIO LEFT"


func _decorate_mouse(e: CharacterBody3D) -> void:
	var visual := e.get_meta("visual") as Node3D
	if visual and visual.get_node_or_null("MouseShell"): return
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
	if float(mouse_target.get_meta("controlled", 0.0)) > 0.0: return true
	if spark_mark_target == mouse_target and spark_mark_time > 0.0: return true
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
	danger_label.text = "MEMORY SECURED - GET THE LAST MESSAGE OUT"
	_story_beat("RECOVERED AUDIO  //  'MOCHI, KEEP MY MOUSE SAFE. I'LL COME HOME WHEN THE DOCTORS LET ME.'", 9.0, 5)

func _is_host_boss(entity: Node) -> bool:
	return is_instance_valid(entity) and is_instance_valid(host_boss) and entity == host_boss.target

func _cinematic_locked() -> bool:
	return mission_phase in ["escape","ending","win"] or (is_instance_valid(host_boss) and host_boss.state == "toy_intro")

func _begin_escape_finale() -> void:
	if mission_phase != "return" or not mouse_caught or is_instance_valid(escape_finale): return
	escape_finale = preload("res://scripts/escape_finale.gd").new()
	add_child(escape_finale)
	escape_finale.start(self)

func _begin_host_boss() -> void:
	if mission_phase != "return" or is_instance_valid(host_boss):
		return
	if is_instance_valid(bubble_payload):
		bubble_payload.set_meta("engulfed", false)
		bubble_payload = null
	_cancel_phase11_holds()
	for zone_list in [surf_lanes, fungus_patches]:
		for zone in zone_list:
			if is_instance_valid(zone): zone.queue_free()
		zone_list.clear()
	host_boss = HostBoss.new()
	host_boss.name = "HostBossFinale"
	add_child(host_boss)
	host_boss.start(self)
	host_boss.state_time = 2.4
	terrain_world.enter_clinic()
	interact_down = false
	capture_bar.visible = false
	interact_label.text = ""

func _win_round() -> void:
	if mission_phase != "ending" or not is_instance_valid(host_boss) or not host_boss.rescued:
		return
	credits += 20
	mission_phase = "win"
	if is_instance_valid(mouse_target): mouse_target.visible = false
	win_panel.visible = true
	if mission_label: mission_label.visible = false
	if story_label: story_label.visible = false
	if danger_label: danger_label.visible = false
	win_label.text = "THE LAST GOODNIGHT

\"Mochi, keep my mouse safe. I'll come home.\"
The shelter record called her abandoned.
At the clinic door, a little girl's hand reached in.

Mochi had not swallowed a toy by mistake.
She had hidden a promise where nobody could throw it away.

Time %.1fs  ·  KOs %d  ·  Sync %d  ·  Credits %d  ·  Purchases %d" % [round_time, defeats, synergies, credits, purchases]
	if is_instance_valid(clinic_system) and clinic_system.enabled:
		win_label.text += "\n急诊报告：治愈 %d/3 · 清洁 %d 块 · 回收收益 %d C" % [clinic_system.completed,clinic_system.clean_cells,clinic_system.sold_value]
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
	var mouse_dist: float = e.global_position.distance_to(player.global_position)
	var pressure: float = clampf((6.5 - mouse_dist) / 6.5, 0.0, 1.0)
	var burst_time: float = maxf(0.0, float(e.get_meta("burst_time", 0.0)) - delta)
	var burst_cd: float = maxf(0.0, float(e.get_meta("burst_cd", 0.0)) - delta)
	var fake_stop: float = maxf(0.0, float(e.get_meta("fake_stop", 0.0)) - delta)
	var wall_bump: float = maxf(0.0, float(e.get_meta("wall_bump", 0.0)) - delta)
	if pressure > 0.35 and burst_cd <= 0.0 and stun <= 0.0 and pinned <= 0.0:
		if sin(living_time * 2.35 + e.global_position.z) > -0.10:
			burst_time = 0.52
			burst_cd = 2.35
			EnemyFactory.spawn_mouse_burst(self, e.global_position)
		else:
			fake_stop = 0.24
			burst_cd = 1.75
	e.set_meta("burst_time", burst_time)
	e.set_meta("burst_cd", burst_cd)
	e.set_meta("fake_stop", fake_stop)
	if stun > 0.0 or pinned > 0.0:
		e.velocity.x = move_toward(e.velocity.x, 0.0, 22.0 * delta)
		e.velocity.z = move_toward(e.velocity.z, 0.0, 22.0 * delta)
	elif fake_stop > 0.0:
		e.velocity.x = move_toward(e.velocity.x, 0.0, 34.0 * delta)
		e.velocity.z = move_toward(e.velocity.z, 0.0, 34.0 * delta)
	else:
		var away := e.global_position - player.global_position
		away.y = 0.0
		if away.length() < 0.2: away = Vector3.RIGHT
		var side := Vector3(-away.z, 0, away.x).normalized()
		var feint := sin(living_time * 5.4 + e.global_position.x * 0.7) * (0.82 + pressure * 0.28)
		var flee_dir := (away.normalized() + side * feint).normalized()
		var burst_boost: float = 1.55 if burst_time > 0.0 else 1.0
		var speed: float = 6.6 * route_boost * burst_boost * (0.48 if slowed else 1.0)
		e.velocity.x = move_toward(e.velocity.x, flee_dir.x * speed, 28.0 * delta)
		e.velocity.z = move_toward(e.velocity.z, flee_dir.z * speed, 28.0 * delta)
	e.velocity.y -= 18.0 * delta
	e.move_and_slide()
	var planar := Vector2(e.velocity.x, e.velocity.z)
	if planar.length() > 0.4: e.rotation.y = atan2(-e.velocity.x, -e.velocity.z)
	var mouse_visual := e.get_meta("visual") as Node3D
	EnemyFactory.animate(mouse_visual, "TOY_MOUSE", living_time, e.velocity, stun > 0.0, pinned > 0.0, pressure + (0.45 if burst_time > 0.0 else 0.0))
	var hit_wall := false
	if absf(e.position.x) > 21.5 * world_scale:
		e.velocity.x *= -0.72
		hit_wall = true
	if absf(e.position.z) > 12.5 * world_scale:
		e.velocity.z *= -0.72
		hit_wall = true
	if hit_wall:
		wall_bump = 0.22
		EnemyFactory.spawn_mouse_bump(self, e.global_position)
	e.set_meta("wall_bump", wall_bump)
	EnemyFactory.apply_mouse_bump(mouse_visual, wall_bump)
	e.position.x = clampf(e.position.x, -21.5 * world_scale, 21.5 * world_scale)
	e.position.z = clampf(e.position.z, -12.5 * world_scale, 12.5 * world_scale)

	if drink_time > 0.0 and _in_drink_wave(e.position):
		e.velocity.x += drink_dir * 8.0 * delta
	var lab := e.get_meta("hp_label") as Label3D
	if lab:
		var state := ""
		if pinned > 0.0: state = "  PINNED"
		elif stun > 0.0: state = "  STUNNED"
		elif slowed: state = "  SLOWED"
		elif burst_time > 0.0: state = "  TURBO BURST"
		elif fake_stop > 0.0: state = "  FEINT"
		elif route_boost > 1.0: state = "  SHORTCUT BOOST"
		lab.text = "ELECTRONIC MOUSE" + state

# GODOT_PHASE2_GAMEPLAY
# GODOT_PHASE3_MISSION
# GODOT_PHASE3_POLISH
# GODOT_PHASE4_MAP_SYNC
# GODOT_PHASE4_ZONE_SYNC
# GODOT_PHASE4_UI_POLISH
# GODOT_PHASE4_GAMEPAD
# GODOT_CHARACTER_MODELS_V1
# GODOT_CHARACTER_ANIMATION_V1
# GODOT_SKILL_VFX_V1
# GODOT_PERSISTENT_VFX_V2
# GODOT_CHARACTER_MODELS_V3_FOLLOWERS
# GODOT_MAP_VISUAL_V2
# GODOT_MAP_VISUAL_V2B
# GODOT_MAP_VISUAL_V2C
# GODOT_CHARACTER_MODELS_V2
# GODOT_PHASE2_POLISH

# GODOT_POLISH_V1

# GODOT_ROLE_SELECT_V1

# GODOT_ROLE_CARDS_V1

# GODOT_ENEMY_MODELS_V1

# GODOT_ENEMY_DEATH_VFX_V1

# GODOT_PHASE5_VISUAL

func build_network_snapshot() -> Dictionary:
	return NetworkState.snapshot(self)

# GODOT_NETWORK_STATE_INTERFACE_V1

func _build_shop() -> void:
	var built: Dictionary = ShopFactory.build(self)
	shop_root = built["root"] as Node3D
	shop_pads.clear()
	for pad in built["pads"]:
		shop_pads.append(pad as Node3D)

func _tick_fun_items(delta: float) -> void:
	acid_umbrella_time = maxf(0.0, acid_umbrella_time - delta)
	plasma_soda_time = maxf(0.0, plasma_soda_time - delta)
	catnip_time = maxf(0.0, catnip_time - delta)
	ShopFactory.set_umbrella(character_visual, acid_umbrella_time > 0.0)
	if is_instance_valid(catnip_beacon):
		if catnip_time <= 0.0:
			catnip_beacon.queue_free()
			catnip_beacon = null
		else:
			ShopFactory.animate_catnip(catnip_beacon, living_time)
func _buy_item(index: int) -> bool:
	if index < 0 or index >= ShopFactory.ITEM_COSTS.size(): return false
	var cost: int = ShopFactory.ITEM_COSTS[index]
	if credits < cost:
		_toast("细菌老板：钱不够！先去救人、清洁或钓宝。",Color("#ff8d9a"),2.2)
		return false
	credits -= cost
	purchases += 1
	if index < shop_pads.size() and is_instance_valid(shop_pads[index]):
		var pad := shop_pads[index]
		_spawn_impact(pad.global_position + Vector3.UP * 0.55, ShopFactory.ITEM_COLORS[index])
		pad.scale = Vector3.ONE * 0.72
		create_tween().set_trans(Tween.TRANS_BACK).tween_property(pad, "scale", Vector3.ONE, 0.28)
		hit_shake = maxf(hit_shake, 0.06)
	match index:
		0:
			acid_umbrella_time = maxf(acid_umbrella_time, 18.0)
			_toast("细菌老板：胃酸伞开张！18秒胃酸伤害 -82%，水流冲击减弱。",Color("#ffe36b"),3.0)
		1:
			plasma_soda_time = maxf(plasma_soda_time, 16.0)
			_toast("细菌老板：血浆汽水！16秒速度 +28%、超级跳、冷却恢复 x1.55。",Color("#64e5ff"),3.0)
		2:
			catnip_time = 14.0
			if is_instance_valid(catnip_beacon): catnip_beacon.queue_free()
			catnip_beacon = ShopFactory.spawn_catnip(self, player.global_position + _forward()*1.8)
			_toast("细菌老板：猫薄荷已投放！附近怪物会被吸引14秒。",Color("#d985ff"),2.8)
		3:
			_apply_mystery_capsule()
	_update_hud()
	return true
func _apply_mystery_capsule() -> void:
	var roll := randi() % 5
	match roll:
		0:
			hp = minf(100.0, hp + 45.0)
			_toast("MYSTERY: strawberry plasma refill!", Color("#ff91bb"), 2.2)
		1:
			skill_q_cd = 0.0
			skill_e_cd = 0.0
			_toast("MYSTERY: illegal cooldown paperwork!", Color("#ffe36b"), 2.2)
		2:
			credits += 24
			_toast("MYSTERY: platelet refund jackpot +24C", Color("#ffd34f"), 2.2)
		3:
			ferment_time = maxf(ferment_time, 12.0)
			_toast("MYSTERY: temporary mega-clay mutation", Color("#b989ff"), 2.2)
		4:
			acid_tide_time = maxf(acid_tide_time, 3.5)
			hp = maxf(1.0, hp - 8.0)
			_toast("MYSTERY: uh-oh... fizzy acid surprise", Color("#b7ef4a"), 2.4)

func _nearest_shop_item(max_dist := 1.45) -> int:
	var best := -1
	var best_d := max_dist
	for i in range(shop_pads.size()):
		if not is_instance_valid(shop_pads[i]): continue
		var d := player.global_position.distance_to(shop_pads[i].global_position)
		if d < best_d:
			best_d = d
			best = i
	return best

# GODOT_PHASE8_ECONOMY_GAMEPLAY

# GODOT_PHASE9_MOUSE_COMBAT
func _attack_target_position(target: CharacterBody3D, max_range: float) -> Vector3:
	if is_instance_valid(target):
		return target.global_position + Vector3.UP * 0.72
	return player.global_position + _forward() * max_range + Vector3.UP * 0.75

func _primary_attack() -> void:
	if _cinematic_locked(): return
	if not role_selected or game_paused or mission_phase == "win" or ko_time > 0.0 or primary_attack_cd > 0.0:
		return
	match role_index:
		0: _spark_arc_shot()
		1: _kaka_tap_nail()
		2: _start_bubble_roll(0.32)
		3: _shroom_spore_shot()
func _secondary_attack() -> void:
	if _cinematic_locked(): return
	if not role_selected or game_paused or mission_phase == "win" or ko_time > 0.0 or secondary_attack_cd > 0.0:
		return
	anim_cast_time = 0.34
	anim_cast_slot = 1
	match role_index:
		0: _spark_lightning_form()
		1: _kaka_bone_hook()
		2: _bubble_sling_instant(0.55)
		3: _shroom_puppet_thread()
func _spark_phase_blink() -> void:
	var start := player.global_position
	var finish := start + _forward() * 6.4
	finish = _safe_skill_destination(finish)
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.get_meta("dead", false):
			continue
		var closest := Geometry3D.get_closest_point_to_segment(enemy.global_position, start, finish)
		if enemy.global_position.distance_to(closest) < 1.55:
			_damage_enemy(enemy, 21.0, 0.85, 0.0, _forward() * 5.5)
	SkillVFX.spawn_phase_blink(self, start + Vector3.UP * 0.78, finish + Vector3.UP * 0.78, ROLE_COLORS[0])
	player.global_position = finish
	player.velocity = _forward() * 4.5
	invuln = maxf(invuln, 0.24)
	damage_shake = maxf(damage_shake, 0.08)
	_toast("PHASE BLINK: THROUGH TISSUE", Color("#ffe36b"), 1.4)

func _control_target_for(source: CharacterBody3D) -> CharacterBody3D:
	if is_instance_valid(puppet_command_target) and puppet_command_target != source and not puppet_command_target.get_meta("dead", false):
		return puppet_command_target
	var best: CharacterBody3D
	var best_dist := 9999.0
	for candidate in enemies:
		if candidate == source or not is_instance_valid(candidate) or candidate.get_meta("dead", false):
			continue
		if candidate == mouse_target or float(candidate.get_meta("controlled", 0.0)) > 0.0:
			continue
		var dist := source.global_position.distance_to(candidate.global_position)
		if dist < best_dist:
			best_dist = dist
			best = candidate
	return best

func _build_frontend() -> void:
	var callbacks := {
		"start": Callable(self, "_menu_show_levels"),
		"settings": Callable(self, "_open_settings").bind(false),
		"quit": Callable(self, "_open_quit").bind("main"),
		"choose_cat": Callable(self, "_begin_selected_level").bind("cat_stomach"),
		"back": Callable(self, "_show_front").bind("main"),
		"volume": Callable(self, "_on_volume_changed"),
		"sensitivity": Callable(self, "_on_sensitivity_changed"),
		"fov": Callable(self, "_on_fov_changed"),
		"fullscreen": Callable(self, "_on_fullscreen_toggled"),
		"settings_back": Callable(self, "_settings_back"),
		"resume": Callable(self, "_resume_game"),
		"pause_settings": Callable(self, "_open_settings").bind(true),
		"pause_levels": Callable(self, "_pause_to_level_select"),
		"pause_main": Callable(self, "_return_to_main_menu"),
		"pause_quit": Callable(self, "_open_quit").bind("pause"),
		"quit_no": Callable(self, "_cancel_quit"),
		"quit_yes": Callable(self, "_confirm_quit")
	}
	front_ui = FrontendUI.build(self, callbacks)

func _show_front(screen_name: String) -> void:
	current_front_screen = screen_name
	FrontendUI.show_screen(front_ui, screen_name)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
func _menu_show_levels() -> void:
	_show_front("levels")

func _begin_selected_level(level_id: String) -> void:
	if level_id != "cat_stomach":
		return
	selected_level_id = level_id
	game_paused = false
	role_selected = false
	FrontendUI.hide_all(front_ui)
	current_front_screen = ""
	role_panel.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _open_settings(from_pause: bool) -> void:
	settings_from_pause = from_pause
	if from_pause:
		game_paused = true
	_show_front("settings")

func _settings_back() -> void:
	_show_front("pause" if settings_from_pause else "main")

func _open_pause() -> void:
	if not role_selected:
		return
	game_paused = true
	_show_front("pause")

func _resume_game() -> void:
	game_paused = false
	current_front_screen = ""
	FrontendUI.hide_all(front_ui)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if mission_phase in ["ending", "win"] else Input.MOUSE_MODE_CAPTURED
func _pause_to_level_select() -> void:
	reload_front_target = "levels"
	get_tree().reload_current_scene()

func _return_to_main_menu() -> void:
	reload_front_target = "main"
	get_tree().reload_current_scene()

func _open_quit(return_screen: String) -> void:
	quit_return_screen = return_screen
	if return_screen == "pause":
		game_paused = true
	_show_front("quit")

func _cancel_quit() -> void:
	_show_front(quit_return_screen)

func _confirm_quit() -> void:
	get_tree().quit(0)

func _handle_escape() -> void:
	if inventory_open:
		if is_instance_valid(inventory_ui): inventory_ui.close_inventory()
		return
	if role_panel and role_panel.visible:
		role_panel.visible = false
		_show_front("levels")
		return
	match current_front_screen:
		"main":
			_open_quit("main")
		"levels":
			_show_front("main")
		"settings":
			_settings_back()
		"quit":
			_cancel_quit()
		"pause":
			_resume_game()
		_:
			if game_paused:
				_resume_game()
			elif role_selected:
				_open_pause()
func _on_volume_changed(value: float) -> void:
	if front_ui.has("volume_value"):
		front_ui["volume_value"].text = "%d%%" % int(value)
	var master_bus := AudioServer.get_bus_index("Master")
	if master_bus >= 0:
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(maxf(value / 100.0, 0.001)))
		AudioServer.set_bus_mute(master_bus, value <= 0.0)

func _on_sensitivity_changed(value: float) -> void:
	mouse_sensitivity = value / 100.0
	if front_ui.has("sensitivity_value"):
		front_ui["sensitivity_value"].text = "%.2fx" % mouse_sensitivity

func _on_fov_changed(value: float) -> void:
	camera_fov = value
	if camera_3p:
		camera_3p.fov = camera_fov
	if camera_1p:
		camera_1p.fov = minf(camera_fov + 4.0, 90.0)
	if front_ui.has("fov_value"):
		front_ui["fov_value"].text = "%d°" % int(value)

func _on_fullscreen_toggled(enabled: bool) -> void:
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)

# GODOT_PHASE11_ROLE_COMBAT_V2
func _cancel_phase11_holds() -> void:
	primary_hold = false
	secondary_hold = false
	kaka_charge_time = 0.0
	kaka_charge_nails = 0
	bubble_roll_charge = 0.0
	bubble_jump_charge = 0.0
	if is_instance_valid(kaka_charge_visual):
		kaka_charge_visual.queue_free()
	kaka_charge_visual = null

func _primary_pressed() -> void:
	if _cinematic_locked(): return
	if not role_selected or game_paused or mission_phase == "win" or ko_time > 0.0:
		return
	primary_hold = true
	match role_index:
		0, 3:
			_primary_attack()
		1:
			kaka_charge_time = 0.0
			kaka_charge_nails = 0
			_primary_attack()
		2:
			if primary_attack_cd > 0.0 or bubble_roll_time > 0.0:
				primary_hold = false
			else:
				bubble_roll_charge = 0.0
func _primary_released() -> void:
	if not primary_hold:
		return
	primary_hold = false
	if role_index == 1:
		_release_kaka_volley()
	elif role_index == 2:
		_start_bubble_roll(bubble_roll_charge)
	bubble_roll_charge = 0.0

func _secondary_pressed() -> void:
	if _cinematic_locked(): return
	if not role_selected or game_paused or mission_phase == "win" or ko_time > 0.0:
		return
	if role_index == 2:
		if secondary_attack_cd > 0.0 or bubble_airborne:
			return
		secondary_hold = true
		bubble_jump_charge = 0.0
	else:
		_secondary_attack()

func _secondary_released() -> void:
	if role_index == 2 and secondary_hold:
		secondary_hold = false
		_launch_bubble_sling(bubble_jump_charge)
		bubble_jump_charge = 0.0

func _tick_phase11(delta: float) -> void:
	if spark_mark_time > 0.0:
		spark_mark_time = maxf(0.0, spark_mark_time - delta)
		if is_instance_valid(spark_mark_target):
			spark_mark_position = spark_mark_target.global_position + Vector3.UP * 0.75
		if is_instance_valid(spark_mark_visual):
			spark_mark_visual.global_position = spark_mark_position
		if spark_mark_time <= 0.0:
			_clear_spark_mark()
	if is_instance_valid(kaka_charge_visual):
		kaka_charge_visual.global_position = player.global_position + Vector3.UP * 0.85
		kaka_charge_visual.rotation.y += delta * 1.8
	if primary_hold:
		match role_index:
			0:
				if primary_attack_cd <= 0.0: _spark_arc_shot()
			1:
				kaka_charge_time = minf(1.8, kaka_charge_time + delta)
				var nail_cap := 7+2*role_upgrade_level(1)
				var next_nails := mini(nail_cap, int(floor(kaka_charge_time / 1.75 * nail_cap)))
				if next_nails != kaka_charge_nails:
					kaka_charge_nails = next_nails
					_refresh_kaka_charge_visual()
			2:
				bubble_roll_charge = minf(1.0, bubble_roll_charge + delta / 1.6)
			3:
				if primary_attack_cd <= 0.0: _shroom_spore_shot()
	if secondary_hold and role_index == 2:
		bubble_jump_charge = minf(1.0, bubble_jump_charge + delta / 1.2)
	kaka_rush_time = maxf(0.0, kaka_rush_time - delta)
	bubble_roll_time = maxf(0.0, bubble_roll_time - delta)
	if bubble_roll_time <= 0.0:
		bubble_roll_power = 0.0
	if bubble_airborne:
		bubble_jump_elapsed += delta
	if bubble_decoy_time > 0.0:
		bubble_decoy_time = maxf(0.0, bubble_decoy_time - delta)
		if is_instance_valid(bubble_decoy):
			bubble_decoy.rotation.y += delta * 2.4
			bubble_decoy.scale = Vector3.ONE * (1.0 + sin(living_time * 5.0) * 0.08)
		if bubble_decoy_time <= 0.0 and is_instance_valid(bubble_decoy):
			SkillVFX.spawn_bubble_burst(self, bubble_decoy.global_position, 2.2)
			bubble_decoy.queue_free()
	_tick_bone_projectiles(delta)
	_tick_bubble_decoy_impact()
	_tick_clay_puppets(delta)
func _phase11_after_move(delta: float, now_on_floor: bool) -> void:
	if kaka_rush_time > 0.0:
		_tick_kaka_rush_contacts()
	if bubble_roll_time > 0.0:
		_tick_bubble_roll_contacts()
	if bubble_airborne and now_on_floor and bubble_jump_elapsed > 0.12:
		_bubble_land()
	if role_index != 1 or kaka_rush_time <= 0.0:
		character_visual.rotation.x = 0.0

func _spark_arc_shot() -> void:
	if primary_attack_cd > 0.0: return
	primary_attack_cd = PRIMARY_ATTACK_COOLDOWNS[0]
	anim_cast_time = 0.12
	anim_cast_slot = 0
	var target := _get_target(PRIMARY_ATTACK_RANGES[0], 0.15)
	var target_pos := _attack_target_position(target, 8.5)
	if is_instance_valid(target):
		_damage_enemy(target, 5.0, 0.04, 0.0, _forward() * 0.5, false)
		target.set_meta("spark_trace", 0.55)
		if (target == spark_mark_target and spark_mark_time > 0.0) or role_upgrade_level(0)>0:
			var chain_target := _spark_chain_target(target, 4.8)
			if is_instance_valid(chain_target):
				_damage_enemy(chain_target, 3.0, 0.10, 0.0, (chain_target.global_position - target.global_position).normalized() * 0.8, false)
				chain_target.set_meta("spark_trace", 0.55)
				SkillVFX.spawn_arc_stream(self, target.global_position + Vector3.UP * 0.72, chain_target.global_position + Vector3.UP * 0.72, true)
	SkillVFX.spawn_arc_stream(self, player.global_position + Vector3.UP * 0.88, target_pos, is_instance_valid(target))

func _spark_chain_target(source: CharacterBody3D, radius: float) -> CharacterBody3D:
	var best: CharacterBody3D
	var best_dist := radius
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy == source or enemy.get_meta("dead", false) or enemy.get_meta("engulfed", false): continue
		var dist := enemy.global_position.distance_to(source.global_position)
		if dist < best_dist:
			best_dist = dist
			best = enemy
	return best

func _spark_lightning_form() -> void:
	secondary_attack_cd = SECONDARY_ATTACK_COOLDOWNS[0]
	var start := player.global_position
	var finish := start + _forward() * (7.2+0.9*role_upgrade_level(0))
	finish = _safe_skill_destination(finish)
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.get_meta("dead", false): continue
		var closest := Geometry3D.get_closest_point_to_segment(enemy.global_position, start, finish)
		if enemy.global_position.distance_to(closest) < 1.45:
			_damage_enemy(enemy, 16.0, 0.85, 0.0, _forward() * 4.8)
	SkillVFX.spawn_phase_blink(self, start + Vector3.UP * 0.78, finish + Vector3.UP * 0.78, ROLE_COLORS[0])
	player.global_position = finish
	player.velocity = _forward() * 6.0
	invuln = maxf(invuln, 0.24)
	damage_shake = maxf(damage_shake, 0.09)
	_toast("LIGHTNING FORM: HIGH-SPEED PASS", Color("#ffe36b"), 1.2)

func _spark_conductive_mark_or_teleport() -> void:
	if spark_mark_time > 0.0:
		var start := player.global_position
		var finish := spark_mark_position
		if is_instance_valid(spark_mark_target):
			finish = spark_mark_target.global_position - _forward() * 1.05
			finish.y = maxf(1.0, finish.y)
		finish = _safe_skill_destination(finish)
		SkillVFX.spawn_phase_blink(self, start + Vector3.UP * 0.7, finish + Vector3.UP * 0.7, ROLE_COLORS[0])
		player.global_position = finish
		invuln = maxf(invuln, 0.28)
		for enemy in enemies:
			if is_instance_valid(enemy) and not enemy.get_meta("dead", false) and enemy.global_position.distance_to(finish) < 2.0:
				_damage_enemy(enemy, 8.0, 0.35, 0.0, (enemy.global_position - finish).normalized() * 2.0)
		skill_q_cd = Q_COOLDOWNS[0]
		_clear_spark_mark()
		_toast("CONDUCTIVE RECALL", Color("#fff06a"), 1.2)
		return
	spark_mark_target = _get_target(18.0, 0.08)
	if is_instance_valid(spark_mark_target):
		_damage_enemy(spark_mark_target as CharacterBody3D, 4.0, 0.35, 0.0, Vector3.ZERO, false)
	spark_mark_position = spark_mark_target.global_position + Vector3.UP * 0.75 if is_instance_valid(spark_mark_target) else _spark_wall_mark_position()
	spark_mark_position = _safe_skill_destination(spark_mark_position)
	spark_mark_time = 9.0
	spark_mark_visual = SkillVFX.spawn_conductive_mark(self, spark_mark_position, is_instance_valid(spark_mark_target))
	_toast("Q AGAIN: TELEPORT TO CONDUCTOR", Color("#fff06a"), 1.6)
func _clear_spark_mark() -> void:
	spark_mark_time = 0.0
	spark_mark_target = null
	if is_instance_valid(spark_mark_visual):
		spark_mark_visual.queue_free()
	spark_mark_visual = null

func _spark_neural_storm() -> void:
	var reacted := false
	var radius := 5.4+0.4*role_upgrade_level(0)
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.get_meta("dead", false): continue
		if enemy.global_position.distance_to(player.global_position) < radius:
			var marked_bonus := enemy == spark_mark_target
			_damage_enemy(enemy, 18.0, 2.8 if marked_bonus else 2.2, 0.0, (enemy.global_position - player.global_position).normalized() * 2.6)
	for zone in surf_lanes + fungus_patches + bone_structures:
		if is_instance_valid(zone) and zone.global_position.distance_to(player.global_position) < 6.5:
			zone.set_meta("ttl", float(zone.get_meta("ttl", 6.0)) + 3.0)
			zone.set_meta("charged", true)
			reacted = true
	SkillVFX.spawn_neural_storm(self, player.global_position, radius)
	if reacted:
		synergies += 1
		_toast("SYNC: CONDUCTIVE BIO NETWORK", Color("#ffe15e"), 2.0)
	else:
		_toast("NEURAL STORM: PARALYSIS FIELD", Color("#ffe15e"), 1.5)

func _kaka_tap_nail() -> void:
	if primary_attack_cd > 0.0: return
	primary_attack_cd = PRIMARY_ATTACK_COOLDOWNS[1]
	anim_cast_time = 0.22
	anim_cast_slot = 0
	_spawn_bone_nail(_forward(), 15.0, false)

func _release_kaka_volley() -> void:
	var count := kaka_charge_nails
	if count > 0:
		for i in range(count):
			var spread := (float(i) - float(count - 1) * 0.5) * 0.055
			var direction := _forward().rotated(Vector3.UP, spread)
			_spawn_bone_nail(direction, 9.5, true)
		primary_attack_cd = 0.8 + float(count) * 0.06
		_toast("BONE VOLLEY x%d" % count, Color("#f4ead4"), 1.2)
	kaka_charge_time = 0.0
	kaka_charge_nails = 0
	if is_instance_valid(kaka_charge_visual): kaka_charge_visual.queue_free()
	kaka_charge_visual = null
func _refresh_kaka_charge_visual() -> void:
	if is_instance_valid(kaka_charge_visual):
		kaka_charge_visual.queue_free()
	kaka_charge_visual = SkillVFX.spawn_bone_charge(self, player.global_position + Vector3.UP * 0.85, kaka_charge_nails)

func _spawn_bone_nail(direction: Vector3, damage: float, volley: bool) -> void:
	var nail := Node3D.new()
	nail.name = "BoneNailProjectile"
	nail.position = player.global_position + Vector3.UP * 0.82 + direction * 0.7
	nail.set_meta("velocity", direction.normalized() * (13.5 if volley else 16.0))
	nail.set_meta("ttl", 6.0)
	nail.set_meta("stuck", false)
	nail.set_meta("damage", damage)
	SkillVFX.decorate_bone_nail(nail, volley)
	add_child(nail)
	bone_projectiles.append(nail)

func _tick_bone_projectiles(delta: float) -> void:
	_prune_freed_nodes(bone_projectiles)
	for nail in bone_projectiles.duplicate():
		if not is_instance_valid(nail): continue
		var ttl := float(nail.get_meta("ttl")) - delta
		nail.set_meta("ttl", ttl)
		if ttl <= 0.0:
			bone_projectiles.erase(nail)
			nail.queue_free()
			continue
		if bool(nail.get_meta("stuck")):
			continue
		var velocity: Vector3 = nail.get_meta("velocity")
		var old_pos: Vector3 = nail.global_position
		var new_pos: Vector3 = old_pos + velocity * delta
		var hit_enemy: CharacterBody3D
		for enemy in enemies:
			if is_instance_valid(enemy) and not enemy.get_meta("dead", false) and not enemy.get_meta("engulfed", false) and (enemy.global_position + Vector3.UP * 0.65).distance_to(new_pos) < 0.72:
				hit_enemy = enemy
				break
		if is_instance_valid(hit_enemy):
			nail.global_position = hit_enemy.global_position + Vector3.UP * 0.65
			nail.set_meta("stuck", true)
			nail.set_meta("stuck_enemy", hit_enemy)
			nail.set_meta("ttl", 2.4)
			hit_enemy.set_meta("bone_pins", mini(7, int(hit_enemy.get_meta("bone_pins", 0)) + 1))
			_damage_enemy(hit_enemy, float(nail.get_meta("damage")), 0.12, 1.45, velocity.normalized() * 2.5)
			SkillVFX.spawn_bone_impact(self, nail.global_position, true)
			continue
		var query := PhysicsRayQueryParameters3D.create(old_pos, new_pos)
		query.exclude = [player.get_rid()]
		var wall_hit := get_world_3d().direct_space_state.intersect_ray(query)
		if not wall_hit.is_empty():
			nail.global_position = wall_hit["position"]
			nail.set_meta("stuck", true)
			nail.set_meta("ttl", 5.0)
			SkillVFX.spawn_bone_impact(self, nail.global_position, false)
		else:
			nail.global_position = new_pos

func _kaka_bone_hook() -> void:
	secondary_attack_cd = SECONDARY_ATTACK_COOLDOWNS[1]
	var target := _get_target(13.0, 0.10)
	var target_pos := _attack_target_position(target, 7.0)
	if not is_instance_valid(target):
		SkillVFX.spawn_basic_attack(self, 1, true, player.global_position + Vector3.UP * 0.86, target_pos)
		_toast("BONE HOOK: NO TARGET", ROLE_COLORS[1], 1.0)
		return
	var pull := player.global_position - target.global_position
	pull.y = 0.0
	_damage_enemy(target, 18.0, 0.35, 1.1, pull.normalized() * 10.5)
	SkillVFX.spawn_basic_attack(self, 1, true, player.global_position + Vector3.UP * 0.86, target.global_position + Vector3.UP * 0.7)
	_toast("BONE HOOK: PULL + SHORT PIN", Color("#f2e8d4"), 1.4)

func _start_kaka_charge() -> void:
	kaka_rush_time = 0.72
	kaka_rush_hits.clear()
	invuln = maxf(invuln, 0.20)
	SkillVFX.spawn_kaka_charge(self, player.global_position, _forward())
	_toast("BONE CHARGE: CREW COLLISION ON", Color("#f4ead4"), 1.2)

func _tick_kaka_rush_contacts() -> void:
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.get_meta("dead", false): continue
		var key := enemy.get_instance_id()
		if not kaka_rush_hits.has(key) and enemy.global_position.distance_to(player.global_position) < 1.65:
			kaka_rush_hits[key] = true
			var pins := int(enemy.get_meta("bone_pins", 0))
			_damage_enemy(enemy, 30.0 + float(pins) * 7.0, 0.8 + float(pins) * 0.12, 0.0, _forward() * (12.0 + float(pins)))
			if pins > 0:
				_shatter_bone_pins(enemy)
				_toast("BONE SHATTER x%d" % pins, Color("#fff1d5"), 1.2)
			else:
				SkillVFX.spawn_bone_impact(self, enemy.global_position + Vector3.UP * 0.5, true)
	for ally in get_tree().get_nodes_in_group("crew_allies"):
		if ally == player or not is_instance_valid(ally): continue
		var key := ally.get_instance_id()
		if not kaka_rush_hits.has(key) and ally is CharacterBody3D and ally.global_position.distance_to(player.global_position) < 1.55:
			kaka_rush_hits[key] = true
			ally.velocity += _forward() * 13.0 + Vector3.UP * 4.0
			SkillVFX.spawn_bone_impact(self, ally.global_position + Vector3.UP * 0.5, false)

func _shatter_bone_pins(enemy: CharacterBody3D) -> void:
	enemy.set_meta("bone_pins", 0)
	for nail in bone_projectiles.duplicate():
		if is_instance_valid(nail) and nail.get_meta("stuck_enemy", null) == enemy:
			bone_projectiles.erase(nail)
			nail.queue_free()
	SkillVFX.spawn_bone_shatter(self, enemy.global_position + Vector3.UP * 0.72)
	damage_shake = maxf(damage_shake, 0.16)

func _start_bubble_roll(power: float) -> void:
	if bubble_roll_time > 0.0: return
	bubble_roll_power = clampf(power, 0.2, 1.0)
	bubble_roll_time = 0.75 + bubble_roll_power * 0.95
	bubble_roll_hits.clear()
	primary_attack_cd = bubble_roll_time + 0.25
	anim_cast_time = 0.28
	anim_cast_slot = 0
	SkillVFX.spawn_bubble_roll(self, player.global_position, bubble_roll_power)
	_toast("MEGA ROLL %d%%" % int(bubble_roll_power * 100.0), Color("#63dcff"), 1.0)

func _tick_bubble_roll_contacts() -> void:
	var radius := 1.0 + bubble_roll_power * 0.75
	if is_instance_valid(bubble_decoy) and not bool(bubble_decoy.get_meta("roll_kicked", false)) and bubble_decoy.global_position.distance_to(player.global_position) < radius + 0.75:
		bubble_decoy.set_meta("roll_kicked", true)
		bubble_decoy_time = minf(bubble_decoy_time, 3.2)
		var decoy_body := bubble_decoy as RigidBody3D
		if decoy_body:
			decoy_body.apply_central_impulse(_forward() * (10.0 + bubble_roll_power * 8.0) + Vector3.UP * 2.8)
		SkillVFX.spawn_bubble_burst(self, bubble_decoy.global_position, 1.5)
		_toast("DECOY KICK: LIVING PINBALL", Color("#80eaff"), 1.3)
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.get_meta("dead", false): continue
		var key := enemy.get_instance_id()
		if not bubble_roll_hits.has(key) and enemy.global_position.distance_to(player.global_position) < radius:
			bubble_roll_hits[key] = true
			enemy.set_meta("goo_slow", maxf(float(enemy.get_meta("goo_slow", 0.0)), 2.4))
			_damage_enemy(enemy, 12.0 + bubble_roll_power * 18.0, 0.18, 0.0, _forward() * (7.0 + bubble_roll_power * 6.0))
			SkillVFX.spawn_bubble_burst(self, enemy.global_position, 1.2 + bubble_roll_power)

func _tick_bubble_decoy_impact() -> void:
	if not is_instance_valid(bubble_decoy) or not bool(bubble_decoy.get_meta("roll_kicked", false)):
		return
	var decoy_body := bubble_decoy as RigidBody3D
	if not decoy_body or decoy_body.linear_velocity.length() < 2.4:
		return
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.get_meta("dead", false): continue
		if enemy.global_position.distance_to(decoy_body.global_position) < 1.45:
			var blast_pos := decoy_body.global_position
			for victim in enemies:
				if not is_instance_valid(victim) or victim.get_meta("dead", false): continue
				var dist := victim.global_position.distance_to(blast_pos)
				if dist < 2.7:
					victim.set_meta("goo_slow", maxf(float(victim.get_meta("goo_slow", 0.0)), 3.5))
					_damage_enemy(victim, 11.0 + (2.7 - dist) * 4.0, 0.28, 0.0, (victim.global_position - blast_pos).normalized() * 7.0, false)
			SkillVFX.spawn_bubble_burst(self, blast_pos, 1.9)
			_toast("DECOY CRASH: GOO PINBALL BURST", Color("#8bedff"), 1.5)
			decoy_body.queue_free()
			bubble_decoy = null
			bubble_decoy_time = 0.0
			return

func _launch_bubble_sling(power: float) -> void:
	var p := clampf(power, 0.15, 1.0)
	secondary_attack_cd = SECONDARY_ATTACK_COOLDOWNS[2]
	bubble_jump_charge = p
	bubble_airborne = true
	bubble_jump_elapsed = 0.0
	player.velocity = _forward() * (6.5 + p * 7.5)
	player.velocity.y = 7.5 + p * 6.0
	invuln = maxf(invuln, 0.20)
	SkillVFX.spawn_bubble_sling(self, player.global_position, _forward(), p)
func _bubble_land() -> void:
	bubble_airborne = false
	var power := clampf(bubble_jump_charge, 0.15, 1.0)
	var radius := 2.0 + power * 2.0 + 0.35*role_upgrade_level(2)
	if is_instance_valid(clinic_system) and clinic_system.active():
		for i in range(clinic_system.sites.size()):
			clinic_system.clean_at(i,player.global_position,radius,0.5+power*0.5)
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.get_meta("dead", false): continue
		var off := enemy.global_position - player.global_position
		if off.length() < radius:
			enemy.set_meta("goo_slow", maxf(float(enemy.get_meta("goo_slow", 0.0)), 4.5))
			_damage_enemy(enemy, 16.0 + power * 20.0, 0.45, 0.0, off.normalized() * (7.0 + power * 5.0) + Vector3.UP * 4.0)
	SkillVFX.spawn_bubble_sling_land(self, player.global_position, radius)
	damage_shake = maxf(damage_shake, 0.18)
	bubble_jump_charge = 0.0
	bubble_jump_elapsed = 0.0
	_toast("PLASMA SLING: SPLASH LANDING", Color("#63dcff"), 1.2)

func _bubble_sling_instant(power: float) -> void:
	secondary_attack_cd = SECONDARY_ATTACK_COOLDOWNS[2]
	var target := _get_target(11.0, 0.08)
	var finish := player.global_position + _forward() * (3.2 + power * 4.0)
	if is_instance_valid(target): finish = target.global_position - _forward() * 0.8
	finish = _safe_skill_destination(finish)
	player.global_position = finish
	bubble_jump_charge = power
	_bubble_land()

func _spawn_bubble_decoy() -> void:
	if is_instance_valid(bubble_decoy):
		SkillVFX.spawn_bubble_burst(self, bubble_decoy.global_position, 2.4)
		bubble_decoy.queue_free()
	bubble_decoy = SkillVFX.spawn_bubble_decoy(self, player.global_position + _forward() * 2.2)
	bubble_decoy_time = 8.0
	_toast("SPLIT DECOY: KICKABLE TROUBLE MAGNET", Color("#70e5ff"), 1.5)
func _bubble_regurgitate() -> void:
	if is_instance_valid(bubble_payload):
		bubble_payload.set_meta("engulfed", false)
		bubble_payload.visible = true
		bubble_payload.collision_layer = 1
		bubble_payload.collision_mask = 1
		bubble_payload.global_position = player.global_position + _forward() * 2.0
		_damage_enemy(bubble_payload, 36.0, 0.55, 0.0, _forward() * 14.0)
		SkillVFX.spawn_bubble_burst(self, bubble_payload.global_position, 2.0)
		bubble_payload = null
		skill_e_cd = E_COOLDOWNS[2]
		_toast("REGURGITATION CANNON: FIRE!", Color("#63dcff"), 1.4)
		return
	var target := _get_target(6.2, 0.03)
	if _is_host_boss(target):
		skill_e_cd = E_COOLDOWNS[2]
		_damage_enemy(target, 26.0, 0.9)
		SkillVFX.spawn_bubble_burst(self, target.global_position, 2.0)
		_toast("GIANT PATIENT: plasma cushion softens panic", ROLE_COLORS[2], 1.4)
		return
	if is_instance_valid(target):
		bubble_payload = target
		target.set_meta("engulfed", true)
		target.visible = false
		target.collision_layer = 0
		target.collision_mask = 0
		skill_e_cd = 0.0
		_toast("PAYLOAD STORED: E TO FIRE", Color("#9eefff"), 1.4)
	else:
		skill_e_cd = 0.8
		_toast("REGURGITATE: NO PAYLOAD", Color("#9eefff"), 1.0)

func _shroom_spore_shot() -> void:
	if primary_attack_cd > 0.0: return
	primary_attack_cd = PRIMARY_ATTACK_COOLDOWNS[3]
	anim_cast_time = 0.20
	anim_cast_slot = 0
	var target := _get_target(PRIMARY_ATTACK_RANGES[3], 0.14)
	var target_pos := _attack_target_position(target, 7.5)
	if is_instance_valid(target):
		var stacks := mini(3, int(target.get_meta("spore_stacks", 0)) + 1)
		target.set_meta("spore_stacks", stacks)
		target.set_meta("goo_slow", maxf(float(target.get_meta("goo_slow", 0.0)), 1.2 + float(stacks) * 0.35))
		_damage_enemy(target, 9.0, 0.08, 0.0, Vector3.ZERO, false)
		if stacks >= 3:
			target.set_meta("spore_stacks", 0)
			_shroom_spore_bloom(target.global_position)
	SkillVFX.spawn_spore_shot(self, player.global_position + Vector3.UP * 0.82, target_pos)
func _shroom_spore_bloom(pos: Vector3) -> void:
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.get_meta("dead", false) and enemy.global_position.distance_to(pos) < 2.5:
			enemy.set_meta("goo_slow", maxf(float(enemy.get_meta("goo_slow", 0.0)), 3.0))
			_damage_enemy(enemy, 18.0, 0.25, 0.0, (enemy.global_position - pos).normalized() * 2.8)
	SkillVFX.spawn_spore_bloom(self, pos, 2.5)
	_toast("SPORE BLOOM: INFECTION SPREAD", Color("#b989ff"), 1.2)

func _shroom_puppet_thread() -> void:
	secondary_attack_cd = SECONDARY_ATTACK_COOLDOWNS[3]
	var corpse := _get_corpse_target(9.0)
	if is_instance_valid(corpse):
		_control_clay_corpse(corpse)
		return
	var target := _get_target(13.0, 0.10)
	if not is_instance_valid(target):
		_toast("PUPPET THREAD: NO TARGET", ROLE_COLORS[3], 1.0)
		return
	if _is_host_boss(target):
		_damage_enemy(target, 18.0, 1.0)
		SkillVFX.spawn_puppet_thread(self, player.global_position + Vector3.UP, target.global_position + Vector3.UP)
		_toast("GIANT PATIENT: soothing thread, not possession", ROLE_COLORS[3], 1.4)
		return
	var active_puppet: CharacterBody3D
	for enemy in enemies:
		if is_instance_valid(enemy) and float(enemy.get_meta("controlled", 0.0)) > 0.0:
			active_puppet = enemy
			break
	if is_instance_valid(active_puppet) and target != active_puppet:
		puppet_command_target = target
		_toast("PUPPET COMMAND: ATTACK MARKED TARGET", Color("#c89bff"), 1.3)
	else:
		target.set_meta("controlled", maxf(float(target.get_meta("controlled", 0.0)), 6.0+0.75*role_upgrade_level(3)))
		target.set_meta("control_attack_cd", 0.12)
		_damage_enemy(target, 6.0, 0.16, 0.0, Vector3.ZERO, false)
		SkillVFX.spawn_puppet_thread(self, player.global_position + Vector3.UP * 0.9, target.global_position + Vector3.UP * 0.8)
		_toast("PUPPET THREAD: ENEMY HIJACKED", Color("#b989ff"), 1.6)
func _get_corpse_target(max_dist: float) -> CharacterBody3D:
	var best: CharacterBody3D
	var best_score := 9999.0
	for corpse in clay_corpses:
		if not is_instance_valid(corpse) or float(corpse.get_meta("puppet_time", 0.0)) > 0.0: continue
		var off := corpse.global_position - player.global_position
		var dist := off.length()
		if dist > max_dist or dist <= 0.01: continue
		var dot := _forward().dot(off.normalized())
		if dot < 0.05: continue
		var score := dist + (1.0 - dot) * 3.0
		if score < best_score:
			best_score = score
			best = corpse
	return best

func register_clay_corpse(corpse_role: int, pos: Vector3) -> CharacterBody3D:
	var corpse := CharacterBody3D.new()
	corpse.name = "CrewClayCorpse"
	corpse.position = pos
	corpse.add_to_group("clay_corpses")
	corpse.add_to_group("crew_allies")
	corpse.set_meta("owner_role", clampi(corpse_role, 0, 3))
	corpse.set_meta("puppet_time", 0.0)
	corpse.set_meta("attack_cd", 0.0)
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.34
	shape.height = 1.2
	collision.shape = shape
	collision.disabled = true
	corpse.add_child(collision)
	var visual := Node3D.new()
	visual.name = "CorpseVisual"
	corpse.add_child(visual)
	CharacterFactory.build_role(visual, clampi(corpse_role, 0, 3))
	visual.scale = Vector3(1.35, 0.08, 1.25)
	visual.position.y = -0.42
	corpse.set_meta("visual", visual)
	add_child(corpse)
	clay_corpses.append(corpse)
	return corpse
func _control_clay_corpse(corpse: CharacterBody3D) -> void:
	corpse.set_meta("puppet_time", 5.8)
	corpse.set_meta("attack_cd", 0.1)
	var visual := corpse.get_meta("visual") as Node3D
	if visual:
		visual.scale = Vector3.ONE * ROLE_VISUAL_SCALES[int(corpse.get_meta("owner_role"))]
		visual.position.y = 0.0
	var collision := corpse.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision: collision.disabled = false
	SkillVFX.spawn_puppet_thread(self, player.global_position + Vector3.UP * 0.9, corpse.global_position + Vector3.UP * 0.7)
	_toast("CLAY CORPSE PUPPET: TEMPORARY CREW", Color("#d7a7ff"), 1.8)

func _tick_clay_puppets(delta: float) -> void:
	for corpse in clay_corpses:
		if not is_instance_valid(corpse): continue
		var puppet_time := maxf(0.0, float(corpse.get_meta("puppet_time", 0.0)) - delta)
		var attack_cd := maxf(0.0, float(corpse.get_meta("attack_cd", 0.0)) - delta)
		corpse.set_meta("puppet_time", puppet_time)
		corpse.set_meta("attack_cd", attack_cd)
		var visual := corpse.get_meta("visual") as Node3D
		var collision := corpse.get_node_or_null("CollisionShape3D") as CollisionShape3D
		if puppet_time <= 0.0:
			if visual:
				visual.scale = Vector3(1.35, 0.08, 1.25)
				visual.position.y = -0.42
			if collision: collision.disabled = true
			corpse.velocity = Vector3.ZERO
			continue
		var target := _nearest_enemy_to(corpse.global_position, 12.0)
		if is_instance_valid(target):
			var off := target.global_position - corpse.global_position
			off.y = 0.0
			if off.length() > 1.4:
				corpse.velocity.x = off.normalized().x * 5.2
				corpse.velocity.z = off.normalized().z * 5.2
			elif attack_cd <= 0.0:
				corpse.set_meta("attack_cd", 0.82)
				_damage_enemy(target, 9.0, 0.1, 0.0, off.normalized() * 2.5, false)
				SkillVFX.spawn_spore_shot(self, corpse.global_position + Vector3.UP * 0.7, target.global_position + Vector3.UP * 0.7)
			corpse.velocity.y -= 18.0 * delta
			corpse.move_and_slide()
func _nearest_enemy_to(pos: Vector3, max_dist: float) -> CharacterBody3D:
	var best: CharacterBody3D
	var best_dist := max_dist
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.get_meta("dead", false) or enemy.get_meta("engulfed", false): continue
		var dist := enemy.global_position.distance_to(pos)
		if dist < best_dist:
			best_dist = dist
			best = enemy
	return best

func _shroom_ferment_burst() -> void:
	var reactions := 0
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.get_meta("dead", false): continue
		var stacks := int(enemy.get_meta("spore_stacks", 0))
		var controlled := float(enemy.get_meta("controlled", 0.0))
		if stacks > 0:
			enemy.set_meta("spore_stacks", 0)
			_damage_enemy(enemy, 8.0 + float(stacks) * 9.0, 0.25 * float(stacks), 0.0)
			SkillVFX.spawn_spore_bloom(self, enemy.global_position, 1.4 + float(stacks) * 0.35)
			reactions += 1
		if controlled > 0.0:
			enemy.set_meta("controlled", controlled + 3.0)
			enemy.set_meta("big", 4.0)
			reactions += 1
	for patch in fungus_patches:
		if is_instance_valid(patch):
			patch.set_meta("ttl", float(patch.get_meta("ttl", 6.0)) + 5.0)
			patch.set_meta("radius", float(patch.get_meta("radius", 3.2)) + 0.8)
			patch.scale *= 1.18
			reactions += 1
	for corpse in clay_corpses:
		if is_instance_valid(corpse) and float(corpse.get_meta("puppet_time", 0.0)) > 0.0:
			corpse.set_meta("puppet_time", float(corpse.get_meta("puppet_time")) + 3.0)
			reactions += 1
	ferment_time = 4.0
	SkillVFX.spawn_spore_bloom(self, player.global_position, 4.0)
	_toast("FERMENT BURST: %d BIO REACTIONS" % reactions, Color("#b989ff"), 1.8)

func _spark_wall_mark_position() -> Vector3:
	var origin := player.global_position + Vector3.UP * 0.82
	var finish := origin + _forward() * 18.0
	var query := PhysicsRayQueryParameters3D.create(origin, finish)
	query.exclude = [player.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		return hit["position"] + hit["normal"] * 0.08
	finish = _safe_skill_destination(finish)
	return finish
