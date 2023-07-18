extends Node

@export var key: int
@export var _value: int

var hud_id: int

signal property_changed(value: int)

func received(buf):
	_value = buf.ReadInt()
	property_changed.emit(_value)

func set_value(value: int):
	_value = value
	NetworkClient.SendHudProperty(self)

func encode(buf):
	buf.WriteInt(_value)