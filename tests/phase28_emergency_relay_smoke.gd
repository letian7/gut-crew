extends SceneTree
var game
var clinic

func scan_as(role: int, index: int) -> void:
	game._set_role(role)
	game.player.position = clinic.sites[index].root.global_position+Vector3(0,0,3)
	clinic.last_held = false
	clinic.handle_interaction(0.6,true)
	clinic.handle_interaction(0.01,false)

func clean_all(index: int) -> void:
	for cell in clinic.sites[index].cells:
		clinic.clean_at(index,cell.mesh.global_position,0.2,2.0)
	assert(clinic.sites[index].stage=="care")

func _init() -> void:
	create_timer(40).timeout.connect(func(): printerr("PHASE28_TIMEOUT"); quit(1))
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await physics_frame
	game._select_role(0,false)
	game.set_process(false)
	game.set_physics_process(false)
	game.story_label.visible = false
	clinic = game.clinic_system
	clinic.set_process(false)
	assert(clinic.name=="ClinicAndSalvage28")
	assert(clinic.care_score==0 and clinic.best_combo==0 and clinic.sterile_bursts==0)
	# Full specialist relay: Spark diagnosis -> Bubble sterilize -> Kaka cargo.
	scan_as(0,0)
	assert(clinic.sites[0].stage=="clean")
	assert(clinic.sites[0].scan_specialist and clinic.care_score==8)
	game._set_role(2)
	var before: int = game.credits
	clean_all(0)
	assert(clinic.clean_cells==20 and game.credits==before+20)
	assert(clinic.sites[0].clean_specialist)
	assert(clinic.sterile_bursts>=5,"Bubble did not trigger sterile bursts")
	assert(clinic.care_score>28 and clinic.best_combo>=20)
	game._set_role(1)
	assert(clinic.pickup_cargo(0))
	assert(clinic.sites[0].care_specialist)
	clinic.sites[0].package.visible = false
	clinic.complete_site(0)
	assert(clinic.sites[0].grade=="S" and clinic.last_grade=="S")
	assert(game.credits==before+68,"S grade reward mismatch")
	assert(clinic.grade_flash>0.0)
	var paid: int = game.credits
	clinic.complete_site(0)
	assert(game.credits==paid,"Repeated grade farmed credits")

	# A mistimed pulse breaks combo and downgrades an otherwise specialist rescue.
	var site: Dictionary = clinic.sites[1]
	site.stage = "care"
	site.started = clinic.clock
	site.scan_specialist = true
	site.clean_specialist = true
	game._set_role(3)
	clinic.care_combo = 7
	clinic.clock = 0.0
	assert(not clinic.care_press(1))
	assert(clinic.care_combo==0 and clinic.care_misses==1 and site.misses==1)
	for i in range(3):
		clinic.clock = (float(i)+0.5)/0.58
		assert(clinic.care_press(1))
	assert(site.stage=="healthy" and site.care_specialist)
	assert(site.grade=="A" and clinic.last_grade=="A")
	assert(clinic.perfect_actions==3)

	# Wrong roles remain viable, but receive the basic B response grade.
	var weak: Dictionary = clinic.sites[2]
	weak.stage = "care"
	weak.started = clinic.clock
	weak.hits = 3
	weak.package.visible = false
	var before_b: int = game.credits
	clinic.complete_site(2)
	assert(weak.grade=="B" and game.credits==before_b+34)

	var snap: Dictionary = clinic.snapshot()
	assert(snap.care_score==clinic.care_score)
	assert(snap.best_combo==clinic.best_combo)
	assert(snap.sterile_bursts==clinic.sterile_bursts)
	assert(snap.patients[0].grade=="S" and snap.patients[1].grade=="A")
	assert(snap.patients[0].relay==[true,true,true])
	var network: Dictionary = game.NetworkState.snapshot(game)
	var parsed: Dictionary = JSON.parse_string(JSON.stringify(network))
	assert(game.NetworkState.validate(parsed))
	assert(parsed.clinic.last_grade=="B" and parsed.clinic.care_score>0)
	print("GODOT_PHASE28_EMERGENCY_RELAY_OK grades=SAB specialist=3 sterile_bursts=%d score=%d best_combo=%d snapshot=json" % [clinic.sterile_bursts,clinic.care_score,clinic.best_combo])
	game.queue_free()
	await process_frame
	quit()
