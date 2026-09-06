extends RefCounted

const SCHEMA_VERSION := 1

static func _v3(v: Vector3) -> Array:
	return [snappedf(v.x,0.001),snappedf(v.y,0.001),snappedf(v.z,0.001)]

static func snapshot(game: Node) -> Dictionary:
	var player := game.get("player") as CharacterBody3D
	var mouse := game.get("mouse_target") as CharacterBody3D
	var player_state := {
		"role": int(game.get("role_index")),
		"position": _v3(player.global_position),
		"velocity": _v3(player.velocity),
		"hp": snappedf(float(game.get("hp")),0.01),
		"q_cd": snappedf(float(game.get("skill_q_cd")),0.01),
		"e_cd": snappedf(float(game.get("skill_e_cd")),0.01),
		"dodge": snappedf(float(game.get("dodge_time")),0.01)
	}
	var mouse_state := {"active": is_instance_valid(mouse)}
	if is_instance_valid(mouse):
		mouse_state["position"] = _v3(mouse.global_position)
		mouse_state["stun"] = snappedf(float(mouse.get_meta("stun",0.0)),0.01)
		mouse_state["pinned"] = snappedf(float(mouse.get_meta("pinned",0.0)),0.01)
	return {
		"schema": SCHEMA_VERSION,
		"player": player_state,
		"mission": {"phase": String(game.get("mission_phase")),"clues": int(game.call("_clue_count")),"caught": bool(game.get("mouse_caught"))},
		"body": {"acid": snappedf(float(game.get("acid_tide_time")),0.01),"spasm": snappedf(float(game.get("spasm_time")),0.01),"drink": snappedf(float(game.get("drink_time")),0.01)},
		"mouse": mouse_state,
		"economy": {"credits": int(game.get("credits")),"purchases": int(game.get("purchases")),"umbrella": snappedf(float(game.get("acid_umbrella_time")),0.01),"soda": snappedf(float(game.get("plasma_soda_time")),0.01),"catnip": snappedf(float(game.get("catnip_time")),0.01)},
		"clinic": game.clinic_system.snapshot() if is_instance_valid(game.get("clinic_system")) else {},
		"stats": {"kos": int(game.get("defeats")),"sync": int(game.get("synergies")),"best": int(game.get("combo_best"))}
	}

static func validate(data: Dictionary) -> bool:
	if int(data.get("schema",-1)) != SCHEMA_VERSION: return false
	if not data.has("player") or not data.has("mission") or not data.has("body"): return false
	var p: Dictionary = data["player"]
	return p.has("role") and p.has("position") and p.has("hp")

static func lerp_position(a: Array, b: Array, t: float) -> Vector3:
	var av := Vector3(float(a[0]),float(a[1]),float(a[2]))
	var bv := Vector3(float(b[0]),float(b[1]),float(b[2]))
	return av.lerp(bv,clampf(t,0.0,1.0))

# GODOT_NETWORK_STATE_V1

# GODOT_PHASE8_ECONOMY_STATE
