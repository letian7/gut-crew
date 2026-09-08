extends SceneTree
const Art = preload("res://scripts/clay_art.gd")
func _init() -> void:
	var stage := Node3D.new()
	root.add_child(stage)
	await process_frame
	create_timer(15.0).timeout.connect(func(): printerr("PHASE34_TIMEOUT"); quit(1))
	var hook := Art.hook(stage,"Hook",Vector3.ZERO,0.3)
	assert(hook.mesh is ArrayMesh)
	var data := hook.mesh.surface_get_arrays(0)
	assert(data[Mesh.ARRAY_VERTEX].size()>300)
	assert(data[Mesh.ARRAY_VERTEX].size()==data[Mesh.ARRAY_NORMAL].size())
	for normal in data[Mesh.ARRAY_NORMAL]: assert(absf(normal.length()-1.0)<0.01)
	Art.debris(stage,Vector3(0,2,0),3.0)
	var cloud := stage.get_node("PhysicalBoneDebris34")
	assert(cloud.get_child_count()==16)
	var fragment := cloud.get_child(0) as RigidBody3D
	var start := fragment.position
	await create_timer(0.25).timeout
	assert(fragment.position.distance_to(start)>0.1)
	assert(fragment.collision_mask==1 and fragment.collision_layer==0)
	await create_timer(2.4).timeout
	assert(not is_instance_valid(cloud))
	stage.queue_free()
	await process_frame
	print("GODOT_PHASE34_ART_OK curved_mesh=normals_valid debris=16+motion+cleanup")
	quit()
