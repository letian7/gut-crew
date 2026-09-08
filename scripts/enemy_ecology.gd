extends Node
## Phase 31: specialist wild-enemy combat and anatomical ecology dressing.
const EnemyFactory = preload("res://scripts/enemy_factory.gd")
const SkillVFX = preload("res://scripts/skill_vfx.gd")
const MODE_BY_KIND := {
	"RAMMER":"charge",
	"SPITTER":"ranged",
	"SPLITTER":"split",
	"SPLIT_LARVA":"swarm"
}
const DISPLAY_BY_KIND := {
	"RAMMER":"撞角菌",
	"SPITTER":"酸囊喷射虫",
	"SPLITTER":"分裂黏团",
	"SPLIT_LARVA":"黏团幼体"
}
var game
var projectiles: Array[Dictionary] = []
var pending_splits: Array[Dictionary] = []
var dressing_props: Array[Node3D] = []
var ranged_shots := 0
var charge_starts := 0
var split_events := 0
var projectile_hits := 0
var ecology_parts := 0

func build(host) -> void:
	game = host
	name = "WildEnemyEcology31"
	for enemy in game.enemies: configure_enemy(enemy)
	_build_dressing()
	set_meta("attack_modes", ["melee","charge","ranged","split","swarm"])
	set_meta("specialist_count", _specialist_count())
func configure_enemy(enemy: CharacterBody3D) -> void:
	var kind := String(enemy.get_meta("kind",""))
	var mode := String(MODE_BY_KIND.get(kind,"melee"))
	enemy.set_meta("attack_mode",mode)
	enemy.set_meta("special_state","idle")
	enemy.set_meta("special_time",0.0)
	enemy.set_meta("special_cd",0.45+fmod(float(enemy.get_instance_id()),1.35))
	enemy.set_meta("special_hit",false)
	enemy.set_meta("charge_dir",Vector3.ZERO)
	enemy.set_meta("split_generation",1 if kind=="SPLIT_LARVA" else 0)
	if DISPLAY_BY_KIND.has(kind): enemy.set_meta("display_name",DISPLAY_BY_KIND[kind])
	if mode in ["charge","ranged"]: enemy.set_meta("aggro_radius",21.0)
	elif mode in ["split","swarm"]: enemy.set_meta("aggro_radius",15.0)

func _specialist_count() -> int:
	var count := 0
	for enemy in game.enemies:
		if String(enemy.get_meta("attack_mode","melee"))!="melee": count += 1
	return count

func _prop(name_: String, authored_pos: Vector3) -> Node3D:
	var root := Node3D.new()
	root.name = name_
	root.position = authored_pos
	game.add_child(root)
	dressing_props.append(root)
	return root
func _build_dressing() -> void:
	var nest_points := [
		Vector3(-16,0.10,6),Vector3(-11,0.14,-4),Vector3(-5,0.08,7),
		Vector3(3,0.12,6),Vector3(9,0.10,-5),Vector3(15,0.10,6),
		Vector3(-14,0.12,-10),Vector3(-6,0.10,-12),Vector3(5,0.12,-11),
		Vector3(13,0.12,-9),Vector3(-2,0.10,1),Vector3(18,0.10,1)]
	for i in range(nest_points.size()):
		var nest := _prop("MucusNest31_%02d"%i,nest_points[i])
		EnemyFactory.sphere(nest,"NestBed",Vector3.ZERO,Vector3(0.72,0.18,0.62),Color("#9d5579"),0.94,0.15)
		for j in range(4):
			var angle := TAU*float(j)/4.0+float(i)*0.37
			var color := Color("#f19bb5") if (i+j)%2==0 else Color("#bd83d7")
			EnemyFactory.sphere(nest,"SoftEgg",Vector3(cos(angle)*0.38,0.18,sin(angle)*0.31),Vector3(0.18,0.24,0.18),color,0.90,0.35)
			ecology_parts += 1
		ecology_parts += 1
	var vent_points := [
		Vector3(-19,0.12,-2),Vector3(-13,0.12,2),Vector3(-8,0.12,-7),
		Vector3(-2,0.12,-9),Vector3(4,0.12,-6),Vector3(10,0.12,-10),
		Vector3(16,0.12,-3),Vector3(20,0.12,5)]
	for i in range(vent_points.size()):
		var vent := _prop("AcidVent31_%02d"%i,vent_points[i])
		EnemyFactory.cylinder(vent,"VentStalk",Vector3(0,0.28,0),Vector3(0.22,0.55,0.22),Color("#7d9653"))
		EnemyFactory.torus(vent,"VentMouth",Vector3(0,0.59,0),Vector3(0.28,0.12,0.28),Color("#c4ed54"),Vector3.ZERO,1.1)
		for j in range(3): EnemyFactory.sphere(vent,"AcidPearl",Vector3(-0.24+0.24*j,0.12,0.24),Vector3.ONE*0.09,Color("#d9ff64"),0.82,1.5)
		ecology_parts += 5
	set_meta("ecology_parts",ecology_parts)
	set_meta("nest_count",nest_points.size())
	set_meta("vent_count",vent_points.size())
func tick(delta: float) -> void:
	if not is_instance_valid(game) or game.game_paused or game.inventory_open or game._cinematic_locked(): return
	_process_pending_splits()
	_tick_projectiles(delta)
	for enemy in game.enemies:
		if not is_instance_valid(enemy) or enemy.get_meta("dead",false) or enemy==game.mouse_target: continue
		var mode := String(enemy.get_meta("attack_mode","melee"))
		if mode=="melee" or mode=="split" or mode=="swarm": continue
		var cd := maxf(0.0,float(enemy.get_meta("special_cd",0.0))-delta)
		var state := String(enemy.get_meta("special_state","idle"))
		var time := maxf(0.0,float(enemy.get_meta("special_time",0.0))-delta)
		if float(enemy.get_meta("stun",0.0))>0.0 or float(enemy.get_meta("pinned",0.0))>0.0 or float(enemy.get_meta("controlled",0.0))>0.0:
			enemy.set_meta("special_state","idle")
			enemy.set_meta("special_time",0.0)
			enemy.set_meta("special_cd",maxf(cd,0.8))
			continue
		var distance: float = enemy.global_position.distance_to(game.player.global_position)
		if state=="idle" and cd<=0.0 and distance<22.0:
			if mode=="ranged" and distance>3.2:
				state="aim"
				time=0.56
				EnemyFactory.spawn_attack_telegraph(game,"SPITTER",enemy.global_position)
			elif mode=="charge" and distance>2.5:
				state="windup"
				time=0.54
				enemy.set_meta("charge_dir",_flat_dir(enemy.global_position,game.player.global_position))
				EnemyFactory.spawn_attack_telegraph(game,"RAMMER",enemy.global_position)
		elif state=="aim" and time<=0.0:
			_spawn_acid_shot(enemy)
			state="idle"
			cd=2.05
		elif state=="windup" and time<=0.0:
			state="charge"
			time=0.72
			cd=2.85
			charge_starts += 1
			enemy.set_meta("special_hit",false)
			_spawn_charge_lane(enemy)
		elif state=="charge":
			enemy.velocity = enemy.get_meta("charge_dir",Vector3.ZERO)*18.5
			if distance<1.55 and not bool(enemy.get_meta("special_hit",false)):
				enemy.set_meta("special_hit",true)
				if game.dodge_time>0.0 and game.dodge_success_lock<=0.0: _perfect_dodge("RAM EVADED")
				else: _hurt_player(enemy,18.0)
			if time<=0.0: state="idle"
		enemy.set_meta("special_cd",cd)
		enemy.set_meta("special_state",state)
		enemy.set_meta("special_time",time)
func _flat_dir(from: Vector3,to: Vector3) -> Vector3:
	var direction := to-from
	direction.y = 0.0
	return direction.normalized() if direction.length_squared()>0.001 else Vector3.FORWARD

func _spawn_charge_lane(enemy: CharacterBody3D) -> void:
	var direction: Vector3 = enemy.get_meta("charge_dir",Vector3.FORWARD)
	for i in range(7):
		var bead := EnemyFactory.sphere(game,"ChargeLane31",enemy.global_position+direction*(1.0+i*0.8)+Vector3.UP*0.10,Vector3(0.16,0.05,0.16),Color("#ffb35f"),0.62,1.8)
		var tween: Tween = game.create_tween()
		tween.tween_property(bead,"scale",Vector3.ZERO,0.70)
		tween.tween_callback(bead.queue_free)

func _spawn_acid_shot(enemy: CharacterBody3D) -> void:
	var root := Node3D.new()
	root.name = "AcidProjectile31"
	game.add_child(root)
	root.global_position = enemy.global_position+Vector3.UP*0.78
	var core := EnemyFactory.sphere(root,"AcidCore",Vector3.ZERO,Vector3.ONE*0.24,Color("#c9f443"),0.88,2.8)
	for i in range(4):
		var angle := TAU*float(i)/4.0
		EnemyFactory.sphere(root,"AcidDroplet",Vector3(cos(angle)*0.22,0,sin(angle)*0.22),Vector3.ONE*0.07,Color("#efff8a"),0.75,2.0)
	var direction := _flat_dir(root.global_position,game.player.global_position)
	projectiles.append({"node":root,"velocity":direction*10.8+Vector3.UP*0.45,"life":2.6,"damage":14.0,"trail":0.0})
	ranged_shots += 1
	EnemyFactory.spawn_attack_hit(game,"SPITTER",enemy.global_position+Vector3.UP*0.75)
func _tick_projectiles(delta: float) -> void:
	for i in range(projectiles.size()-1,-1,-1):
		var shot: Dictionary = projectiles[i]
		var node := shot.node as Node3D
		if not is_instance_valid(node):
			projectiles.remove_at(i)
			continue
		shot.life = float(shot.life)-delta
		shot.trail = float(shot.get("trail",0.0))-delta
		var velocity: Vector3 = shot.velocity
		velocity.y -= 0.7*delta
		shot.velocity = velocity
		node.global_position += velocity*delta
		node.rotation += Vector3(delta*5.0,delta*8.0,delta*3.0)
		if float(shot.trail)<=0.0:
			shot.trail=0.065
			var drop := EnemyFactory.sphere(game,"AcidTrail32",node.global_position,Vector3(0.10,0.06,0.14),Color("#dfff64"),0.58,1.8)
			var trail_tw: Tween = game.create_tween()
			trail_tw.tween_property(drop,"scale",Vector3.ZERO,0.18)
			trail_tw.tween_callback(drop.queue_free)
		if game._kaka_wall_blocks_point(node.global_position):
			game._toast("BONE WALL BLOCKED ACID",Color("#fff0d2"),0.8)
			_remove_projectile(i)
		elif node.global_position.distance_to(game.player.global_position+Vector3.UP*0.55)<0.72:
			if game.dodge_time>0.0 and game.dodge_success_lock<=0.0:
				_perfect_dodge("ACID SHOT EVADED")
			elif game.invuln<=0.0:
				var damage := float(shot.damage)*(0.35 if game.kaka_armor_time>0.0 else (0.18 if game.acid_umbrella_time>0.0 else 1.0))
				game.hp=maxf(0.0,game.hp-damage)
				game._player_hurt_feedback(damage,node.global_position,true)
				game.invuln=0.72
				projectile_hits += 1
				game._toast("酸囊命中！横移或躲闪可避开弹体",Color("#cfff61"),1.4)
			_remove_projectile(i)
		elif float(shot.life)<=0.0:
			_remove_projectile(i)
		else:
			projectiles[i]=shot

func _remove_projectile(index: int) -> void:
	var node := projectiles[index].node as Node3D
	if is_instance_valid(node):
		EnemyFactory.spawn_attack_hit(game,"SPITTER",node.global_position)
		node.queue_free()
	projectiles.remove_at(index)
func _perfect_dodge(message: String) -> void:
	game.dodge_success_lock=0.38
	game.hit_shake=maxf(game.hit_shake,0.08)
	SkillVFX.spawn_dodge_success(game,game.player.global_position,game.ROLE_COLORS[game.role_index])
	game._toast(message,game.ROLE_COLORS[game.role_index],1.0)

func _hurt_player(enemy: CharacterBody3D, amount: float) -> void:
	if game.invuln>0.0 or game.ko_time>0.0: return
	amount *= 0.35 if game.kaka_armor_time>0.0 else 1.0
	game.hp=maxf(0.0,game.hp-amount)
	game._player_hurt_feedback(amount,enemy.global_position,true)
	game.invuln=0.82
	var push := _flat_dir(enemy.global_position,game.player.global_position)
	game.player.velocity += push*10.5+Vector3.UP*2.8
	game._toast("撞角冲锋！侧闪可触发完美闪避",Color("#ffb15e"),1.4)

func on_enemy_defeated(enemy: CharacterBody3D) -> void:
	if String(enemy.get_meta("kind",""))!="SPLITTER": return
	if int(enemy.get_meta("split_generation",0))>=1: return
	pending_splits.append({"position":enemy.global_position,"territory":String(enemy.get_meta("territory",""))})
	split_events += 1

func _process_pending_splits() -> void:
	if pending_splits.is_empty(): return
	var entries := pending_splits.duplicate(true)
	pending_splits.clear()
	for entry in entries:
		var base: Vector3 = entry.position
		for side in [-1.0,1.0]:
			game._spawn_enemy("SPLIT_LARVA",base+Vector3(side*0.72,0,0),Color("#ff9fba"),34.0,4.4,true,String(entry.territory))
			var larva: CharacterBody3D = game.enemies[-1]
			configure_enemy(larva)
			larva.set_meta("special_cd",1.8)
			EnemyFactory.spawn_attack_hit(game,"SPLITTER",larva.global_position+Vector3.UP*0.35)
# GODOT_PHASE31_ENEMY_ECOLOGY
