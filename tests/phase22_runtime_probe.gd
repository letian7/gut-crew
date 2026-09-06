extends SceneTree
var game
func sample(label: String) -> void:
	var start := Time.get_ticks_msec()
	var frames := 0
	while Time.get_ticks_msec()-start < 2500:
		await process_frame
		frames += 1
	print("PHASE22_GPU_SAMPLE ",label," fps=",snappedf(float(frames)*1000.0/float(Time.get_ticks_msec()-start),0.1)," draw_calls=",Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
func _init() -> void:
	create_timer(25).timeout.connect(func():printerr("PHASE22_GPU_TIMEOUT");quit(1))
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._select_role(0)
	await sample("mouth")
	game.mouth_intro.finish()
	await sample("upper_stomach")
	game.mission_phase = "return"
	game._begin_host_boss()
	await sample("boss")
	print("GODOT_PHASE22_RUNTIME_GPU_OK")
	quit()
