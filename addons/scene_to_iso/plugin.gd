@tool
extends EditorPlugin

func _enter_tree():
	_create_isos_from_directory("res://items")

func _create_iso_from_png(scene_path: String):
	var config = ConfigFile.new()
	config.load("res://id_mappings.ini")

	var iso = IsoDefinition.new()
	iso.scene = load(scene_path)
	iso.disallow_drag = true

	# Save the iso with the same name as the scene file but in isos folders
	var base_name = scene_path.get_file().get_basename()
	var iso_id = 0
	for key in config.get_section_keys("isos"):
		if config.get_value("isos", key) == base_name:
			iso_id = key
			break

	var iso_path = "res://isos/" + iso_id + "_" + base_name + ".tres"
	print(iso_path)
	ResourceSaver.save(iso, iso_path)

func _create_isos_from_directory(dir_path: String):
	var dir = DirAccess.open(dir_path)
	if !dir:
		print("Error: Unable to open the directory.")
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tscn"):
			_create_iso_from_png(dir_path + "/" + file_name)
		elif not file_name.begins_with("."):  # Ignore hidden files and directories
			var sub_dir_path = dir_path + "/" + file_name
			if dir.current_is_dir():
				_create_isos_from_directory(sub_dir_path)
		file_name = dir.get_next()

	dir.list_dir_end()