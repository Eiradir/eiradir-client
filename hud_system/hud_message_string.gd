extends Node
class_name HudMessageString

@export var key: int

var hud_id: int

signal message_received(value: String)

func received(buf):
	var value = buf.ReadString()
	message_received.emit(value)

func send(value: String):
	NetworkClient.SendHudMessage(self, value)

func encode(value, buf):
	buf.WriteString(value)