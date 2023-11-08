extends Node

var tooltip_scene = preload("res://interface/tooltip/tooltip.tscn")
var menu_scene = preload("res://interface/menu/menu.tscn")

var entity_manager: EntityManager
var tile_cursor_position: Vector2i = Vector2i(0, 0)
var hover_time_passed: float = -1.0
var eager_hover_time_passed: float = -1.0
var current_tooltip: PopupPanel
var current_menu: PopupMenu

func _ready():
	entity_manager = %EntityManager

func _process(delta: float):
	var map_position = ChunkManager.mouse_to_map()
	if tile_cursor_position != map_position:
		if current_tooltip:
			current_tooltip.queue_free()
			current_tooltip = null
		hover_time_passed = 0.0
		eager_hover_time_passed = 0.0
		tile_cursor_position = map_position
	elif !current_menu:
		if hover_time_passed != -1.0:
			hover_time_passed += delta
		if eager_hover_time_passed != -1.0:
			eager_hover_time_passed += delta
	if hover_time_passed > 0.2 and hover_time_passed != -1.0:
		request_tooltip(map_position, 0, false)
		hover_time_passed = -1.0
	elif eager_hover_time_passed > 3 and eager_hover_time_passed != -1.0:
		request_tooltip(map_position, 0, true)
		eager_hover_time_passed = -1.0

func _input(event):
	if FocusManager.is_mouse_over_hud():
		return
	var map_position = ChunkManager.mouse_to_map()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		position_clicked(map_position, 0)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		position_rightclicked(map_position, 0)

func position_clicked(map_position: Vector2i, level: int):
	var entity = entity_manager.get_entity_at(map_position, level)
	if entity and not entity.iso.disallow_drag:
		NetworkClient.SendEntityInteract(entity.id, 1, [])
		return

	if Input.is_action_pressed("use"):
		interact(map_position, level, 8)
	elif FocusManager.is_mouse_occupied():
		interact(map_position, level, 1)

func position_rightclicked(map_position: Vector2i, level: int):
	if FocusManager.is_mouse_occupied():
		interact(map_position, level, 2)
		return

	var entity = entity_manager.get_entity_at(map_position, level)
	if entity:
		var nonce = randi() % 100000
		var menu = create_menu()
		menu.nonce = nonce
		menu.item_selected.connect(_entity_menu_item_selected.bind(entity.id))
		menu.popup_hide.connect(_menu_closed.bind(menu))
		current_menu = menu
		NetworkClient.SendEntityInteract(entity.id, 7, [nonce])
		if current_tooltip:
			current_tooltip.queue_free()
			current_tooltip = null
		return

	var map = ChunkManager.try_get_tilemap_at(map_position, level)
	var has_tile = map.get_cell_source_id(0, map_position) != -1 if map else false
	if has_tile:
		var nonce = randi() % 100000
		var menu = create_menu()
		menu.nonce = nonce
		menu.item_selected.connect(_tile_menu_item_selected.bind(map_position, level))
		menu.popup_hide.connect(_menu_closed.bind(menu))
		current_menu = menu
		NetworkClient.SendTileInteract(map_position, level, 7, [nonce])
		if current_tooltip:
			current_tooltip.queue_free()
			current_tooltip = null

func interact(map_position: Vector2i, level: int, interaction_id: int):
	var entity = entity_manager.get_entity_at(map_position, level)
	if entity:
		NetworkClient.SendEntityInteract(entity.id, interaction_id, [])
		return

	var map = ChunkManager.try_get_tilemap_at(map_position, level)
	var has_tile = map.get_cell_source_id(0, map_position) != -1 if map else false
	if has_tile:
		NetworkClient.SendTileInteract(map_position, level, interaction_id, [])

func request_tooltip(map_position: Vector2i, level: int, eager: bool):
	var entity = entity_manager.get_entity_at(map_position, level)
	if entity and (entity.iso.eager_tooltip or eager):
		var nonce = randi() % 100000
		var tooltip = create_tooltip()
		tooltip.nonce = nonce
		NetworkClient.SendEntityInteract(entity.id, 6, [nonce])
		return

	if eager:
		var map = ChunkManager.try_get_tilemap_at(map_position, level)
		var has_tile = map.get_cell_source_id(0, map_position) != -1 if map else false
		if has_tile:
			var nonce = randi() % 100000
			var tooltip = create_tooltip()
			tooltip.nonce = nonce
			NetworkClient.SendTileInteract(map_position, level, 6, [nonce])

func create_tooltip():
	if current_tooltip:
		current_tooltip.queue_free()
		current_tooltip = null

	var panel = PopupPanel.new()
	panel.theme_type_variation = "TooltipPanel"

	var tooltip = tooltip_scene.instantiate()
	tooltip.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.transient = true
	panel.wrap_controls = true
	panel.set_flag(Window.FLAG_NO_FOCUS, true)
	panel.set_flag(Window.FLAG_POPUP, false)
	panel.set_flag(Window.FLAG_MOUSE_PASSTHROUGH, true)
	panel.add_child(tooltip)
	add_child(panel)
	var tooltip_pos = get_viewport().get_mouse_position()
	var tooltip_offset = ProjectSettings.get_setting("display/mouse_cursor/tooltip_position_offset")
	var rect = Rect2(tooltip_pos + tooltip_offset, panel.get_contents_minimum_size())
	rect.size = rect.size.clamp(rect.size, panel.get_max_size())

	var viewport_rect = get_viewport().get_visible_rect()
	if rect.size.x + rect.position.x > viewport_rect.size.x + viewport_rect.position.x:
		rect.position.x = tooltip_pos.x - rect.size.x - tooltip_offset.x

		if rect.position.x < viewport_rect.position.x:
			rect.position.x = viewport_rect.position.x + viewport_rect.size.x - rect.size.x
	elif rect.position.x < viewport_rect.position.x:
		rect.position.x = viewport_rect.position.x
	

	if rect.size.y + rect.position.y > viewport_rect.size.y + viewport_rect.position.y:
		rect.position.y = tooltip_pos.y - rect.size.y - tooltip_offset.y

		if rect.position.y < viewport_rect.position.y:
			rect.position.y = viewport_rect.position.y + viewport_rect.size.y - rect.size.y
	elif rect.position.y < viewport_rect.position.y:
		rect.position.y = viewport_rect.position.y

	panel.set_position(rect.position)
	panel.set_size(rect.size)
	panel.show()
	panel.child_controls_changed()
	current_tooltip = panel
	return tooltip

func create_menu():
	var menu = menu_scene.instantiate()
	%CanvasLayer.add_child(menu)
	return menu

func _menu_closed(menu: PopupMenu):
	menu.queue_free()
	menu = null

func _entity_menu_item_selected(item_id: int, entity_id: String):
	NetworkClient.SendEntityInteract(entity_id, item_id, [])

func _tile_menu_item_selected(item_id: int, map_position: Vector2i, level: int):
	NetworkClient.SendTileInteract(map_position, level, item_id, [])
