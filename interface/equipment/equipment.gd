extends Control

func _ready():
	for slot in %EquipmentSlots.get_children():
		var slot_id = slot.name.right(2).to_int()
		slot.tooltip_requested.connect(_on_slot_tooltip.bind(slot_id))
		slot.menu_requested.connect(_on_slot_menu.bind(slot_id))
		slot.menu_item_selected.connect(_on_slot_menu_item_selected.bind(slot_id))
		slot.clicked.connect(_on_slot_clicked.bind(slot_id))
		slot.rightclicked.connect(_on_slot_rightclicked.bind(slot_id))
	for slot in %BeltSlots.get_children():
		var slot_id = slot.name.right(2).to_int()
		slot.tooltip_requested.connect(_on_slot_tooltip.bind(slot_id))
		slot.menu_requested.connect(_on_slot_menu.bind(slot_id))
		slot.menu_item_selected.connect(_on_slot_menu_item_selected.bind(slot_id))
		slot.clicked.connect(_on_slot_clicked.bind(slot_id))
		slot.rightclicked.connect(_on_slot_rightclicked.bind(slot_id))

func _on_inventory_inventory_changed(items):
	for i in range(0, items.size()):
		var item = items[i]
		var slot = get_node_or_null("%%Slot%02d" % i)
		if slot:
			slot.set_item(item)

func _on_inventory_inventory_slot_changed(slot_id, item):
	var slot = get_node_or_null("%%Slot%02d" % slot_id)
	if slot:
		slot.set_item(item)

func _on_slot_tooltip(tooltip: Control, slot_id: int):
	tooltip.nonce = randi() % 100000
	%Inventory.interacti(slot_id, 6, tooltip.nonce)

func _on_slot_menu(menu: PopupMenu, slot_id: int):
	menu.nonce = randi() % 100000
	%Inventory.interacti(slot_id, 7, menu.nonce)

func _on_slot_menu_item_selected(item_id: int, slot_id: int):
	%Inventory.interact(slot_id, item_id)

func _on_slot_clicked(slot_id: int):
	if Input.is_action_pressed("use"):
		%Inventory.interact(slot_id, 8)
	else:
		%Inventory.interact(slot_id, 1)

func _on_slot_rightclicked(slot_id: int):
	%Inventory.interact(slot_id, 2)
