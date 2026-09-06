extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	game._set_role(0)
	game.living_time = 0.25
	game.player.velocity = Vector3(5, 0, 0)
	game._animate_role_model(0.0)
	assert(absf(game.character_visual.get_node("SparkArmL").rotation.x) > 0.05)
	game.anim_cast_time = 0.21
	game.anim_cast_slot = 0
	game._animate_role_model(0.0)
	assert(absf(game.character_visual.get_node("SparkArmL").rotation.x) > 0.8)
	game.dodge_time = 0.14
	game._animate_role_model(0.0)
	assert(absf(game.character_visual.rotation.z) > 2.0)
	game.dodge_time = 0.0
	game.anim_cast_time = 0.0
	game.anim_hurt_time = 0.2
	game._animate_role_model(0.0)
	assert(game.character_visual.scale.y < game.character_visual.scale.x)
	game._set_role(2)
	game.anim_hurt_time = 0.0
	game.anim_cast_time = 0.21
	game.anim_cast_slot = 1
	game._animate_role_model(0.0)
	assert(game.character_visual.scale.x > game.ROLE_VISUAL_SCALES[2] * 1.10)
	print("GODOT_CHARACTER_ANIMATION_OK")
	quit(0)
