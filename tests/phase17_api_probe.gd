extends SceneTree
func _init() -> void:
	for property in ClassDB.class_get_property_list("ConcavePolygonShape3D"):
		if "back" in String(property["name"]): print(property["name"])
	quit(0)
