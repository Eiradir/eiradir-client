extends Node

class TransitionCandidate:
	var tile: TileDefinition
	var direction: GridDirections.Keys

var transitions

func _find_candidates(map_pos: Vector2i, level: int) -> Array[TransitionCandidate]:
	var map: EiradirTileMap = ChunkManager.get_tilemap_at(map_pos, level)
	var tile_id: int = map.get_tile_id(map_pos)
	var tile_def: TileDefinition = Registries.tiles.load_entry_by_id(tile_id)
	if !tile_def || tile_def.refuses_transitions:
		return []

	var result: Array[TransitionCandidate] = []

	for dir in GridDirections.horizontal_directions:
		var neighbour_map_pos: Vector2i = GridDirections.apply_offset(map_pos, dir)
		var neighbour_map: EiradirTileMap = _get_neighbour_or_this_map(map, neighbour_map_pos, level)
		if !neighbour_map:
			continue
		var neighbour_tile_id: int = neighbour_map.get_tile_id(neighbour_map_pos)
		var neighbour_tile_def: TileDefinition = Registries.tiles.load_entry_by_id(neighbour_tile_id)
		if !neighbour_tile_def:
			continue
		var neighbour_refuses_transition = neighbour_tile_def.refuses_transitions
		var neighbour_cannot_transition = neighbour_tile_def.cannot_transition
		var neighbour_is_submissive_and_breedable = neighbour_tile_id < tile_id
		if tile_id == neighbour_tile_id || neighbour_cannot_transition || neighbour_refuses_transition || neighbour_is_submissive_and_breedable:
			continue

		var candidate = TransitionCandidate.new()
		candidate.tile = neighbour_tile_def
		candidate.direction = dir
		result.append(candidate)
	return result

func _get_neighbour_or_this_map(map: EiradirTileMap, map_pos: Vector2i, level: int) -> EiradirTileMap:
	if map.contains(map_pos):
		return map
	return ChunkManager.get_tilemap_at(map_pos, level)

func _pack_directions(candidates: Array[TransitionCandidate], tile: TileDefinition) -> int:
	var packed_directions: int = 0
	for candidate in candidates:
		if candidate.tile == tile:
			packed_directions = packed_directions | GridDirections.get_bit_mask(candidate.direction)
	return packed_directions

func _get_transition_id(tile: TileDefinition, packed_directions: int) -> int:
	var tile_id = Registries.tiles.get_entry_id(tile)
	return (tile_id << 8) | packed_directions

func _find_dominant_tile(candidates: Array[TransitionCandidate]):
	var tile_counts: Dictionary = {}
	for candidate in candidates:
		if !tile_counts.has(candidate.tile):
			tile_counts[candidate.tile] = 0
		tile_counts[candidate.tile] += 1
	var max_count = 0
	var max_tile: TileDefinition = null
	for tile in tile_counts.keys():
		var count = tile_counts[tile]
		if count > max_count:
			max_count = count
			max_tile = tile
	return max_tile

func resolve_transition_id(map_pos: Vector2i, level: int) -> int:
	var candidates = _find_candidates(map_pos, level)
	var dominant_tile = _find_dominant_tile(candidates)
	if !dominant_tile:
		return 0
	var packed_directions = _pack_directions(candidates, dominant_tile)
	return _get_transition_id(dominant_tile, packed_directions)
