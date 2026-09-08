extends Node3D
const Art = preload("res://scripts/clay_art.gd")
## Phase 30: clay first-person arms and role-specific field tools.
var game
var left_arm: Node3D
var right_arm: Node3D
var tool_root: Node3D
var role := -1
var base_position := Vector3(0.0, -0.56, -0.86)
var action_time := 0.0
var action_strength := 0.0
var action_kind := ""

func _mat(color: Color, emission := 0.0) -> StandardMaterial3D:
	var mat := Art.material(color)
	mat.albedo_color = color
	mat.roughness = 0.82
	if emission > 0.0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = emission
	return mat

func _part(parent: Node3D, name_: String, mesh: PrimitiveMesh, pos: Vector3, scale_: Vector3, color: Color, emission := 0.0) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = name_
	part.mesh = mesh
	part.position = pos
	part.scale = scale_
	part.material_override = _mat(color, emission)
	parent.add_child(part)
	return part

func _sphere(radius := 0.22) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 16
	mesh.rings = 8
	return mesh

func _capsule(radius := 0.16, height := 0.60) -> CapsuleMesh:
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 16
	mesh.rings = 6
	return mesh

func _cylinder(radius := 0.12, height := 0.55) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius * 1.08
	mesh.height = height
	mesh.radial_segments = 14
	return mesh

func build(host) -> void:
	game = host
	name = "FirstPersonClayRig30"
	position = base_position
	left_arm = Node3D.new()
	left_arm.name = "LeftClayArm"
	left_arm.position = Vector3(-0.54, -0.04, 0.06)
	add_child(left_arm)
	right_arm = Node3D.new()
	right_arm.name = "RightClayArm"
	right_arm.position = Vector3(0.54, -0.04, 0.06)
	add_child(right_arm)
	tool_root = Node3D.new()
	tool_root.name = "RoleTool"
	right_arm.add_child(tool_root)
	rebuild(game.role_index)
	set_process(true)

func _clear_parts(root: Node3D) -> void:
	for child in root.get_children():
		child.free()

func rebuild(index: int) -> void:
	role = clampi(index, 0, 3)
	_clear_parts(left_arm)
	_clear_parts(right_arm)
	tool_root = Node3D.new()
	tool_root.name = "RoleTool"
	right_arm.add_child(tool_root)
	var role_color: Color = game.ROLE_COLORS[role]
	var cuff_color := role_color.darkened(0.35)
	for entry in [[left_arm, -1.0], [right_arm, 1.0]]:
		var arm := entry[0] as Node3D
		var side := float(entry[1])
		var sleeve := _part(arm, "ClaySleeve", _capsule(0.12, 0.56), Vector3(0, 0.02, 0.0), Vector3.ONE, cuff_color)
		sleeve.rotation.x = -0.70
		sleeve.rotation.z = side * 0.12
		_part(arm, "GlovedHand", _sphere(0.16), Vector3(side * 0.025, 0.23, -0.22), Vector3(0.94, 0.80, 1.02), role_color)
		var cuff := _part(arm, "ClayCuff", _cylinder(0.18, 0.12), Vector3(0, -0.21, 0.15), Vector3.ONE, Color("#eee4d2"))
		cuff.rotation.x = -0.70
	_build_tool(role)
func _build_tool(index: int) -> void:
	match index:
		0:
			var coil := _part(tool_root, "SparkCoil", TorusMesh.new(), Vector3(0.01, 0.29, -0.34), Vector3(0.19, 0.19, 0.19), Color("#ffe45f"), 3.0)
			coil.rotation.x = PI * 0.5
			for x in [-0.075, 0.075]:
				var prong := _part(tool_root, "ArcProng", _cylinder(0.025, 0.34), Vector3(x, 0.40, -0.46), Vector3.ONE, Color("#fff8b0"), 2.6)
				prong.rotation.x = PI * 0.5
		1:
			var hammer_handle := _part(left_arm, "BoneHammerHandle", _cylinder(0.060, 0.68), Vector3(-0.09, 0.31, -0.38), Vector3.ONE, Color("#9d8063"))
			hammer_handle.rotation.x = PI * 0.5
			var hammer_head := _part(left_arm, "BoneHammerHead", _capsule(0.14, 0.60), Vector3(-0.09, 0.34, -0.72), Vector3(1.0, 0.92, 1.0), Color("#ead8ba"), 0.18)
			hammer_head.rotation.z = PI * 0.5
			_part(left_arm, "HammerKnuckleL", _sphere(0.13), Vector3(-0.39, 0.34, -0.72), Vector3(0.85, 0.96, 1.0), Color("#f2e4cc"))
			_part(left_arm, "HammerKnuckleR", _sphere(0.13), Vector3(0.21, 0.34, -0.72), Vector3(0.85, 0.96, 1.0), Color("#f2e4cc"))
			var hook_shaft := _part(tool_root, "BoneDriver", _cylinder(0.055, 0.60), Vector3(0.08, 0.31, -0.39), Vector3.ONE, Color("#9d8063"))
			hook_shaft.rotation.x = PI * 0.5
			Art.hook(tool_root, "BoneHook", Vector3(0.08,0.36,-0.73),0.19)
			for i in range(7):
				var wrap := _part(left_arm,"HammerGripWrap",_cylinder(0.068,0.027),Vector3(-0.09,0.31,-0.12-float(i)*0.046),Vector3.ONE,Color("#715143"))
				wrap.rotation.x=PI*0.5
			for side in [-1.0,1.0]:
				var cap := _part(left_arm,"HammerStrikePad",_sphere(0.115),Vector3(-0.09+side*0.30,0.34,-0.72),Vector3(0.33,0.94,0.96),Color("#b5a084"))
				cap.rotation.z=side*0.12
			for i in range(5):
				_part(left_arm,"HammerPore",_sphere(0.015),Vector3(-0.24+float(i)*0.075,0.40,-0.838),Vector3(1.0,0.45,0.20),Color("#ae967c"))
			for i in range(6):
				var ring := _part(tool_root,"HookGripWrap",_cylinder(0.063,0.028),Vector3(0.08,0.31,-0.13-float(i)*0.046),Vector3.ONE,Color("#715143"))
				ring.rotation.x=PI*0.5

		2:
			var nozzle := _part(tool_root, "PlasmaNozzle", _cylinder(0.11, 0.46), Vector3(0.02, 0.30, -0.38), Vector3.ONE, Color("#70e8ff"), 1.4)
			nozzle.rotation.x = PI * 0.5
			_part(tool_root, "BubbleTank", _sphere(0.18), Vector3(0.16, 0.16, -0.10), Vector3(0.86, 1.12, 0.86), Color(0.45, 0.92, 1.0, 0.72), 0.9)
		3:
			var stem := _part(tool_root, "SporeStem", _cylinder(0.07, 0.42), Vector3(0.02, 0.29, -0.34), Vector3.ONE, Color("#e6d3bf"))
			stem.rotation.x = PI * 0.5
			_part(tool_root, "SporeCap", _sphere(0.18), Vector3(0.02, 0.31, -0.59), Vector3(1.35, 0.54, 1.12), Color("#bb89ff"), 1.2)
			for x in [-0.10, 0.0, 0.10]:
				_part(tool_root, "SporeLamp", _sphere(0.035), Vector3(x, 0.32, -0.74), Vector3.ONE, Color("#e6ff93"), 2.4)

func refresh_visibility() -> void:
	if not is_instance_valid(game):
		visible = false
		return
	visible = game.first_person and game.role_selected and not game.game_paused and not game.inventory_open and not game._cinematic_locked()

func trigger_action(kind: String, strength := 0.5) -> void:
	action_kind = kind
	action_strength = clampf(strength, 0.0, 1.0)
	action_time = 0.24 + action_strength * 0.20

func _process(delta: float) -> void:
	if not is_instance_valid(game): return
	if role != game.role_index: rebuild(game.role_index)
	refresh_visibility()
	if not visible: return
	action_time = maxf(0.0, action_time - delta)
	var planar_speed := Vector2(game.player.velocity.x, game.player.velocity.z).length()
	var stride := clampf(planar_speed / 9.2, 0.0, 1.3)
	var clay_tick := floorf(game.living_time * 12.0) / 12.0
	var bob := sin(clay_tick * 9.0) * 0.018 * stride
	var sway := cos(clay_tick * 4.5) * 0.024 * stride
	position = base_position + Vector3(sway, bob + absf(bob) * 0.4, 0.0)
	var cast: float = sin(clampf(game.anim_cast_time / 0.42, 0.0, 1.0) * PI) if game.anim_cast_time > 0.0 else 0.0
	var hurt: float = sin(clampf(game.anim_hurt_time / 0.30, 0.0, 1.0) * PI) if game.anim_hurt_time > 0.0 else 0.0
	var action: float = sin(clampf(action_time / (0.24 + action_strength * 0.20), 0.0, 1.0) * PI) if action_time > 0.0 else 0.0
	var hammer_charge: float = clampf(game.kaka_charge_time / 1.8, 0.0, 1.0) if role == 1 and game.primary_hold else 0.0
	var hook_charge: float = game.kaka_hook_charge if role == 1 and game.secondary_hold else 0.0
	var armor: float = clampf(game.kaka_armor_time / 2.2, 0.0, 1.0) if role == 1 else 0.0
	left_arm.rotation = Vector3(-cast * 0.24 + hurt * 0.22 - hammer_charge * 0.82 - action * action_strength * 0.95, -cast * 0.12, -0.08 - sway - hammer_charge * 0.18)
	right_arm.rotation = Vector3(-cast * 0.52 + hurt * 0.30 - hook_charge * 0.20 + action * action_strength * 0.18, cast * 0.10, 0.08 + sway + hook_charge * 0.10)
	if role == 1:
		left_arm.position.z = 0.06 - hammer_charge * 0.13 + action * action_strength * 0.24
		right_arm.position.z = 0.06 - hook_charge * 0.16
	else:
		left_arm.position.z = 0.06
		right_arm.position.z = 0.06
	scale = Vector3(1.0 + hurt * 0.05 + armor * 0.035, 1.0 - hurt * 0.08 + armor * 0.025, 1.0 + armor * 0.04)
# GODOT_PHASE32_KAKA_DUAL_VIEWMODEL
