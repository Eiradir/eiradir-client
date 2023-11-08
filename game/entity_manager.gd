extends Node2D
class_name EntityManager

var entity_script  = preload("res://game/entity.gd")

func _ready():
	NetworkClient.EntityReceived.connect(_on_entity_received)
	NetworkClient.EntitiesReceived.connect(_on_entities_received)
	NetworkClient.EntityRemoved.connect(_on_entity_removed)
	NetworkClient.EntityMoved.connect(_on_entity_moved)
	NetworkClient.EntityTurned.connect(_on_entity_turned)

func _on_entity_received(_map_name: String, networked_entity):
	_update_entity(networked_entity)

func _on_entities_received(_map_name: String, _chunk_pos, networked_entities):
	for networked_entity in networked_entities:
		_update_entity(networked_entity)

func _on_entity_removed(_map_name: String, entity_id: String):
	var existing = get_node_or_null(entity_id)
	if existing:
		existing.queue_free()

func _update_entity(networked_entity):
	var existing = get_node_or_null(networked_entity.Id)
	if existing:
		if existing.iso_id == networked_entity.IsoId:
			_populate_entity(existing, networked_entity)
		else:
			existing.queue_free()
			_spawn_entity(networked_entity)
	else:
		_spawn_entity(networked_entity)

func _spawn_entity(networked_entity):
	var iso = Registries.isos.load_entry_by_id(networked_entity.IsoId)
	if !iso:
		print("invalid iso id ", networked_entity.IsoId, " for ", networked_entity.Id)
		return
	var entity = entity_script.new()
	var entity_visual = iso.scene.instantiate()
	entity.add_child(entity_visual)
	entity.name = networked_entity.Id
	entity.id = networked_entity.Id
	entity.iso_id = networked_entity.IsoId
	entity.iso = iso
	_populate_entity(entity, networked_entity)
	add_child(entity)

func _populate_entity(entity, networked_entity):
	var map_pos = Vector2i(networked_entity.Position.x, networked_entity.Position.y)
	entity.map_position = map_pos
	entity.level = networked_entity.Position.z
	entity.position = ChunkManager.map_to_global(map_pos)
	entity.direction = GridDirections.Keys.values()[networked_entity.Direction]
	entity.color = networked_entity.Properties.get(NetworkedDataKeys.Key.Color, Color.WHITE)
	entity.paperdolls.clear()
	entity.paperdolls.append_array(networked_entity.Properties.get(NetworkedDataKeys.Key.Paperdolls, []))
	entity.paperdoll_colors.clear()
	entity.paperdoll_colors.append_array(networked_entity.Properties.get(NetworkedDataKeys.Key.PaperdollColors, []))
	entity.visual_traits.clear()
	entity.visual_traits.append_array(networked_entity.Properties.get(NetworkedDataKeys.Key.VisualTraits, []))
	entity.visual_trait_colors.clear()
	entity.visual_trait_colors.append_array(networked_entity.Properties.get(NetworkedDataKeys.Key.VisualTraitColors, []))
	_move_entity_group(entity)

func _move_entity_group(entity):
	var chunk_group = ChunkManager.get_chunk_group_at(entity.map_position)
	if entity.chunk_group == chunk_group:
		return
	if entity.chunk_group:
		entity.remove_from_group(entity.chunk_group)
	entity.chunk_group = chunk_group
	entity.add_to_group(chunk_group)

func get_entity_at(map_position: Vector2i, level: int):
	var entities_group = ChunkManager.get_chunk_group_at(map_position)
	var entities = get_tree().get_nodes_in_group(entities_group)
	for entity in entities:
		if entity.map_position == map_position and entity.level == level:
			return entity
	return null

func get_entity_by_id(entity_id: String):
	return get_node_or_null(entity_id)

func _on_entity_moved(entity_id: String, world_pos: Vector3i):
	var entity = get_entity_by_id(entity_id)
	if !entity:
		print("received move for unknown entity ", entity_id)
		return
	var map_pos = Vector2i(world_pos.x, world_pos.y)
	entity.direction = GridDirections.get_direction_to(entity.map_position, map_pos)
	entity.map_position = map_pos
	entity.level = world_pos.z
	entity.enable_mobility()
	if entity.mobility:
		entity.mobility.move_to(world_pos)
	else:
		entity.position = ChunkManager.map_to_global(map_pos)
	_move_entity_group(entity)

func _on_entity_turned(entity_id: String, direction: GridDirections.Keys):
	var entity = get_node_or_null(entity_id)
	if !entity:
		print("received direction for unknown entity ", entity_id)
		return
	entity.direction = direction
