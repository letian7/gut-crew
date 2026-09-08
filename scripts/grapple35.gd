extends RefCounted
const FX = preload("res://scripts/skill_vfx.gd")
var game
var anchor_body: Node3D
var anchor_local := Vector3.ZERO
var anchor_normal := Vector3.UP
var rope_length := 0.0
var attached_time := 0.0
var hanging := false
var maximum_range := 32.0
var reel_held := false
var reel_time := 0.0
var flight_grace := 0.0
var outbound_time := 0.0

func start_reel() -> void:
	reel_held=true
	reel_time=0.0

func end_reel(g) -> void:
	reel_held=false
	if reel_time<0.2: release(g)

func muzzle(g) -> Vector3:
	var marker: Node3D = g.first_person_viewmodel.get_node_or_null("RightClayArm/RoleTool/HookMuzzle") if is_instance_valid(g.first_person_viewmodel) else null
	if g.first_person and is_instance_valid(marker): return marker.global_position
	return g.player.global_position + Vector3.UP * 1.15 + g.player.global_basis.x * 0.48 + g._forward()*0.5

func heavy(g, enemy: Node3D) -> bool:
	return g._is_host_boss(enemy) or bool(enemy.get_meta("elite",false)) or bool(enemy.get_meta("heavy",false)) or String(enemy.get_meta("kind","")) in ["RAMMER","SPLITTER"]

func hit_center(g, enemy: Node3D) -> Vector3:
	return enemy.global_position+Vector3.UP*(2.5 if g._is_host_boss(enemy) else 0.72)

func hit_radius(g, enemy: Node3D) -> float:
	return 3.0 if g._is_host_boss(enemy) else (1.1 if heavy(g,enemy) else 0.72)

func ray(g, a: Vector3, b: Vector3, extra: Array[RID] = []) -> Dictionary:
	if a.distance_squared_to(b)<0.00001: return {}
	var query := PhysicsRayQueryParameters3D.create(a,b)
	var excluded: Array[RID] = [g.player.get_rid()]
	excluded.append_array(extra)
	query.exclude = excluded
	query.hit_from_inside = false
	return g.get_world_3d().direct_space_state.intersect_ray(query)

func launch(g) -> void:
	game=g
	clear(g)
	flight_grace=0.0
	outbound_time=0.0
	var power: float = clampf(g.kaka_hook_charge,0.12,1.0)
	var camera: Camera3D = g.camera_1p if g.first_person else g.camera_3p
	var start := muzzle(g)
	var aim_origin := camera.global_position
	var direction: Vector3 = g._aim_forward()
	maximum_range=22.0+power*18.0
	var endpoint := aim_origin+direction*maximum_range
	var target: CharacterBody3D = g.kaka_hook_target
	# Keep a narrow aim assist for small clay enemies, never choose hidden mouth enemies.
	if g.mouth_intro.active: target=null
	elif is_instance_valid(g.host_boss) and is_instance_valid(g.host_boss.target):
		var boss: CharacterBody3D=g.host_boss.target
		var center := hit_center(g,boss)
		var nearest := Geometry3D.get_closest_point_to_segment(center,aim_origin,endpoint)
		if nearest.distance_to(center)<hit_radius(g,boss): target=boss
	if is_instance_valid(target):
		var off: Vector3 = hit_center(g,target)-aim_origin
		if off.length()>maximum_range or (not g._is_host_boss(target) and direction.dot(off.normalized())<0.94): target=null
	var sight := ray(g,aim_origin,endpoint)
	if is_instance_valid(target):
		endpoint=hit_center(g,target)
		var occlusion := ray(g,aim_origin,endpoint)
		if not occlusion.is_empty() and occlusion.collider!=target and (occlusion.position as Vector3).distance_to(endpoint)>0.8:
			target=null
			endpoint=occlusion.position
	elif not sight.is_empty():
		endpoint=sight.position
		if sight.collider is CharacterBody3D and sight.collider in g.enemies: target=sight.collider
	g.kaka_hook_start=start
	g.kaka_hook_end=endpoint
	g.kaka_hook_tip=start
	g.kaka_hook_power=power
	g.kaka_hook_flight=0.0
	g.kaka_hook_victim=target
	g.kaka_hook_phase="outgoing"
	g.kaka_hook_projectile=FX.spawn_hook_projectile(g,start,power)
	FX.update_hook_projectile(g.kaka_hook_projectile,start,start,1.0,false)
	g.secondary_attack_cd=0.75+power*1.15
	g.kaka_hook_charge=0.0
	g.kaka_hook_target=null
	g._fp_action("骨钩发射",0.5)

func attach(g, point: Vector3, collider: Node3D, normal: Vector3) -> void:
	g.kaka_hook_tip=point
	g.kaka_hook_end=point
	anchor_body=collider
	anchor_local=collider.to_local(point) if is_instance_valid(collider) else point
	anchor_normal=normal
	rope_length=maxf(2.2,g.player.global_position.distance_to(point))
	hanging=point.y>g.player.global_position.y+2.2 and not is_instance_valid(g.kaka_hook_victim)
	attached_time=0.0
	g.kaka_hook_phase="attached"
	g._toast("顶部牵绳：WASD 摆荡 · 按住右键收绳 · 空格/再按右键脱钩" if hanging else "牵引自身：靠近锚点 · 空格/右键脱钩",Color("#ffdc99"),3.5)
	FX.spawn_hook_bite(g,point,g.kaka_hook_power)

func tick(g, delta: float) -> void:
	flight_grace=maxf(0.0,flight_grace-delta)
	if g.kaka_hook_phase.is_empty(): return
	if not is_instance_valid(g.kaka_hook_projectile): clear(g); return
	var origin := muzzle(g)
	if g.kaka_hook_phase=="outgoing":
		outbound_time+=delta
		if outbound_time>2.5: clear(g); return
		var old: Vector3 = g.kaka_hook_tip
		var next: Vector3 = old.move_toward(g.kaka_hook_end,(24.0+g.kaka_hook_power*16.0)*delta)
		var hit := ray(g,old,next+(next-old).normalized()*0.06)
		var victim: CharacterBody3D = g.kaka_hook_victim
		if not hit.is_empty():
			next=hit.position
			if hit.collider is CharacterBody3D and hit.collider in g.enemies:
				victim=hit.collider
			else:
				g.kaka_hook_victim=null
				attach(g,next,hit.collider,hit.normal)
		g.kaka_hook_tip=next
		g.kaka_hook_flight=clampf(g.kaka_hook_start.distance_to(next)/maxf(0.01,g.kaka_hook_start.distance_to(g.kaka_hook_end)),0.0,1.0)
		if g.kaka_hook_phase=="outgoing" and is_instance_valid(victim) and not bool(victim.get_meta("dead",false)):
			var center: Vector3 = hit_center(g,victim)
			var nearest := Geometry3D.get_closest_point_to_segment(center,old,next)
			if nearest.distance_to(center)<hit_radius(g,victim):
				g.kaka_hook_victim=victim
				g._damage_enemy(victim,7.0+g.kaka_hook_power*7.0,0.65,0.0,Vector3.ZERO,false)
				if heavy(g,victim):
					attach(g,nearest,victim,Vector3.UP)
				else:
					g.kaka_hook_phase="returning"
					FX.spawn_hook_bite(g,center,g.kaka_hook_power)
		elif g.kaka_hook_phase=="outgoing" and next.distance_to(g.kaka_hook_end)<0.04:
			clear(g)
			g._toast("骨钩落空",Color("#ddc8a8"),0.8)
	elif g.kaka_hook_phase=="returning":
		var victim: CharacterBody3D = g.kaka_hook_victim
		if not is_instance_valid(victim) or bool(victim.get_meta("dead",false)): clear(g); return
		var finish: Vector3 = g.player.global_position+g._forward()*1.35
		var motion: Vector3 = (finish-victim.global_position).limit_length((7.5+g.kaka_hook_power*10.5)*delta)
		victim.set_meta("stun",0.25)
		victim.velocity=Vector3.ZERO
		var collision := victim.move_and_collide(motion)
		g.kaka_hook_tip=victim.global_position+Vector3.UP*0.72
		if victim.global_position.distance_to(finish)<0.24:
			victim.set_meta("hooked_close",1.25)
			g._toast("拉到面前！左键骨锤追击",Color("#ffcf78"),1.2)
			clear(g)
		elif collision!=null: clear(g)
	elif g.kaka_hook_phase=="attached":
		attached_time+=delta
		if reel_held: reel_time+=delta
		if not is_instance_valid(anchor_body) or attached_time>12.0 or (is_instance_valid(g.kaka_hook_victim) and bool(g.kaka_hook_victim.get_meta("dead",false))): clear(g); return
		g.kaka_hook_tip=anchor_body.to_global(anchor_local)
		g.kaka_hook_end=g.kaka_hook_tip
		var blockage := ray(g,g.player.global_position+Vector3.UP*0.8,g.kaka_hook_tip)
		if not blockage.is_empty() and blockage.collider!=anchor_body and (blockage.position as Vector3).distance_to(g.kaka_hook_tip)>0.6: clear(g); return
	if is_instance_valid(g.kaka_hook_projectile):
		FX.update_hook_projectile(g.kaka_hook_projectile,origin,g.kaka_hook_tip,1.0,g.kaka_hook_phase!="outgoing")

func motion(g, delta: float, input: Vector3) -> void:
	if g.kaka_hook_phase!="attached":
		if flight_grace>0.0 and not g.player.is_on_floor(): g.player.velocity+=input*8.0*delta
		return
	var offset: Vector3 = g.kaka_hook_tip-(g.player.global_position+Vector3.UP*0.8)
	var distance := offset.length()
	if distance<2.0 and not hanging: clear(g); return
	if distance<0.01: return
	var direction := offset/distance
	var reel := not hanging or reel_held
	if reel: rope_length=maxf(2.0,rope_length-11.0*delta)
	var velocity: Vector3 = g.player.velocity
	# Retain tangential momentum. Only constrain outward motion when rope is taut.
	velocity+=input*14.0*delta
	if distance>=rope_length-0.1:
		var outward := velocity.dot(direction)
		if outward<0.0: velocity-=direction*outward
		velocity+=direction*minf(85.0,maxf(0.0,distance-rope_length)*32.0+18.0)*delta
	elif reel:
		velocity+=direction*34.0*delta
	g.player.velocity=velocity.limit_length(25.0)

func release(g, jump: bool = false) -> void:
	var attached: bool = g.kaka_hook_phase=="attached"
	clear(g)
	if attached:
		flight_grace=1.2
		if jump: g.player.velocity.y=maxf(g.player.velocity.y,3.5)+2.5

func clear(g) -> void:
	if is_instance_valid(g.kaka_hook_projectile): g.kaka_hook_projectile.queue_free()
	g.kaka_hook_projectile=null
	g.kaka_hook_phase=""
	g.kaka_hook_victim=null
	g.kaka_hook_flight=0.0
	anchor_body=null
	hanging=false
	reel_held=false
