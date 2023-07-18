extends Node

var hud_id: int
var inventories = {}

func _ready():
	for child in get_children():
		inventories[child.key] = child
		child.hud_id = hud_id

func hud_inventory_received(key: int, items):
	var inventory = inventories[key]
	if inventory:
		inventory.received_full(items)

func hud_inventory_slot_received(key: int, slot: int, item):
	var inventory = inventories[key]
	if inventory:
		inventory.received_slot(slot, item)
		