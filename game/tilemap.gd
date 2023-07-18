extends TileMap
class_name EiradirTileMap

var tiles: PackedByteArray
var chunk_pos: Vector2i
var chunk_size: int

func init_from_tilemap():
	var tile_definitions = Registries.tiles.get_entries()
	var used_cells = get_used_cells(0)
	if used_cells.size() > 0:
		tiles.resize(chunk_size * chunk_size)
	for pos in get_used_cells(0):
		var atlas_pos = get_cell_atlas_coords(0, pos)
		for tile in tile_definitions:
			for variant in tile.variants:
				if variant == atlas_pos:
					var rel_pos = pos - chunk_pos * chunk_size
					tiles[rel_pos.y * chunk_size + rel_pos.x] = Registries.tiles.get_entry_id(tile)
					break
		ChunkManager.update_transitions_at(pos, 0)

func _pick_variant(tile_def: TileDefinition, map_pos: Vector2i) -> Vector2i:
	var variants = tile_def.variants
	return variants[(map_pos.x * map_pos.y) % variants.size()]

func set_chunk(p_tiles: PackedByteArray):
	tiles = p_tiles
	var sx = chunk_pos.x * chunk_size
	var sy = chunk_pos.y * chunk_size
	for x in range(chunk_size):
		for y in range(chunk_size):
			var pos = Vector2i(sx + x, sy + y)
			var tile_def: TileDefinition = Registries.tiles.load_entry_by_id(p_tiles[y * chunk_size + x])
			if tile_def:
				var variant = _pick_variant(tile_def, pos)
				set_cell(0, pos, tile_def.source_id, variant)

func set_tile(map_pos: Vector2i, tile_id: int):
	if tiles.size() == 0:
		tiles.resize(chunk_size * chunk_size)
	var rel_map_pos = map_pos - chunk_pos * chunk_size
	tiles[rel_map_pos.y * chunk_size + rel_map_pos.x] = tile_id
	var tile_def: TileDefinition = Registries.tiles.load_entry_by_id(tile_id)
	if tile_def:
		var variant	= _pick_variant(tile_def, map_pos)
		set_cell(0, map_pos, tile_def.source_id, variant)

func set_transition(map_pos: Vector2i, transition_id: int):
	if transition_id <= 0:
		return
	set_layer_enabled(1, true)
	var transition_def: TileDefinition = Registries.transitions.load_entry_by_id(transition_id)
	if transition_def:
		var variant	= _pick_variant(transition_def, map_pos)
		set_cell(1, map_pos, transition_def.source_id, variant)
	else:
		pass#print("Transition not found: ", transition_id)

func get_tile_id(map_pos: Vector2i) -> int:
	if tiles.size() == 0:
		return 0
	var rel_map_pos = map_pos - chunk_pos * chunk_size
	return tiles[rel_map_pos.y * chunk_size + rel_map_pos.x]

func contains(map_pos: Vector2i) -> bool:
	var rel_map_pos = map_pos - chunk_pos * chunk_size
	return rel_map_pos.x >= 0 and rel_map_pos.x < chunk_size and rel_map_pos.y >= 0 and rel_map_pos.y < chunk_size
