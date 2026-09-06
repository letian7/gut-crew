extends Node3D
const Shell = preload("res://scripts/art18_organic_shell.gd")
const Clay = preload("res://scripts/art18_character.gd")
const Detail = preload("res://scripts/art22_detail.gd")
const LEFT_TOP := Vector3(-3,4.6,11)
const RIGHT_TOP := Vector3(3,4.6,11)
const LEFT_FOOT := Vector3(-8.2,1.125,3.8)
const RIGHT_FOOT := Vector3(7.7,1.275,4.0)
const BRIDGE_Y := 2.65

func _lane(label: String, a: Vector3, b: Vector3, width: float, color: Color) -> void:
	# Shared z-plane seams prevent a horizontal landing from overhanging a slope.
	var side := Vector3.RIGHT if absf(b.z-a.z)>0.01 else Vector3.BACK
	var points: Array[Vector3] = []
	var ids: Array[int] = []
	for row in range(25):
		var t := float(row)/24.0
		for col in range(9):
			var u := float(col)/8.0
			var swell := 1.0+0.055*sin(t*PI)*sin(t*PI*3.0)
			points.append(a.lerp(b,t)+side*(u-0.5)*width*swell+Vector3.UP*0.035*sin(t*PI)*sin(u*PI))
	for row in range(24):
		for col in range(8):
			var i := row*9+col
			ids.append_array([i,i+9,i+1,i+1,i+9,i+10])
	var mesh := Shell._mesh(self,label,points,ids,color)
	var body := StaticBody3D.new()
	body.collision_layer = 5
	var shape := CollisionShape3D.new()
	var trimesh := mesh.mesh.create_trimesh_shape()
	trimesh.backface_collision = true
	shape.shape = trimesh
	body.add_child(shape)
	mesh.add_child(body)
	# Curved underside and scalloped edges share the exact walkable rim.
	var flesh: Array[Vector3] = []
	for row in range(25):
		var t := float(row)/24.0
		var swell := 1.0+0.055*sin(t*PI)*sin(t*PI*3.0)
		for col in range(9):
			var angle := float(col)/8.0*PI
			flesh.append(a.lerp(b,t)+side*cos(angle)*width*0.5*swell-Vector3.UP*sin(angle)*0.85)
	var underside := Shell._mesh(self,label+"FleshUnderside",flesh,ids,color.darkened(0.12))
	# Camera-only hull: the visible flesh must not cut through the spring-arm camera.
	var camera_hull := StaticBody3D.new()
	camera_hull.name = "CameraHull"
	camera_hull.collision_layer = 2
	camera_hull.collision_mask = 0
	var camera_shape := CollisionShape3D.new()
	var shell_shape := underside.mesh.create_trimesh_shape()
	shell_shape.backface_collision = true
	camera_shape.shape = shell_shape
	camera_hull.add_child(camera_shape)
	underside.add_child(camera_hull)
	Detail.decorate_lane(self,label,a,b,width)

func build() -> void:
	name = "VerticalStomach20"
	_lane("UpperLanding",Vector3(0,4.6,14.0),Vector3(0,4.6,11.0),8.5,Color("b48a84"))
	for s in [-1.0,1.0]:
		var label := "Left" if s < 0 else "Right"
		var foot := LEFT_FOOT if s < 0 else RIGHT_FOOT
		_lane(label+"UpperFold",Vector3(s*3,4.6,11),Vector3(s*7,BRIDGE_Y,7.8),3.0,Color("ab7b83"))
		_lane(label+"BridgeLanding",Vector3(s*7,BRIDGE_Y,7.8),Vector3(s*7,BRIDGE_Y,5.9),3.8,Color("ba8d8c"))
		_lane(label+"LowerFold",Vector3(s*7,BRIDGE_Y,5.9),foot,2.7,Color("a77986"))
		var edge := Vector3(foot.x,foot.y,2.4 if s < 0 else 2.75)
		_lane(label+"LowlandRamp",edge,Vector3(foot.x,-0.02,0),2.3,Color("a67e88"))
	_lane("AcidOverpass",Vector3(-7,BRIDGE_Y,7),Vector3(7,BRIDGE_Y,7),1.5,Color("c09686"))
	set_meta("levels",[0.03,BRIDGE_Y,4.6])
	set_meta("walkable",true)
	set_meta("art_revision",22)
