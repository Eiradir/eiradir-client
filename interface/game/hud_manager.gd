extends Control

func _ready():
	NetworkClient.HudStateReceived.connect(_on_hud_state_received)
	NetworkClient.HudMessageReceived.connect(_on_hud_message_received)
	NetworkClient.HudPropertyReceived.connect(_on_hud_property_received)
	NetworkClient.HudInventoryReceived.connect(_on_hud_inventory_received)
	NetworkClient.HudInventorySlotReceived.connect(_on_hud_inventory_slot_received)

func _process(_delta):
	var fps = Engine.get_frames_per_second() 
	%FPS.text = "FPS: %d" % fps

func _on_hud_state_received(hud_id: int, hud_type_id: int, hud_state: int):
	if hud_state == 0:
		var existing = get_node_or_null(str(hud_id))
		if existing:
			existing.visible = false
	elif hud_state == 1:
		var existing = get_node_or_null(str(hud_id))
		if existing:
			existing.visible = true
			return
		var hud_type = Registries.hud_types.load_entry_by_id(hud_type_id)
		if !hud_type:
			print("HUD type not found: %d" % hud_type_id)
			return
		if !hud_type.scene:
			print("HUD type has no scene: %d" % hud_type_id)
			return
		var hud = hud_type.scene.instantiate()
		hud.name = str(hud_id)
		var properties = hud.get_node_or_null("Properties")
		if properties:
			properties.hud_id = hud_id
		var messages = hud.get_node_or_null("Messages")
		if messages:
			messages.hud_id = hud_id
		var inventories = hud.get_node_or_null("Inventories")
		if inventories:
			inventories.hud_id = hud_id
		add_child(hud)
	elif hud_state == 2:
		var existing = get_node_or_null(str(hud_id))
		if existing:
			existing.queue_free()

func _on_hud_message_received(hud_id: int, key: int, buf):
	var hud = get_node_or_null(str(hud_id))
	if hud:
		var messages = hud.get_node_or_null("Messages")
		if messages:
			messages.hud_message_received(key, buf)

func _on_hud_property_received(hud_id: int, key: int, buf):
	var hud = get_node_or_null(str(hud_id))
	if hud:
		var properties = hud.get_node_or_null("Properties")
		if properties:
			properties.hud_property_received(key, buf)

func _on_hud_inventory_received(hud_id: int, key: int, items):
	var hud = get_node_or_null(str(hud_id))
	if hud:
		var inventories = hud.get_node_or_null("Inventories")
		if inventories:
			inventories.hud_inventory_received(key, items)

func _on_hud_inventory_slot_received(hud_id: int, key: int, slot: int, item):
	var hud = get_node_or_null(str(hud_id))
	if hud:
		var inventories = hud.get_node_or_null("Inventories")
		if inventories:
			inventories.hud_inventory_slot_received(key, slot, item)