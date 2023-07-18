extends Node

signal menu_received(nonce: int, items: Array)

func _ready():
	NetworkClient.MenuReceived.connect(_on_menu_received)

func _on_menu_received(nonce: int, items):
	menu_received.emit(nonce, items)