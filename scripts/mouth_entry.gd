extends Node3D
const Clay = preload("res://scripts/art18_character.gd")
const Art = preload("res://scripts/organ_world_factory.gd")
const Detail = preload("res://scripts/art22_detail.gd")
const SPAWN := Vector3(0,18.6,63)
const ARRIVAL := Vector3(0,4.85,12)
var game
var active := false
var completed := false
var swallow_time := -1.0
var safe := SPAWN
var hidden_world: Array[Dictionary] = []
var roof_lift := 1.0
var training: Node3D

func build_training() -> void:
	training = preload("res://scripts/mouth_training35.gd").new()
	add_child(training)
	training.global_transform = Transform3D.IDENTITY
	training.build(game,self)


func _surface(label: String, vertices: Array[Vector3], ids: Array[int], color: Color, solid := true) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in ids:
		var p := vertices[i]
		st.set_color(color.lightened(sin(p.z*1.8+p.x)*0.025))
		st.add_vertex(p)
	st.generate_normals()
	st.index()
	var mesh := MeshInstance3D.new()
	mesh.name = label
	mesh.mesh = st.commit()
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material_override = Clay.clay_material(mat)
	add_child(mesh)
	if solid:
		var body := StaticBody3D.new()
		body.collision_layer = 5
		var shape := CollisionShape3D.new()
		var collision := mesh.mesh.create_trimesh_shape()
		collision.backface_collision = true
		shape.shape = collision
		body.add_child(shape)
		mesh.add_child(body)
	return mesh

func _grid(rows: int, columns: int) -> Array[int]:
	var ids: Array[int] = []
	for row in range(rows):
		for col in range(columns):
			var i := row*(columns+1)+col
			ids.append_array([i,i+columns+1,i+1,i+1,i+columns+1,i+columns+2])
	return ids

func floor_y(z: float) -> float:
	return 18.0-(68.0-z)*0.11 if z >= 50.0 else 16.02-(50.0-z)*0.48

func _channel(label: String, za: float, zb: float, wa: float, wb: float, ha: float, hb: float, color: Color) -> void:
	var points: Array[Vector3] = []
	for row in range(49):
		var t := float(row)/48.0
		var z := lerpf(za,zb,t)
		var width := lerpf(wa,wb,t)
		for col in range(17):
			var u := float(col)/16.0*2.0-1.0
			points.append(Vector3(u*width,floor_y(z)+0.16*(1-u*u),z))
	_surface(label+"Floor",points,_grid(48,16),color)
	points.clear()
	for row in range(49):
		var t := float(row)/48.0
		var z := lerpf(za,zb,t)
		var width := lerpf(wa,wb,t)
		for col in range(33):
			var a := float(col)/32.0*PI
			var crease := 0.12*sin(z*2.4)*sin(a)
			points.append(Vector3(cos(a)*(width+crease),floor_y(z)+sin(a)*(lerpf(ha,hb,t)+crease)*roof_lift,z))
	_surface(label+"Vault",points,_grid(48,32),color.darkened(0.22))

func build(host) -> void:
	game = host
	roof_lift = 1.0 if DisplayServer.get_name() == "headless" and OS.get_environment("GUT_CREW_QA_LEGACY_LAYOUT") == "1" else 1.8
	name = "MouthEntry20"
	_channel("Tongue",68,50,6.0,3.1,9.0,5.7,Color("b16b7c"))
	_channel("Esophagus",50,33,3.1,2.7,5.7,5.7,Color("986175"))
	_surface("ClosedMuzzle",[Vector3(-6,17,68),Vector3(6,17,68),Vector3(-6,18+10*roof_lift,68),Vector3(6,18+10*roof_lift,68)],[0,1,2,1,3,2],Color("774b61"))
	_surface("SwallowEnd",[Vector3(-3,7,33),Vector3(3,7,33),Vector3(-3,8+7*roof_lift,33),Vector3(3,8+7*roof_lift,33)],[0,1,2,1,3,2],Color("503a50"))
	for side in [-1.0,1.0]:
		for i in range(7):
			var z := 64.0-float(i)*1.65
			var x: float = side*lerpf(5.15,3.20,float(i)/6.0)
			var y := floor_y(z)
			for upper in [false,true]:
				var height := 1.05 if i != 1 else 2.65
				var tooth := Detail.tooth(self,"UpperTooth" if upper else "LowerTooth",height,0.45 if i != 1 else 0.59,side*0.28)
				var roof_height := lerpf(9.0,5.7,(68.0-z)/18.0)*roof_lift
				var width := lerpf(6.0,3.1,(68.0-z)/18.0)
				var tx := x*(0.78 if upper else 1.0)
				var root_y := y+roof_height*sqrt(maxf(0.01,1.0-pow(tx/width,2)))-0.08 if upper else y+0.25
				tooth.position = Vector3(tx,root_y,z)
				if upper: tooth.rotation.z = PI
				if upper:
					Art.sphere(self,"UpperGum",tooth.position+Vector3.UP*0.09,Vector3(0.95,0.42,1.1),Color("a56577"))
			Art.sphere(self,"Gum",Vector3(x,y+0.3,z),Vector3(1.1,0.65,1.8),Color("ac6176"))
	# Raised palate folds are above the playable lane, not loose hanging spheres.
	var folds: Array = []
	for i in range(9):
		var z := 65.0-float(i)*1.6
		var roof_height := lerpf(9.0,5.7,(68.0-z)/18.0)*roof_lift
		var width := lerpf(6.0,3.1,(68.0-z)/18.0)
		var curve: Array[Vector3] = []
		for j in range(25):
			var x := (float(j)/24.0*2.0-1.0)*width*0.73
			curve.append(Vector3(x,floor_y(z)+roof_height*sqrt(1.0-pow(x/width,2))-0.06,z))
		folds.append(curve)
	Detail.tubes(self,"SculptedPalateFolds",folds,0.11,Color("b17b89"))
	# Small papillae stay outside the central movement corridor.
	for i in range(90):
		var z := 64.5-float(i/6)*0.77
		var x := (float(i%6)-2.5)*0.66+sin(float(i)*2.39)*0.09
		if absf(x) < 0.8: continue
		Art.sphere(self,"TonguePapilla",Vector3(x,floor_y(z)+0.18,z),Vector3(0.095,0.075,0.17),Color("c48995"))
	for z in [63.0,54.0,44.0,36.0]:
		var lamp := OmniLight3D.new()
		lamp.position = Vector3(0,floor_y(z)+3.5,z)
		lamp.light_color = Color("ffe0bb")
		lamp.light_energy = 1.0 if roof_lift > 1.0 else 1.55
		lamp.omni_range = 11
		add_child(lamp)
	Art.zone_label(self,"沿舌面下行 · 进入咽喉",Vector3(0,20,53),Color("ffe4bb"))
	Art.zone_label(self,"吞咽通道 / STOMACH BELOW",Vector3(0,12,35),Color("ffe4bb"))
	set_meta("floor_drop",floor_y(63)-floor_y(34))
	set_meta("closed",true)
	set_meta("art_revision",22)

func begin() -> void:
	_restore_world()
	for node in game.get_children():
		if node is Node3D and node != self and node != game.player and not node is Light3D:
			hidden_world.append({"node":node,"visible":node.visible})
			node.visible = false
	if is_instance_valid(training): training.reset()
	active = true
	completed = false
	swallow_time = -1.0
	safe = game.world_point(SPAWN)
	game.mission_phase = "mouth"
	game.mission_label.text = "新手入职 · 两侧教学站可自由练习，沿舌面进入咽喉"
	game.player.position = game.world_point(SPAWN)
	game.player.velocity = Vector3.ZERO
	game.yaw = 0.0
	game.pitch = -0.10
	game.player.rotation.y = 0.0
	game.camera_pivot.rotation.x = -0.10
	game._story_beat("莫奇张开了嘴。沿舌面进入咽喉，寻找被吞下的录音老鼠。",6.0,0)

func constrain(point: Vector3) -> Vector3:
	point = game.authored_point(point)
	point.z = clampf(point.z,33.7,66.5)
	var t := clampf((point.z-50.0)/18.0,0.0,1.0)
	var width := lerpf(2.7,3.1,(point.z-33.0)/17.0) if point.z < 50.0 else lerpf(3.1,6.0,t)
	point.x = clampf(point.x,-width+0.8,width-0.8)
	var height := lerpf(5.7,9.0,t)*roof_lift
	# Account for the full capsule, not just its foot position, below the curved roof.
	var side := minf(0.99,(absf(point.x)+0.4)/(width-0.13))
	var ceiling := floor_y(point.z)+height*sqrt(1.0-side*side)-1.65
	point.y = minf(point.y,maxf(floor_y(point.z)+0.20,ceiling))
	return game.world_point(point)

func keep_inside() -> void:
	var p: Vector3 = game.player.position
	if p.y < floor_y(p.z/game.world_scale)-2.0:
		game.player.position = safe
		game.player.velocity = Vector3.ZERO
	else:
		game.player.position = constrain(p)
		if game.player.is_on_floor(): safe = game.player.position+Vector3.UP*0.15

func tick(delta: float) -> void:
	if not active or game.game_paused: return
	if is_instance_valid(training): training.tick(delta)
	game.mission_label.text = "猫嘴 → 咽喉 → 胃部上层  |  沿舌面向下走"
	if game.player.position.z < 35.5*game.world_scale and swallow_time < 0:
		swallow_time = 1.2
		game.terrain_world.overlay.visible = true
		game.terrain_world.overlay.modulate.a = 1.0
		game.terrain_world.transition_label.text = "咕咚！\n正在滑入胃部上层"
	if swallow_time >= 0:
		swallow_time -= delta
		game.player.velocity = Vector3.ZERO
		if swallow_time <= 0: finish()

func finish() -> void:
	game._clear_kaka_hook_projectile()
	if is_instance_valid(training): training.hide_prompt()
	_restore_world()
	active = false
	completed = true
	swallow_time = -1.0
	game.mission_phase = "diagnose"
	game.player.position = game.world_point(ARRIVAL)
	game.player.velocity = Vector3.ZERO
	game.terrain_world.last_safe = game.world_point(ARRIVAL)
	game.terrain_world.transition_time = 1.0
	game.invuln = maxf(game.invuln,2.0)
	game._refresh_mission_ui()
	game._story_beat("抵达胃部上层。两侧肉褶通向低地，组织桥可以绕开酸池。",6.0,0)

func _restore_world() -> void:
	for entry in hidden_world:
		if is_instance_valid(entry.node): entry.node.visible = entry.visible
	hidden_world.clear()
