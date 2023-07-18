@tool
extends EditorPlugin

func _enter_tree():
	_simplify_scenes_in_directory("res://items")

func _simplify_scene(scene_path: String):
	var scene = load(scene_path).instantiate()
	
	var sprite = scene.get_child(0)
	var new_scene = PackedScene.new()
	new_scene.pack(sprite)

	ResourceSaver.save(new_scene, scene_path)

func _simplify_scenes_in_directory(dir_path: String):
	var dir = DirAccess.open(dir_path)
	if !dir:
		print("Error: Unable to open the directory.")
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tscn"):
			_simplify_scene(dir_path + "/" + file_name)
		elif not file_name.begins_with("."):  # Ignore hidden files and directories
			var sub_dir_path = dir_path + "/" + file_name
			if dir.current_is_dir():
				_simplify_scenes_in_directory(sub_dir_path)
		file_name = dir.get_next()

	dir.list_dir_end()