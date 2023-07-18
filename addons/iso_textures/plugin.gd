@tool
extends EditorPlugin

func _enter_tree():
	_fix_isos_in_directory("res://isos")

func _fix_iso(iso_path: String):
	var iso = load(iso_path)
	var scene = iso.scene.instantiate()
	if scene is Sprite2D:
		iso.texture = scene.texture
		ResourceSaver.save(iso, iso_path)
	scene.queue_free()

func _fix_isos_in_directory(dir_path: String):
	var dir = DirAccess.open(dir_path)
	if !dir:
		print("Error: Unable to open the directory.")
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".tres"):
			_fix_iso(dir_path + "/" + file_name)
		elif not file_name.begins_with("."):  # Ignore hidden files and directories
			var sub_dir_path = dir_path + "/" + file_name
			if dir.current_is_dir():
				_fix_isos_in_directory(sub_dir_path)
		file_name = dir.get_next()

	dir.list_dir_end()