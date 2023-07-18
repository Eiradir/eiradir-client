@tool
extends EditorPlugin

func _enter_tree():
	_create_scenes_from_directory("res://items")

func _create_scene_from_png(png_path: String):
	var scene = PackedScene.new()
	
	# Create Node2D with Y-sort enabled
	var node = Node2D.new()
	node.y_sort_enabled = true
	
	# Create Sprite2D with Y-sort enabled
	var sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.y_sort_enabled = true
	sprite.texture = load(png_path)
	node.add_child(sprite)
	sprite.owner = node

	scene.pack(node)

	# Save the scene with the same name as the PNG file
	var scene_path = png_path.get_base_dir() + "/" + (png_path.get_file().get_basename() + ".tscn")
	ResourceSaver.save(scene, scene_path)

func _create_scenes_from_directory(dir_path: String):
	var dir = DirAccess.open(dir_path)
	if !dir:
		print("Error: Unable to open the directory.")
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".png"):
			_create_scene_from_png(dir_path + "/" + file_name)
		elif not file_name.begins_with("."):  # Ignore hidden files and directories
			var sub_dir_path = dir_path + "/" + file_name
			if dir.current_is_dir():
				_create_scenes_from_directory(sub_dir_path)
		file_name = dir.get_next()

	dir.list_dir_end()