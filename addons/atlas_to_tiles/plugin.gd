@tool
extends EditorPlugin

func _enter_tree():
	_run()

func _run():
	var atlas_file_path = "res://tiles/tileset/transitions_nopadding.atlas"
	var atlas_data = {}
	var atlas_file = FileAccess.open(atlas_file_path, FileAccess.READ)
	
	if !atlas_file:
		print("Error: Unable to open the file.")
		return

	var current_tile_name = ""
	var regex = RegEx.new()
	regex.compile("xy: (\\d+), (\\d+)")
	while not atlas_file.eof_reached():
		var line = atlas_file.get_line()
		if line == "":
			continue
		if not line.begins_with("  "):
			current_tile_name = line
			if not atlas_data.has(current_tile_name):
				var arr: Array[Vector2i] = []
				atlas_data[current_tile_name] = arr
		else:
			var xy_values = regex.search(line)
			if xy_values:
				var x = int(xy_values.get_string(1)) / 76
				var y = int(xy_values.get_string(2)) / 37
				atlas_data[current_tile_name].append(Vector2i(x, y))

	atlas_file.close()

	for tile_name in atlas_data.keys():
		if atlas_data[tile_name].size() > 0: # Add this condition
			var tile_def = TileDefinition.new()
			tile_def.source_id = 2
			print(atlas_data[tile_name])
			print(tile_def.variants)
			var variants: Array[Vector2i] = atlas_data[tile_name]
			#tile_def.variants = variants
			tile_def.init(variants)
			var tile_def_path = "res://transitions/%s.tres" % tile_name
			ResourceSaver.save(tile_def, tile_def_path)
	