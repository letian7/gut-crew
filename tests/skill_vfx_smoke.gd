extends SceneTree
const SkillVFX = preload("res://scripts/skill_vfx.gd")

func _validate_hit_vfx(game: Node3D) -> void:
	var keys := ["HitArc","BoneChip","VFXBurst","VFXBurst"]
	for i in range(4):
		var holder := Node3D.new()
		game.add_child(holder)
		SkillVFX.spawn_hit(holder,Vector3.ZERO,Color.WHITE,i)
		assert(holder.get_node_or_null("HitRing") != null)
		assert(holder.get_node_or_null(keys[i]) != null)
		holder.queue_free()

func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	var q_keys := ["SparkWireVFX","BoneGrowthVFX","PlasmaDrop","Spore"]
	var e_keys := ["OverloadRing","BonePinVFX","EngulfShell","FermentRing"]
	for i in range(4):
		SkillVFX.spawn_cast(game,i,0,Vector3.ZERO,Vector3.FORWARD,Vector3(0,0,-5))
		await process_frame
		assert(game.get_node_or_null(q_keys[i]) != null)
		SkillVFX.spawn_cast(game,i,1,Vector3.ZERO,Vector3.FORWARD,Vector3(0,0,-4))
		await process_frame
		assert(game.get_node_or_null(e_keys[i]) != null)
	var bone := Node3D.new(); game.add_child(bone)
	SkillVFX.decorate_bone(bone,true)
	assert(bone.get_node_or_null("BoneKnuckle") != null)
	var lane := Node3D.new(); game.add_child(lane)
	SkillVFX.decorate_lane(lane,true)
	assert(lane.get_node_or_null("FlowBead") != null)
	var fungus := Node3D.new(); game.add_child(fungus)
	SkillVFX.decorate_fungus(fungus,true)
	assert(fungus.get_node_or_null("PatchSpore") != null)
	SkillVFX.animate_zone(lane,1.2,true)
	SkillVFX.animate_zone(fungus,1.2,true)
	_validate_hit_vfx(game)
	print("GODOT_SKILL_VFX_OK")
	quit(0)
