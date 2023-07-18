extends Node

var hud_id: int
var messages = {}

func _ready():
	for child in get_children():
		messages[child.key] = child
		child.hud_id = hud_id

func hud_message_received(key: int, buf):
	var message = messages[key]
	if message:
		message.received(buf)