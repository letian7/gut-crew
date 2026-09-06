extends RefCounted
const Shell = preload("res://scripts/art18_organic_shell.gd")

static func tooth(parent: Node3D, label: String, height: float, radius: float, bend: float) -> MeshInstance3D:
	var points: Array[Vector3] = []
	var ids: Array[int] = []
	for row in range(25):
		var t := float(row)/24.0
		var r := maxf(0.012,radius*pow(1.0-t,0.72)*(1.0+0.12*sin(t*PI)))
		for col in range(25):
			var angle := float(col)/24.0*TAU
			points.append(Vector3(cos(angle)*r+bend*t*t,height*t,sin(angle)*r*0.72+0.15*t*t))
	for row in range(24):
		for col in range(24):
			var i := row*25+col
			ids.append_array([i,i+25,i+1,i+1,i+25,i+26])
	var node := Shell._mesh(parent,label,points,ids,Color("d8cbb0"))
	node.set_meta("sculpted_tooth",true)
	return node

static func tubes(parent: Node3D, label: String, curves: Array, radius: float, color: Color) -> MeshInstance3D:
	var points: Array[Vector3] = []
	var ids: Array[int] = []
	for curve in curves:
		var base := points.size()
		for row in range(curve.size()):
			var tangent: Vector3 = (curve[mini(row+1,curve.size()-1)]-curve[maxi(row-1,0)]).normalized()
			var side := tangent.cross(Vector3.UP).normalized()
			if side.length() < 0.1: side = Vector3.RIGHT
			var up := tangent.cross(side).normalized()
			var r := radius*(0.15+0.85*pow(sin(PI*float(row)/float(curve.size()-1)),0.35))
			for col in range(9):
				var a := TAU*float(col)/8.0
				points.append(curve[row]+(side*cos(a)+up*sin(a))*r)
		for row in range(curve.size()-1):
			for col in range(8):
				var i := base+row*9+col
				ids.append_array([i,i+9,i+1,i+1,i+9,i+10])
	return Shell._mesh(parent,label,points,ids,color)

static func decorate_lane(parent: Node3D, label: String, a: Vector3, b: Vector3, width: float) -> void:
	var side := Vector3.RIGHT if absf(b.z-a.z)>0.01 else Vector3.BACK
	var borders: Array = []
	var veins: Array = []
	for s in [-1.0,1.0]:
		var curve: Array[Vector3] = []
		for i in range(33):
			var t := float(i)/32.0
			var swell := 1.0+0.055*sin(t*PI)*sin(t*PI*3.0)
			curve.append(a.lerp(b,t)+side*s*width*0.5*swell-Vector3.UP*0.035)
		borders.append(curve)
	for n in range(3):
		var curve: Array[Vector3] = []
		for i in range(25):
			var t := 0.08+float(n)*0.14+float(i)/24.0*0.54
			var lateral := (float(n)-1.0)*width*0.23+sin(t*PI*2.0+float(n))*width*0.10
			curve.append(a.lerp(b,t)+side*lateral+Vector3.UP*0.09)
		veins.append(curve)
	tubes(parent,label+"SoftLip",borders,0.12,Color("b7838d"))
	var grain := tubes(parent,label+"TissueGrain",veins,0.048,Color("b48a98"))
	grain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
