extends Node

@export var key: int
@export var _value: Array

var hud_id: int

signal property_changed(value: Array)

func received(buf):
	var count = buf.ReadShort()
	_value.resize(count)
	for i in range(count):
		_value[i] = {
			iconId = buf.ReadShort(),
			name = buf.ReadString()
		}
	property_changed.emit(_value)

func encode(_buf):
	pass