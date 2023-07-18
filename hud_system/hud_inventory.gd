extends Node

@export var key: int

var hud_id: int
var _items: Array

signal inventory_changed(items)
signal inventory_slot_changed(slot: int, item)

func received_full(items):
	_items = items
	inventory_changed.emit(_items)

func received_slot(slot: int, item):
	_items[slot] = item
	inventory_slot_changed.emit(slot, item)

func interact(slot: int, interaction_id: int):
	NetworkClient.SendHudInventorySlotInteract(hud_id, key, slot, interaction_id)

func interacti(slot: int, interaction_id: int, param: int):
	NetworkClient.SendHudInventorySlotInteractI(hud_id, key, slot, interaction_id, param)