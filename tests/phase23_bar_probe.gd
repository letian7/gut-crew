extends SceneTree
func _init():
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var bar = game.combat_hud.skills[0].bar
	print("BAR_BEFORE size=",bar.size," min=",bar.get_combined_minimum_size()," font=",bar.get_theme_font_size("font_size"))
	bar.size = Vector2(94,4)
	await process_frame
	print("BAR_AFTER size=",bar.size," min=",bar.get_combined_minimum_size())
	quit()
