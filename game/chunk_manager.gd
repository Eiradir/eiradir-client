extends Node2D

@export var chunk_size = 16
@export var group_cull_range = 2
@export var tilemap_cull_range = 2

var tilemap_scene = preload("res://game/tilemap.tscn")

var chunk_groups: Dictionary = {}
var chunk_maps: Dictionary = {}

func _ready():
	for child in get_children():
		if child is EiradirTileMap:
			var parts = child.name.split("-")
			var chunk_pos = Vector2i(int(parts[0]), int(parts[1]))
			child.chunk_pos = chunk_pos
			child.chunk_size = chunk_size
			child.init_from_tilemap()
			
	NetworkClient.TileMapReceived.connect(_on_tilemap_received)
	NetworkClient.TileUpdateReceived.connect(_on_tile_update_received)

func _on_tilemap_received(_map_name: String, chunk_pos: Vector3i, _chunk_size: int, tiles):
	var map_pos = chunk_to_map(chunk_pos)
	var map = get_tilemap_at(map_pos, chunk_pos.z)
	map.set_chunk(tiles)
	update_transitions_in_chunk(Vector2i(chunk_pos.x, chunk_pos.y), chunk_pos.z)
	update_transitions_around_chunk(Vector2i(chunk_pos.x, chunk_pos.y), chunk_pos.z)

func _on_tile_update_received(_map_name: String, world_pos: Vector3i, tile_id: int):
	var map_pos = Vector2i(world_pos.x, world_pos.y)
	var map = get_tilemap_at(map_pos, world_pos.z)
	map.set_tile(map_pos, tile_id)
	update_transitions_at(map_pos, world_pos.z)
	update_transitions_around(map_pos, world_pos.z)

func clear_out_of_range(map_pos: Vector2i):
	_clear_out_of_range_chunk_groups(map_pos)
	_clear_out_of_range_tilemaps(map_pos)

func update_transitions_around(map_pos: Vector2i, level: int):
	for dir in GridDirections.horizontal_directions:
		var neighbor_map_pos = GridDirections.apply_offset(map_pos, dir)
		update_transitions_at(neighbor_map_pos, level)

func update_transitions_in_chunk(chunk_pos: Vector2i, level: int):
	for x in range(chunk_size):
		for y in range(chunk_size):
			var map_pos = Vector2i(chunk_pos.x * chunk_size + x, chunk_pos.y * chunk_size + y)
			update_transitions_at(map_pos, level)

func update_transitions_around_chunk(chunk_pos: Vector2i, level: int):
	# for each direction, update transitions at the edge of the chunk
	for dir in GridDirections.horizontal_directions:
		var neighbour_chunk_pos = GridDirections.apply_offset(chunk_pos, dir)
		# N = x=... y=chunk_size-1
		# S = x=... y=0
		# E = x=0 y=...
		# W = x=chunk_size-1 y=...
		# NE = x=0 y=chunk_size-1
		# NW = x=chunk_size-1 y=chunk_size-1
		# SE = x=0 y=0
		# SW = x=chunk_size-1 y=0
		var edge_map_start = Vector2i(0, 0)
		var edge_map_end = Vector2i(0, 0)
		match dir:
			GridDirections.Keys.SouthEast:
				edge_map_start = Vector2i(0, 0)
				edge_map_end = Vector2i(chunk_size - 1, 0)
			GridDirections.Keys.South:
				edge_map_start = Vector2i(0, 0)
				edge_map_end = Vector2i(chunk_size - 1, 0)
			GridDirections.Keys.SouthWest:
				edge_map_start = Vector2i(chunk_size - 1, 0)
				edge_map_end = Vector2i(chunk_size - 1, 0)
			GridDirections.Keys.East:
				edge_map_start = Vector2i(0, 0)
				edge_map_end = Vector2i(0, chunk_size - 1)
			GridDirections.Keys.West:
				edge_map_start = Vector2i(chunk_size - 1, 0)
				edge_map_end = Vector2i(chunk_size - 1, chunk_size - 1)
			GridDirections.Keys.NorthEast:
				edge_map_start = Vector2i(0, chunk_size - 1)
				edge_map_end = Vector2i(0, chunk_size - 1)
			GridDirections.Keys.North:
				edge_map_start = Vector2i(0, chunk_size - 1)
				edge_map_end = Vector2i(chunk_size - 1, chunk_size - 1)
			GridDirections.Keys.NorthWest:
				edge_map_start = Vector2i(chunk_size - 1, chunk_size - 1)
				edge_map_end = Vector2i(chunk_size - 1, chunk_size - 1)
		for x in range(edge_map_start.x, edge_map_end.x + 1):
			for y in range(edge_map_start.y, edge_map_end.y + 1):
				var map_pos = Vector2i(neighbour_chunk_pos.x * chunk_size + x, neighbour_chunk_pos.y * chunk_size + y)
				update_transitions_at(map_pos, level)

func update_transitions_at(map_pos: Vector2i, level: int):
	var map = try_get_tilemap_at(map_pos, level)
	if !map:
		return
	var transition_id = TransitionResolver.resolve_transition_id(map_pos, level)
	map.set_transition(map_pos, transition_id)

func get_chunk_group_at(map_pos: Vector2i) -> String:
	var chunk_pos = map_to_chunk(map_pos)
	var key = "%d-%d" % [chunk_pos.x, chunk_pos.y]
	chunk_groups[key] = chunk_pos
	return key

func remove_chunk_group(group: String):
	var nodes = get_tree().get_nodes_in_group(group)
	for child in nodes:
		child.queue_free()
	chunk_groups.erase(group)

func remove_tilemap(key: String):
	chunk_maps.erase(key)
	var tilemap = get_node(key)
	if tilemap:
		tilemap.queue_free()

func _clear_out_of_range_chunk_groups(map_pos: Vector2i):
	var center_chunk_pos = map_to_chunk(map_pos)
	for key in chunk_groups.keys():
		var chunk_pos = chunk_groups[key]
		if abs(chunk_pos.x - center_chunk_pos.x) > group_cull_range or abs(chunk_pos.y - center_chunk_pos.y) > group_cull_range:
			remove_chunk_group(key)

func _clear_out_of_range_tilemaps(map_pos: Vector2i):
	var center_chunk_pos = map_to_chunk(map_pos)
	for key in chunk_maps.keys():
		var chunk_pos = chunk_maps[key]
		if abs(chunk_pos.x - center_chunk_pos.x) > tilemap_cull_range or abs(chunk_pos.y - center_chunk_pos.y) > tilemap_cull_range:
			remove_tilemap(key)

func try_get_tilemap_at(map_pos: Vector2i, _level: int) -> TileMap:
	var chunk_pos = map_to_chunk(map_pos)
	var key = "%d-%d" % [chunk_pos.x, chunk_pos.y]
	return get_node_or_null(key)

func get_tilemap_at(map_pos: Vector2i, _level: int) -> TileMap:
	var chunk_pos = map_to_chunk(map_pos)
	var key = "%d-%d" % [chunk_pos.x, chunk_pos.y]
	var existing = get_node_or_null(key)
	if existing:
		return existing
	var map = tilemap_scene.instantiate()
	map.name = key
	map.chunk_pos = chunk_pos
	map.chunk_size = chunk_size
	chunk_maps[key] = chunk_pos
	add_child(map)
	return map

func map_to_global(map_pos: Vector2i, level: int = 0) -> Vector2:
	var map = get_tilemap_at(map_pos, level)
	return map.to_global(map.map_to_local(map_pos))

func mouse_to_map() -> Vector2i:
	var map = get_tilemap_at(Vector2i(0, 0), 0)
	var pos = map.get_global_mouse_position()
	return map.local_to_map(map.to_local(pos))

func global_to_map(pos: Vector2) -> Vector2i:
	var map = get_tilemap_at(Vector2i(0, 0), 0)
	return map.local_to_map(map.to_local(pos))

func chunk_to_map(chunk_pos: Vector3i) -> Vector2i:
	return Vector2i(chunk_pos.x * chunk_size, chunk_pos.y * chunk_size)

func map_to_chunk(map_pos: Vector2i) -> Vector2i:
	return Vector2i(floor(map_pos.x / float(chunk_size)), floor(map_pos.y / float(chunk_size)))
