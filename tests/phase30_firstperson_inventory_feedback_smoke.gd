extends SceneTree
var game

func _init() -> void:
	create_timer(45).timeout.connect(func(): printerr("PHASE30_TIMEOUT"); quit(1))
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await physics_frame
	game._select_role(0, false)
	game.set_process(false)
	game.set_physics_process(false)
	game.story_label.visible = false

	# Formal gameplay begins in first-person with a visible clay viewmodel.
	assert(game.first_person)
	assert(game.camera_1p.current)
	assert(not game.camera_3p.current)
	assert(not game.character_visual.visible)
	assert(game.camera_1p.near <= 0.03)
	var rig: Node3D = game.first_person_viewmodel
	assert(is_instance_valid(rig))
	assert(rig.name == "FirstPersonClayRig30")
	assert(rig.get_node_or_null("LeftClayArm/ClaySleeve") != null)
	assert(rig.get_node_or_null("RightClayArm/GlovedHand") != null)
	assert(rig.find_children("SparkCoil", "MeshInstance3D", true, false).size() == 1)
	# Every fixed profession receives a distinct first-person tool model.
	var tools := ["SparkCoil", "BoneDriver", "PlasmaNozzle", "SporeCap"]
	for i in range(4):
		game._set_role(i)
		await process_frame
		assert(rig.role == i)
		assert(rig.find_children(tools[i], "MeshInstance3D", true, false).size() == 1)
	game._set_role(0)
	game.role_selected = true
	rig.refresh_visibility()
	assert(rig.visible)
	game._toggle_view()
	assert(not game.first_person and game.camera_3p.current)
	assert(game.character_visual.visible and not rig.visible)
	game._toggle_view()
	assert(game.first_person and game.camera_1p.current)
	assert(game.help_label.text.contains("Tab inventory"))
	assert(game.help_label.text.contains("V view"))

	# Tab inventory is modal, summarizes live resources and can safely close.
	var inventory = game.inventory_ui
	assert(is_instance_valid(inventory))
	inventory.open_inventory()
	assert(inventory.visible and game.inventory_open)
	assert(inventory.opened_count == 1)
	assert(inventory.summary.text.contains("BIOCOINS"))
	assert(inventory.catalog.text.contains("ACID UMBRELLA"))
	assert(inventory.catalog.text.contains("MYSTERY CAPSULE"))
	assert(inventory.upgrades.text.contains("闪仔"))
	assert(inventory.treasure.text.contains("空袋"))
	inventory.close_inventory()
	assert(not inventory.visible and not game.inventory_open)

	# Damage amount now drives trauma, first-person recoil and the red impact state.
	game.damage_shake = 0.0
	game.anim_hurt_time = 0.0
	game.impact_feedback.hurt_time = 0.0
	game._player_hurt_feedback(24.0, game.player.global_position + Vector3.RIGHT, true)
	assert(game.damage_shake >= 0.80)
	assert(game.anim_hurt_time > 0.30)
	assert(game.impact_feedback.hurt_time > 0.60)
	assert(game.impact_feedback.hurt_strength >= 0.99)
	assert(game.impact_feedback.directional)
	game.living_time = 1.37
	game._tick_camera_trauma(0.01)
	assert(absf(game.camera_pivot.position.x) > 0.001 or absf(game.camera_pivot.rotation.z) > 0.001)
	game.hp = 30.0
	game.impact_feedback.tick(0.01)
	assert(game.impact_feedback.hurt_events >= 1)

	print("GODOT_PHASE30_FIRSTPERSON_INVENTORY_FEEDBACK_OK default=first_person tools=4 inventory=tab trauma=scaled red_edges=active")
	game.queue_free()
	await process_frame
	quit()
