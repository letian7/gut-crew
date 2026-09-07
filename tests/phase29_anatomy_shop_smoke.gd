extends SceneTree
const Shop = preload("res://scripts/shop_factory.gd")
var game
var route

func _init() -> void:
	create_timer(45).timeout.connect(func(): printerr("PHASE29_TIMEOUT"); quit(1))
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await physics_frame
	game._select_role(0,false)
	game.set_process(false)
	game.set_physics_process(false)
	game.story_label.visible = false
	route = game.anatomy_route
	route.set_process(false)
	assert(is_instance_valid(route) and route.get_meta("linear_route"))
	assert(route.get_meta("chapter_count")==3)
	assert(route.get_meta("anatomy_order")==["mouth","pharynx","esophagus","cardia","gastric_body","pyloric_antrum","duodenum","colon_exit"])
	assert(route.gates.size()==2)
	assert(game.terrain_world.ROOMS[1].title.begins_with("十二指肠"))
	assert(game.terrain_world.ROOMS[2].title.begins_with("贲门"))
	assert(game.terrain_world.ROOMS[3].title.begins_with("幽门窦"))

	# Anatomical dressing replaces visibly incorrect lung/synapse imagery.
	assert(route.find_children("GastricRuga*","MeshInstance3D",true,false).size()==14)
	assert(route.find_children("GastricPit29*","MeshInstance3D",true,false).size()==36)
	assert(route.find_children("DuodenalVillus*","MeshInstance3D",true,false).size()==28)
	assert(route.find_children("BileRidge*","MeshInstance3D",true,false).size()==6)
	assert(route.get_node_or_null("CardiaMuscleRing")!=null)
	assert(route.get_node_or_null("PylorusMuscleRing")!=null)
	for node in game.find_children("Alveolus*","MeshInstance3D",true,false):
		assert(not node.visible)
	for node in game.find_children("SynapseNode*","MeshInstance3D",true,false):
		assert(not node.visible)

	# Clues occupy the real digestive sequence, and later stages cannot be diagnosed early.
	var authored0: Vector3 = game.authored_point(game.clue_nodes[0].global_position)
	var authored1: Vector3 = game.authored_point(game.clue_nodes[1].global_position)
	var authored2: Vector3 = game.authored_point(game.clue_nodes[2].global_position)
	assert(authored0.distance_to(Vector3(-18,0.55,8.8))<0.1)
	assert(authored1.distance_to(Vector3(0,0.50,-11.2))<0.1)
	assert(authored2.distance_to(Vector3(18,0.55,-8.7))<0.1)
	assert(route.can_use_clue(0) and not route.can_use_clue(1))
	game.player.global_position = game.clue_nodes[1].global_position
	game.interact_down = true
	game._update_mission(1.0)
	assert(not game.clue_done[1],"Later chapter bypassed the sphincter gate")
	game.interact_down = false
	game._update_mission(0.01)

	# Each completed chapter opens exactly the next biological gate.
	assert(not route.gates[0].open and not route.gates[1].open)
	game._complete_clue(0)
	route.refresh()
	await process_frame
	assert(route.gates[0].open and not route.gates[1].open)
	assert(route.can_use_clue(1) and game.clue_nodes[1].visible)
	assert(route.gates[0].collision.disabled)
	game._complete_clue(1)
	route.refresh()
	await process_frame
	assert(route.gates[1].open and route.can_use_clue(2))
	assert(route.gates[1].collision.disabled)
	game._complete_clue(2)
	route.refresh()
	assert(game.mission_phase=="chase")
	assert(route.route_label.text.contains("诊断完成"))
	var mouse_authored: Vector3 = game.authored_point(game.mouse_target.global_position)
	assert(mouse_authored.distance_to(Vector3(18,0.55,-8.7))<0.1)

	# BODY MART is now a walk-in shop with a physical shell and animated bacterium.
	var shop: Node3D = game.shop_root
	assert(shop.get_node_or_null("ShopFloor")!=null)
	assert(shop.get_node_or_null("BackWall") is StaticBody3D)
	assert(shop.get_node_or_null("LeftWall") is StaticBody3D)
	assert(shop.get_node_or_null("RightWall") is StaticBody3D)
	assert(shop.get_node_or_null("ShopCounter") is StaticBody3D)
	var merchant: Node3D = shop.get_node_or_null("BacteriaMerchant")
	assert(is_instance_valid(merchant))
	assert(merchant.get_node_or_null("BacteriaBody")!=null)
	assert(merchant.find_children("Eye*","MeshInstance3D",false,false).size()==2)
	assert(merchant.get_node_or_null("MerchantTalk") is Label3D)
	var old_y: float = merchant.position.y
	Shop.animate(shop,1.5)
	assert(not is_equal_approx(merchant.position.y,old_y))
	assert(Shop.ITEM_DESCRIPTIONS.size()==4)
	for i in range(4):
		var label: Label3D = game.shop_pads[i].get_node("ItemLabel")
		assert(label.text.contains(Shop.ITEM_DISPLAY_NAMES[i]))
		assert(label.text.contains(Shop.ITEM_DESCRIPTIONS[i]))
	# Product proximity shows effect and price before the hold purchase.
	game.mission_phase = "diagnose"
	game.player.global_position = game.shop_pads[0].global_position
	game.interact_down = false
	game._update_mission(0.01)
	assert(game.interact_label.text.contains("胃酸伞"))
	assert(game.interact_label.text.contains("18秒抗胃酸"))
	var before: int = game.credits
	game.credits = 0
	game.interact_down = true
	game._update_mission(0.4)
	assert(game.purchases==0 and game.credits==0)
	game.credits = before

	print("GODOT_PHASE29_ANATOMY_SHOP_OK route=3 gates=2 rugae=14 pits=36 villi=28 shop=walk_in merchant=bacteria descriptions=4")
	game.queue_free()
	await process_frame
	quit()
