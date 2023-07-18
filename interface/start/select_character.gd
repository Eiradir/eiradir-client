extends Control

signal to_create_character(server: String)
signal character_selected(server: String, id: int)

var servers = [
	{
		name = "Eiradir Server",
		icon = preload("res://icons/eiradir.png"),
		url = "https://server.eiradir.net"
	},
	{
		name = "Local Server",
		icon = preload("res://icons/eiradev.png"),
		url = "http://localhost:8080"
	}
]
var _server_url: String

func _ready():
	%Server.clear()
	for server in servers:
		%Server.add_icon_item(server.icon, server.name)
	%Server.select(1 if OS.has_feature("editor") else 0)
	_on_server_item_selected(%Server.selected)

func _on_create_character_button_pressed():
	to_create_character.emit(_server_url)

func fetch_characters():
	for child in %CharacterButtons.get_children():
		child.queue_free()
	%CreateCharacterButton.hide()
	%LoadingCharactersLabel.show()
	var result = await Eiradir.server_api.fetch_character_list(_server_url).completed
	var characters = result[0]
	var error = result[1]
	if error:
		return
	for child in %CharacterButtons.get_children():
		%CharacterButtons.remove_child(child)
		child.queue_free()
	if Eiradir.tokens.get_roles().has("headless-login"):
		var button = Button.new()
		button.text = "Headless Login"
		button.pressed.connect(func():
			character_selected.emit(_server_url, 0)
		)
		%CharacterButtons.add_child(button)
	for chara in characters:
		print(chara)
		var button = Button.new()
		button.text = chara.name
		button.pressed.connect(func():
			character_selected.emit(_server_url, chara.id)
		)
		%CharacterButtons.add_child(button)
	%LoadingCharactersLabel.hide()
	%CreateCharacterButton.show()

func _on_server_item_selected(index: int):
	_server_url = servers[index].url
	fetch_characters()
