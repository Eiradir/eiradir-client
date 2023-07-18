extends AspectRatioContainer

var tooltip_scene = preload("res://interface/tooltip/tooltip.tscn")
var menu_scene = preload("res://interface/menu/menu.tscn")

signal clicked()
signal rightclicked()
signal tooltip_requested(tooltip: Control)
signal menu_requested(menu: PopupMenu)
signal menu_item_selected(item_id: int)

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if FocusManager.is_mouse_occupied():
				rightclicked.emit()
			else:
				add_child(_make_menu())

func set_item(item):
	var iso_id = item.IsoId
	var iso = Registries.isos.load_entry_by_id(iso_id) if iso_id > 0 else null
	if iso:
		%TextureRect.texture = iso.texture
		%TextureRect.self_modulate = item.Properties.get(NetworkedDataKeys.Key.Color, Color.WHITE)
		%CountLabel.text = str(item.Count) if item.Count > 1 else ""
		set_tooltip_text(Registries.isos.get_entry_name(iso))
	else:
		%TextureRect.texture = null
		%CountLabel.text = ""
		set_tooltip_text("empty")

func _make_custom_tooltip(_for_text: String):
	var tooltip = tooltip_scene.instantiate()
	tooltip_requested.emit(tooltip)
	return tooltip

func _make_menu():
	var menu = menu_scene.instantiate()
	menu.item_selected.connect(_menu_item_selected)
	menu.popup_hide.connect(_menu_closed.bind(menu))
	menu_requested.emit(menu)
	return menu

func _menu_item_selected(item_id: int):
	menu_item_selected.emit(item_id)

func _menu_closed(menu: PopupMenu):
	menu.queue_free()
