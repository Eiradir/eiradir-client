extends Node

var cache_by_id: Dictionary = {}
var resource_paths_by_id: Dictionary = {} 
var resource_paths_by_name: Dictionary = {}
var id_by_resource_path: Dictionary = {}
var name_by_resource_path: Dictionary = {}

func _find_resource_paths(base_dir: String) -> void:
	var dir = DirAccess.open(base_dir)
	if dir:
		dir.list_dir_begin()

		var file = dir.get_next()
		while file != "":
			if not dir.current_is_dir():
				var underscore = file.find("_")
				var id = int(file.substr(0, underscore))
				var key = file.get_basename().substr(underscore + 1)
				var path = base_dir + "/" + file.trim_suffix(".remap")
				resource_paths_by_id[id] = path
				resource_paths_by_name[key] = path
				id_by_resource_path[path] = id
				name_by_resource_path[path] = key

			file = dir.get_next()
		dir.list_dir_end()

func preload_resources():
	for id in resource_paths_by_id.keys():
		load_entry_by_id(id)

func load_registry(base_dir: String) -> void:
	_find_resource_paths(base_dir)
	#if not OS.has_feature("editor"):
	preload_resources()

func get_entry_path_by_id(id: int) -> String:
	return resource_paths_by_id.get(id, "")

func get_entry_path_by_name(key: String) -> String:
	return resource_paths_by_name.get(key, "")

func _load_cached(path: String) -> Resource: # TODO unfortunately it seems the threaded loading is broken and likely fixed in Godot 4.1+
	var error = ResourceLoader.load_threaded_request(path)
	if error != OK:
		print("Failed to load ", path, " (", error, ")")
		return null
	var load_status = ResourceLoader.load_threaded_get_status(path)
	while load_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().create_timer(0.5).timeout
		load_status = ResourceLoader.load_threaded_get_status(path)
	if load_status == ResourceLoader.THREAD_LOAD_FAILED:
		print("Failed to load ", path)
		return null
	var loaded = ResourceLoader.load_threaded_get(path)
	return loaded

func _load_cached_sync(path: String) -> Resource:
	return ResourceLoader.load(path)

func load_entry_by_id(id: int) -> Resource:
	var cached = cache_by_id.get(id, null)
	if cached != null:
		return cached
	var path = get_entry_path_by_id(id)
	if path != "":
		#return await _load_cached(path)
		var loaded = _load_cached_sync(path)
		cache_by_id[id] = loaded
		return loaded
	else:
		return null

func load_entry_by_name(key: String) -> Resource:
	var path = get_entry_path_by_name(key)
	if path != "":
		#return await _load_cached(path)
		return _load_cached_sync(path)
	else:
		return null

func get_entry_id(entry: Resource) -> int:
	return id_by_resource_path.get(entry.resource_path, -1)

func get_entry_name(entry: Resource) -> String:
	return name_by_resource_path.get(entry.resource_path, "invalid")

func get_entries() -> Array:
	return cache_by_id.values()
