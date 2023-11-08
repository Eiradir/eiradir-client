extends Control

signal to_select_character
signal to_info(title: String, message: String)
signal to_game(game: Node)

var _server: String
var _char_id: int
var _game: Node

func init(server: String, id: int):
	_server = server
	_char_id = id

func _ready():
	%Message.text = tr("JOIN_FETCHING_TOKEN")
	var result = await Eiradir.server_api.fetch_join_token(_server).completed
	var username = result[0]
	var join_token = result[1]
	var game_host = result[2]
	var game_port = result[3]
	%Message.text = tr("JOIN_CONNECTING")
	NetworkClient.Connected.connect(_on_connected.bind(username, join_token))
	NetworkClient.Joining.connect(_on_joining)
	NetworkClient.Joined.connect(_on_joined)
	NetworkClient.Disconnected.connect(_on_disconnected)
	NetworkClient.ConnectToServer(game_host, game_port)
	
func _on_connected(username, join_token):
	_game = load("res://game/game.tscn").instantiate()
	_game.hide()
	get_tree().get_root().add_child(_game)
	NetworkClient.SendConnect(username, join_token, {
		headless = true if _char_id == 0 else false,
		char = _char_id
	})

func _on_joining():
	%Message.text = tr("JOIN_LOADING_WORLD")

func _on_joined():
	%Message.text = tr("JOIN_FINISHED")
	to_game.emit(_game)

func _on_disconnected(_reason: int, message: String):
	if _game:
		_game.queue_free()
	to_info.emit("Unable to join", message)

func _on_cancel_button_pressed():
	if _game:
		_game.queue_free()
	to_select_character.emit()
