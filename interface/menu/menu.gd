extends PopupMenu

signal item_selected(interaction_id: int)

var nonce: int = 0
var _items: Array = []

func _ready():
	MenuManager.menu_received.connect(_on_menu_received)

func _on_menu_received(p_nonce: int, items: Array):
	if nonce != p_nonce:
		print("nonce mismatch: %d vs %d" % [nonce, p_nonce])
		return
	_items = items
	for item in items:
		if item.type == 0:
			add_item(item.text, item.id)
	position = get_viewport().get_mouse_position() + Vector2(10, 10)
	show()

func _on_index_pressed(index):
	var item = _items[index]
	item_selected.emit(item.id)
