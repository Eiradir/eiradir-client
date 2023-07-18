extends Node

var game_root: Node2D
var tile_selection = preload("res://game/cursor/tile_selection.tscn")
var tile_cursor_position = Vector2i(0, 0)
var last_tile_selection: Node2D = null

func _ready():
	game_root = get_node("/root/game")

func _process(_delta):
	var map_position = ChunkManager.mouse_to_map()
	if tile_cursor_position != map_position:
		if last_tile_selection:
			last_tile_selection.fade_out()
			last_tile_selection = null
		var map = ChunkManager.try_get_tilemap_at(map_position, 0)
		var has_tile = map.get_cell_source_id(0, map_position) != -1 if map else false
		if has_tile:
			last_tile_selection = tile_selection.instantiate()
			last_tile_selection.position = ChunkManager.map_to_global(map_position)
			game_root.add_child(last_tile_selection)
		tile_cursor_position = map_position
	%CursorItem.position = get_viewport().get_mouse_position()

func _on_inventory_inventory_slot_changed(_slot: int, item):
	if item.Count == 0:
		%CursorItem.hide()
		FocusManager.mouse_occupied = false
		return
	var iso_id = item.IsoId
	var iso = Registries.isos.load_entry_by_id(iso_id)
	if iso:
		%CursorItem.texture = iso.texture
		%CursorItemCountLabel.text = str(item.Count) if item.Count > 1 else ""
		%CursorItem.show()
		FocusManager.mouse_occupied = true
	else:
		%CursorItem.hide()
		FocusManager.mouse_occupied = false


func _on_inventory_inventory_changed(items):
	for i in range(0, items.size()):
		_on_inventory_inventory_slot_changed(i, items[i])
