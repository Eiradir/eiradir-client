extends Node

var hud_id: int
var properties = {}

func _ready():
	for child in get_children():
		properties[child.key] = child
		child.hud_id = hud_id

func hud_property_received(key: int, buf):
	var property = properties[key]
	if property:
		property.received(buf)
