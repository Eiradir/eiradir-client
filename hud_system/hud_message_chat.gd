extends Node
class_name HudMessageChat

@export var key: int

var hud_id: int

signal message_received(message: String, type: int, entity_id: String)

func received(buf):
	var message = buf.ReadString()
	var type = buf.ReadByte()
	var entity_id = buf.ReadUniqueId()
	message_received.emit(message, type, entity_id)

func send(_value: String):
	push_error("Use SubmitChatMessage to send chat to the server instead")

func encode(_value, _buf):
	push_error("Use SubmitChatMessage to send chat to the server instead")