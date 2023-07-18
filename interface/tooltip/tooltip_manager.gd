extends Node

signal tooltip_received(nonce: int, items: Array)

func _ready():
	NetworkClient.TooltipReceived.connect(_on_tooltip_received)

func _on_tooltip_received(nonce: int, items):
	tooltip_received.emit(nonce, items)