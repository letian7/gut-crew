extends SceneTree
func _init():
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0)
	game.set_process(false)
	game.set_physics_process(false)
	print("BEFORE_BOUNDARY ",game.mouth_intro.constrain(Vector3(5,100,51)))
	game._story_beat("PRESERVE_THIS_STORY",5.0,0)
	game._select_role(1)
	print("AFTER_ROLE_SWITCH ",game.story_label.text)
	game.mouth_intro.finish()
	game.mission_phase = "return"
	game._begin_host_boss()
	for n in game.host_boss.cat.find_children("*","Node3D",true,false):
		if "Tail" in String(n.name): print("TAIL_NODE ",n.get_path())
	game.interact_label.text = "STALE_TOY_PROMPT"
	game.host_boss.state = "recover"
	game.host_boss.apply_hit(10000,0,0)
	print("ENDING_PROMPT ",game.interact_label.text)
	quit()
