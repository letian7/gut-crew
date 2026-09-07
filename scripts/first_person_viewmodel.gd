extends Node3D
## Phase 30: clay first-person arms and role-specific field tools.
var game
var left_arm: Node3D
var right_arm: Node3D
var tool_root: Node3D
var role := -1
var base_position := Vector3(0.0, -0.42, -0.76)

func _mat(color: Color, emission := 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
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
	left_arm.position = Vector3(-0.31, -0.02, 0.03)
	add_child(left_arm)
	right_arm = Node3D.new()
	right_arm.name = "RightClayArm"
	right_arm.position = Vector3(0.31, -0.02, 0.03)
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
		var sleeve := _part(arm, "ClaySleeve", _capsule(0.14, 0.60), Vector3(0, 0.02, 0.0), Vector3.ONE, cuff_color)
		sleeve.rotation.x = -0.70
		sleeve.rotation.z = side * 0.12
		_part(arm, "GlovedHand", _sphere(0.19), Vector3(side * 0.01, 0.23, -0.22), Vector3(1.0, 0.82, 1.08), role_color)
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
			var shaft := _part(tool_root, "BoneDriver", _cylinder(0.075, 0.64), Vector3(0.02, 0.31, -0.40), Vector3.ONE, Color("#f4ead6"))
			shaft.rotation.x = PI * 0.5
			_part(tool_root, "BoneKnuckleA", _sphere(0.12), Vector3(0.02, 0.31, -0.10), Vector3(1.25, 0.72, 0.82), Color("#fff4df"))
			_part(tool_root, "BoneKnuckleB", _sphere(0.10), Vector3(0.02, 0.31, -0.71), Vector3(0.75, 0.75, 1.35), Color("#fff4df"))
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

func _process(_delta: float) -> void:
	if not is_instance_valid(game): return
	if role != game.role_index: rebuild(game.role_index)
	refresh_visibility()
	if not visible: return
	var planar_speed := Vector2(game.player.velocity.x, game.player.velocity.z).length()
	var stride := clampf(planar_speed / 9.2, 0.0, 1.3)
	var clay_tick := floorf(game.living_time * 12.0) / 12.0
	var bob := sin(clay_tick * 9.0) * 0.018 * stride
	var sway := cos(clay_tick * 4.5) * 0.024 * stride
	position = base_position + Vector3(sway, bob + absf(bob) * 0.4, 0.0)
	var cast := sin(clampf(game.anim_cast_time / 0.42, 0.0, 1.0) * PI) if game.anim_cast_time > 0.0 else 0.0
	var hurt := sin(clampf(game.anim_hurt_time / 0.30, 0.0, 1.0) * PI) if game.anim_hurt_time > 0.0 else 0.0
	left_arm.rotation = Vector3(-cast * 0.24 + hurt * 0.22, -cast * 0.12, -0.08 - sway)
	right_arm.rotation = Vector3(-cast * 0.52 + hurt * 0.30, cast * 0.10, 0.08 + sway)
	scale = Vector3(1.0 + hurt * 0.05, 1.0 - hurt * 0.08, 1.0)
# GODOT_PHASE30_FIRST_PERSON_VIEWMODEL
